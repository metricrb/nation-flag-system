--!strict

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("NationFlagSystem"):WaitForChild("Config"))
local Nations = require(ReplicatedStorage:WaitForChild("NationFlagSystem"):WaitForChild("Nations"))

--[=[
	Registered flag pole handle.

	@interface PoleRecord
	@within FlagRegistry
	.mesh MeshPart
	.model Model
	.poleId string
	.prompt ProximityPrompt
]=]
export type PoleRecord = {
	poleId: string,
	model: Model,
	mesh: MeshPart,
	prompt: ProximityPrompt,
}

--[=[
	@class FlagRegistry
	Discovers flag Models, attaches ProximityPrompts, and applies nation textures.
]=]
local FlagRegistry = {}

local polesById: { [string]: PoleRecord } = {}
local onRegistered: ((PoleRecord) -> ())? = nil

local function findFlagMesh(model: Model): MeshPart?
	local preferred: MeshPart? = nil
	local fallback: MeshPart? = nil
	for _, descendant in model:GetDescendants() do
		if descendant:IsA("MeshPart") then
			local lower = string.lower(descendant.Name)
			if string.find(lower, "flag", 1, true) then
				preferred = descendant
				break
			end
			if fallback == nil and descendant.TextureID ~= "" then
				fallback = descendant
			elseif fallback == nil then
				fallback = descendant
			end
		end
	end
	return preferred or fallback
end

local function ensurePoleId(model: Model): string
	local existing = model:GetAttribute("PoleId")
	if typeof(existing) == "string" and existing ~= "" then
		return existing
	end
	local poleId = HttpService:GenerateGUID(false)
	model:SetAttribute("PoleId", poleId)
	return poleId
end

local function updatePromptObjectText(prompt: ProximityPrompt, model: Model, mesh: MeshPart)
	local current = model:GetAttribute("CurrentNation")
	if typeof(current) == "string" and current ~= "" then
		local nation = Nations.get(current)
		prompt.ObjectText = if nation then nation.displayName else current
		return
	end

	local matched = Nations.getByTexture(mesh.TextureID)
	if matched then
		model:SetAttribute("CurrentNation", matched.id)
		prompt.ObjectText = matched.displayName
	elseif model.Name ~= "Model" then
		prompt.ObjectText = model.Name
	else
		prompt.ObjectText = "Flag"
	end
end

local function ensurePrompt(attach: BasePart): ProximityPrompt
	local existing = attach:FindFirstChild("FlagChangePrompt")
	if existing and existing:IsA("ProximityPrompt") then
		return existing
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.Name = "FlagChangePrompt"
	prompt.ActionText = Config.PromptActionText
	prompt.ObjectText = "Flag"
	prompt.MaxActivationDistance = Config.PromptMaxDistance
	prompt.HoldDuration = Config.PromptHoldDuration
	prompt.RequiresLineOfSight = false
	prompt.Parent = attach
	return prompt
end

--[=[
	Sets a callback invoked whenever a pole is registered (including during `init`).

	@within FlagRegistry
	@param callback (PoleRecord) -> ()
]=]
function FlagRegistry.setOnRegistered(callback: (PoleRecord) -> ())
	onRegistered = callback
end

--[=[
	Registers a single flag Model (idempotent by `PoleId`).

	@within FlagRegistry
	@param model Model
	@return PoleRecord?
]=]
function FlagRegistry.registerModel(model: Model): PoleRecord?
	local existingId = model:GetAttribute("PoleId")
	if typeof(existingId) == "string" and polesById[existingId] then
		return polesById[existingId]
	end

	local mesh = findFlagMesh(model)
	if not mesh then
		warn("[NationFlagSystem] No MeshPart found on", model:GetFullName())
		return nil
	end

	local poleId = ensurePoleId(model)
	if polesById[poleId] then
		return polesById[poleId]
	end

	local prompt = ensurePrompt(mesh)
	updatePromptObjectText(prompt, model, mesh)

	local record: PoleRecord = {
		poleId = poleId,
		model = model,
		mesh = mesh,
		prompt = prompt,
	}
	polesById[poleId] = record

	if onRegistered then
		onRegistered(record)
	end

	return record
end

local function resolveFolder(): Folder?
	local ok, folder = pcall(function()
		local current: Instance = game
		for part in string.gmatch(Config.FlagFolderPath, "[^%.]+") do
			if part == "game" then
				continue
			end
			current = (current :: any):WaitForChild(part, 2)
		end
		return current
	end)
	if ok and folder and folder:IsA("Folder") then
		return folder
	end
	return nil
end

--[=[
	Scans the configured flag folder and CollectionService tag.

	@within FlagRegistry
]=]
function FlagRegistry.init()
	table.clear(polesById)

	local folder = resolveFolder()
	if folder then
		for _, child in folder:GetChildren() do
			if child:IsA("Model") then
				FlagRegistry.registerModel(child)
			end
		end
		folder.ChildAdded:Connect(function(child)
			if child:IsA("Model") then
				FlagRegistry.registerModel(child)
			end
		end)
	else
		warn("[NationFlagSystem] Flag folder not found:", Config.FlagFolderPath)
	end

	for _, tagged in CollectionService:GetTagged(Config.CollectionTag) do
		if tagged:IsA("Model") then
			FlagRegistry.registerModel(tagged)
		end
	end

	CollectionService:GetInstanceAddedSignal(Config.CollectionTag):Connect(function(instance)
		if instance:IsA("Model") then
			FlagRegistry.registerModel(instance)
		end
	end)
end

--[=[
	@within FlagRegistry
	@param poleId string
	@return PoleRecord?
]=]
function FlagRegistry.get(poleId: string): PoleRecord?
	return polesById[poleId]
end

--[=[
	@within FlagRegistry
	@return number
]=]
function FlagRegistry.count(): number
	local n = 0
	for _ in polesById do
		n += 1
	end
	return n
end

--[=[
	Sets MeshPart.TextureID and updates `CurrentNation` / prompt ObjectText.

	@within FlagRegistry
	@param record PoleRecord
	@param nationId string
	@return boolean — false if nation missing or has empty texture
]=]
function FlagRegistry.applyNation(record: PoleRecord, nationId: string): boolean
	local nation = Nations.get(nationId)
	if not nation or nation.textureId == "" then
		return false
	end

	-- Prefer classic asset URL — matches textures authored on FlagHall meshes
	local digits = string.match(nation.textureId, "(%d+)")
	if not digits then
		return false
	end
	local textureUrl = "http://www.roblox.com/asset/?id=" .. digits

	record.mesh.TextureID = textureUrl
	record.model:SetAttribute("CurrentNation", nation.id)
	record.prompt.ObjectText = nation.displayName

	-- Confirm write stuck (some meshes reject certain content ids)
	if string.match(record.mesh.TextureID, digits) == nil then
		record.mesh.TextureID = "rbxassetid://" .. digits
	end

	return string.match(record.mesh.TextureID, digits) ~= nil
end

return FlagRegistry
