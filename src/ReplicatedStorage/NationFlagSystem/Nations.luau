--!strict

local WorldFlags = require(script.Parent.WorldFlags)
local PassportExtras = require(script.Parent.PassportExtras)
local Types = require(script.Parent.Types)

type WorldFlag = { name: string, flagAssetId: number }

--[=[
	@class Nations
	Merged nation catalog for the picker and server.
	Combines [WorldFlags], [PassportExtras], and place-known texture overrides.
]=]
local Nations = {}

local byId: { [string]: Types.NationEntry } = {}
local ordered: { Types.NationEntry } = {}
local textureToId: { [string]: string } = {}

local function toTextureId(assetId: number): string
	return "rbxassetid://" .. tostring(assetId)
end

local function normalizeTextureKey(textureId: string): string
	local digits = string.match(textureId, "(%d+)")
	return digits or textureId
end

local function addNation(entry: Types.NationEntry)
	local existing = byId[entry.id]
	if existing then
		if entry.inPassportAssets and not existing.inPassportAssets then
			byId[entry.id] = entry
		elseif entry.textureId ~= "" and (existing.textureId == "" or existing.textureId == "rbxassetid://0") then
			byId[entry.id] = entry
		elseif entry.textureId ~= existing.textureId and entry.textureId ~= "" then
			byId[entry.id] = entry
		else
			return
		end
	else
		byId[entry.id] = entry
	end
	if entry.textureId ~= "" then
		textureToId[normalizeTextureKey(entry.textureId)] = entry.id
	end
end

local passportSet: { [string]: boolean } = {}
for _, code in PassportExtras.PassportCodes do
	passportSet[code] = true
end

local iso2InPassport: { [string]: boolean } = {}
for iso3, iso2 in PassportExtras.Iso3ToIso2 do
	if passportSet[iso3] then
		iso2InPassport[iso2] = true
	end
end

for iso2, data in WorldFlags :: { [string]: WorldFlag } do
	addNation({
		id = iso2,
		displayName = data.name,
		textureId = toTextureId(data.flagAssetId),
		iso2 = iso2,
		inPassportAssets = iso2InPassport[iso2] == true,
	})
end

-- ISO3 aliases resolve via get() but are not duplicated in the picker list
for iso3, iso2 in PassportExtras.Iso3ToIso2 do
	if not passportSet[iso3] then
		continue
	end
	local base = byId[iso2]
	if base then
		byId[iso3] = {
			id = iso3,
			displayName = base.displayName,
			textureId = base.textureId,
			iso2 = iso2,
			inPassportAssets = true,
		}
		base.inPassportAssets = true
	end
end

local listedCustoms: { [string]: boolean } = {}
for code, override in PassportExtras.Overrides do
	local textureId = ""
	if override.flagAssetId and override.flagAssetId > 0 then
		textureId = toTextureId(override.flagAssetId)
	elseif override.iso2 and byId[override.iso2] then
		textureId = byId[override.iso2].textureId
	end

	local entry: Types.NationEntry = {
		id = code,
		displayName = override.name,
		textureId = textureId,
		iso2 = override.iso2,
		inPassportAssets = true,
	}
	byId[code] = entry
	if textureId ~= "" then
		textureToId[normalizeTextureKey(textureId)] = code
		if override.iso2 == nil then
			listedCustoms[code] = true
		elseif byId[override.iso2] then
			byId[override.iso2].inPassportAssets = true
		end
	elseif override.iso2 and byId[override.iso2] then
		byId[override.iso2].inPassportAssets = true
	end
end

-- Place-known texture overrides from FlagHall named poles
local placeOverrides: { [string]: { name: string, assetId: number } } = {
	CL = { name = "Chile", assetId = 18997002450 },
	CH = { name = "Switzerland", assetId = 10030877286 },
	XK = { name = "Kosovo", assetId = 16876086640 },
}

for iso2, info in placeOverrides do
	local existing = byId[iso2]
	addNation({
		id = iso2,
		displayName = if existing then existing.displayName else info.name,
		textureId = toTextureId(info.assetId),
		iso2 = iso2,
		inPassportAssets = if existing then existing.inPassportAssets else false,
	})
end

for id, entry in byId do
	if entry.textureId == "" then
		continue
	end
	local isIso2 = entry.iso2 == id or (#id == 2 and entry.iso2 == nil)
	local isCustomListed = listedCustoms[id] == true
	if isIso2 or isCustomListed then
		table.insert(ordered, entry)
	end
end

table.sort(ordered, function(a, b)
	if a.inPassportAssets ~= b.inPassportAssets then
		return a.inPassportAssets
	end
	return string.lower(a.displayName) < string.lower(b.displayName)
end)

--[=[
	Looks up a nation by id (ISO2, ISO3 alias, or custom code).

	@within Nations
	@param id string
	@return Types.NationEntry?
]=]
function Nations.get(id: string): Types.NationEntry?
	return byId[id]
end

--[=[
	Reverse-lookup by MeshPart TextureID / asset digits.

	@within Nations
	@param textureId string
	@return Types.NationEntry?
]=]
function Nations.getByTexture(textureId: string): Types.NationEntry?
	local id = textureToId[normalizeTextureKey(textureId)]
	return if id then byId[id] else nil
end

--[=[
	Ordered list for the picker (passport nations first, then A–Z).

	@within Nations
	@return {Types.NationEntry}
]=]
function Nations.list(): { Types.NationEntry }
	return ordered
end

--[=[
	Case-insensitive filter on display name and codes.

	@within Nations
	@param query string
	@return {Types.NationEntry}
]=]
function Nations.search(query: string): { Types.NationEntry }
	local q = string.lower(query)
	if q == "" then
		return ordered
	end

	local results = {}
	for _, entry in ordered do
		if
			string.find(string.lower(entry.displayName), q, 1, true)
			or string.find(string.lower(entry.id), q, 1, true)
			or (entry.iso2 ~= nil and string.find(string.lower(entry.iso2), q, 1, true))
		then
			table.insert(results, entry)
		end
	end
	return results
end

return Nations
