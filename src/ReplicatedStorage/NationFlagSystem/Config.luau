--!strict

local Types = require(script.Parent.Types)

--[=[
	@class Config
	Global defaults for authorization, flag discovery, and prompts.
	Override per pole with Attributes (`AuthMode`, `GroupId`, `MinGroupRank`, `TeamName`).
]=]

--[=[
	@prop AuthMode Types.AuthMode
	@within Config
	Default auth mode. `"Either"` allows group **or** team.
]=]

--[=[
	@prop GroupId number
	@within Config
	Roblox group id. `0` disables the group check.
]=]

--[=[
	@prop MinGroupRank number
	@within Config
	Minimum rank required in `GroupId`.
]=]

--[=[
	@prop TeamName string
	@within Config
	Exact `Team.Name` for team authorization.
]=]

--[=[
	@prop FlagFolderPath string
	@within Config
	Dot path from `game` to the folder of flag Models (default `Workspace.Flags`).
]=]

--[=[
	@prop CollectionTag string
	@within Config
	CollectionService tag for poles outside the flag folder.
]=]

--[=[
	@prop PromptActionText string
	@within Config
]=]

--[=[
	@prop PromptMaxDistance number
	@within Config
]=]

--[=[
	@prop PromptHoldDuration number
	@within Config
]=]

--[=[
	@prop DenyMessage string
	@within Config
	Toast shown when a player is not authorized.
]=]

export type Config = {
	AuthMode: Types.AuthMode,
	GroupId: number,
	MinGroupRank: number,
	TeamName: string,
	FlagFolderPath: string,
	CollectionTag: string,
	PromptActionText: string,
	PromptMaxDistance: number,
	PromptHoldDuration: number,
	DenyMessage: string,
}

local Config: Config = {
	AuthMode = "Either", -- "Group" | "Team" | "Either" | "Anyone"
	GroupId = 0,
	MinGroupRank = 1,
	TeamName = "Foreign Affairs",

	FlagFolderPath = "Workspace.Flags",
	CollectionTag = "CustomizableFlag",

	PromptActionText = "Change Flag",
	PromptMaxDistance = 10,
	PromptHoldDuration = 0,

	DenyMessage = "You are not allowed to change this flag.",
}

return Config
