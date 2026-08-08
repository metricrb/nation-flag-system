--!strict

--[=[
	@class Types
	Shared type aliases for Nation Flag System modules.
]=]

--[=[
	Authorization mode for a pole or global Config.

	Possible values: `Group`, `Team`, `Either`, `Anyone`.

	@type AuthMode "Group" | "Team" | "Either" | "Anyone"
	@within Types
]=]
export type AuthMode = "Group" | "Team" | "Either" | "Anyone"

--[=[
	A selectable nation in the picker / registry.

	@interface NationEntry
	@within Types
	.displayName string — Human-readable name
	.id string — Stable id (ISO2, ISO3 alias, or custom e.g. `UNO`)
	.inPassportAssets boolean — Listed in passport-system assets / defaults
	.iso2 string? — ISO 3166-1 alpha-2 when applicable
	.textureId string — `rbxassetid://...` for MeshPart.TextureID
]=]
export type NationEntry = {
	id: string,
	displayName: string,
	textureId: string,
	iso2: string?,
	inPassportAssets: boolean,
}

--[=[
	Resolved authorization settings for a pole.

	@interface PoleAuth
	@within Types
	.authMode AuthMode
	.groupId number
	.minGroupRank number
	.teamName string
]=]
export type PoleAuth = {
	authMode: AuthMode,
	groupId: number,
	minGroupRank: number,
	teamName: string,
}

return {}
