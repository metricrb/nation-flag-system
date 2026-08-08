--!strict

--[=[
	@class FlagService
	Server entry Script. Creates remotes, initializes [FlagRegistry], hooks prompts,
	and handles `RequestSetNation` with [FlagAuth] checks.

	Remotes under `ReplicatedStorage.NationFlagSystem.Remotes`:
	- `OpenPicker` (server → client): `poleId`, `currentNationId`
	- `RequestSetNation` (client → server): `poleId`, `nationId`
	- `Notify` (server → client): toast `message`
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("NationFlagSystem"):WaitForChild("Config"))
local Nations = require(ReplicatedStorage:WaitForChild("NationFlagSystem"):WaitForChild("Nations"))
local FlagAuth = require(script.Parent.FlagAuth)
local FlagRegistry = require(script.Parent.FlagRegistry)

local root = ReplicatedStorage:WaitForChild("NationFlagSystem")
local remotesFolder = root:FindFirstChild("Remotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = root
end

local function ensureRemote(name: string): RemoteEvent
	local existing = remotesFolder:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = remotesFolder
	return remote
end

local OpenPicker = ensureRemote("OpenPicker")
local RequestSetNation = ensureRemote("RequestSetNation")
local Notify = ensureRemote("Notify")

local hookedPrompts: { [ProximityPrompt]: RBXScriptConnection } = {}

local function notify(player: Player, message: string)
	Notify:FireClient(player, message)
end

local function hookPrompt(record: FlagRegistry.PoleRecord)
	if hookedPrompts[record.prompt] then
		return
	end

	hookedPrompts[record.prompt] = record.prompt.Triggered:Connect(function(player: Player)
		if not FlagAuth.isAuthorized(player, record.model) then
			notify(player, Config.DenyMessage)
			return
		end

		local current = record.model:GetAttribute("CurrentNation")
		local currentId = if typeof(current) == "string" then current else ""
		OpenPicker:FireClient(player, record.poleId, currentId)
	end)
end

FlagRegistry.setOnRegistered(hookPrompt)
FlagRegistry.init()

RequestSetNation.OnServerEvent:Connect(function(player: Player, poleId: unknown, nationId: unknown)
	if typeof(poleId) ~= "string" or typeof(nationId) ~= "string" then
		warn("[NationFlagSystem] Bad RequestSetNation payload", typeof(poleId), typeof(nationId))
		notify(player, "Invalid flag request.")
		return
	end

	local record = FlagRegistry.get(poleId)
	if not record then
		warn("[NationFlagSystem] Unknown poleId", poleId)
		notify(player, "Flag not found.")
		return
	end

	if not FlagAuth.isAuthorized(player, record.model) then
		notify(player, Config.DenyMessage)
		return
	end

	local nation = Nations.get(nationId)
	if not nation then
		warn("[NationFlagSystem] Unknown nationId", nationId)
		notify(player, "Unknown nation.")
		return
	end

	local ok = FlagRegistry.applyNation(record, nationId)
	if ok then
		print("[NationFlagSystem] Set", poleId, "->", nation.id, nation.textureId)
		notify(player, "Flag set to " .. nation.displayName)
	else
		warn("[NationFlagSystem] applyNation failed", nationId, nation.textureId)
		notify(player, "Could not apply that nation flag.")
	end
end)

print(string.format("[NationFlagSystem] Ready — %d poles, %d nations", FlagRegistry.count(), #Nations.list()))
