--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("NationFlagSystem"):WaitForChild("Config"))
local Types = require(ReplicatedStorage:WaitForChild("NationFlagSystem"):WaitForChild("Types"))

--[=[
	@class FlagAuth
	Resolves per-pole authorization attributes and checks players.
]=]
local FlagAuth = {}

local function readStringAttribute(instance: Instance, name: string, fallback: string): string
	local value = instance:GetAttribute(name)
	if typeof(value) == "string" and value ~= "" then
		return value
	end
	return fallback
end

local function readNumberAttribute(instance: Instance, name: string, fallback: number): number
	local value = instance:GetAttribute(name)
	if typeof(value) == "number" then
		return value
	end
	return fallback
end

--[=[
	Reads pole Attributes with Config fallbacks.

	@within FlagAuth
	@param pole Instance — Flag Model
	@return Types.PoleAuth
]=]
function FlagAuth.resolve(pole: Instance): Types.PoleAuth
	local mode = readStringAttribute(pole, "AuthMode", Config.AuthMode)
	if mode ~= "Group" and mode ~= "Team" and mode ~= "Either" and mode ~= "Anyone" then
		mode = Config.AuthMode
	end

	local groupId = readNumberAttribute(pole, "GroupId", Config.GroupId)
	if groupId == 0 then
		groupId = Config.GroupId
	end

	return {
		authMode = mode :: Types.AuthMode,
		groupId = groupId,
		minGroupRank = readNumberAttribute(pole, "MinGroupRank", Config.MinGroupRank),
		teamName = readStringAttribute(pole, "TeamName", Config.TeamName),
	}
end

local function inGroup(player: Player, groupId: number, minRank: number): boolean
	if groupId <= 0 then
		return false
	end
	local ok, rank = pcall(function()
		return player:GetRankInGroup(groupId)
	end)
	return ok and typeof(rank) == "number" and rank >= minRank
end

local function onTeam(player: Player, teamName: string): boolean
	if teamName == "" then
		return false
	end
	local team = player.Team
	return team ~= nil and team.Name == teamName
end

--[=[
	Returns whether `player` may change this pole.

	@within FlagAuth
	@param player Player
	@param pole Instance
	@return boolean
]=]
function FlagAuth.isAuthorized(player: Player, pole: Instance): boolean
	local auth = FlagAuth.resolve(pole)
	if auth.authMode == "Anyone" then
		return true
	end

	local groupOk = inGroup(player, auth.groupId, auth.minGroupRank)
	local teamOk = onTeam(player, auth.teamName)

	if auth.authMode == "Group" then
		return groupOk
	elseif auth.authMode == "Team" then
		return teamOk
	elseif auth.authMode == "Either" then
		return groupOk or teamOk
	end

	return false
end

return FlagAuth
