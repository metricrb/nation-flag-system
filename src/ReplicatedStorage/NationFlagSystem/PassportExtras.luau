--!strict

--[=[
	@class PassportExtras
	Passport-system nation codes, ISO3→ISO2 mapping, and non-ISO overrides.
	Source: [passport-system](https://github.com/metricrb/passport-system) `NationDefaults` + `assets/`.
]=]

--[=[
	Custom / missing-flag override entry.

	@interface PassportExtra
	@within PassportExtras
	.code string
	.flagAssetId number? — Roblox image id when set
	.iso2 string? — Map onto a WorldFlags row when possible
	.name string
]=]
export type PassportExtra = {
	code: string,
	name: string,
	flagAssetId: number?,
	iso2: string?,
}

local PassportExtras = {}

--[=[
	@prop Iso3ToIso2 {[string]: string}
	@within PassportExtras
	Maps passport ISO3 codes (e.g. `USA`) to WorldFlags ISO2 (`US`).
]=]
PassportExtras.Iso3ToIso2 = {
	AFG = "AF",
	ALB = "AL",
	ANT = "AQ",
	ARM = "AM",
	AUS = "AU",
	BEL = "BE",
	BIH = "BA",
	BLR = "BY",
	BMU = "BM",
	BRA = "BR",
	BRN = "BN",
	CAN = "CA",
	CHN = "CN",
	COL = "CO",
	DEU = "DE",
	DNK = "DK",
	ESP = "ES",
	EST = "EE",
	FIN = "FI",
	FJI = "FJ",
	FLK = "FK",
	FRA = "FR",
	GBR = "GB",
	GGY = "GG",
	GIB = "GI",
	GRC = "GR",
	HKG = "HK",
	IDN = "ID",
	IND = "IN",
	IRL = "IE",
	ISL = "IS",
	ISR = "IL",
	ITA = "IT",
	JEY = "JE",
	JOR = "JO",
	JPN = "JP",
	KOR = "KR",
	LAO = "LA",
	LBY = "LY",
	LTU = "LT",
	LUX = "LU",
	MAR = "MA",
	MEX = "MX",
	MKD = "MK",
	MLT = "MT",
	MMR = "MM",
	MNE = "ME",
	MNG = "MN",
	MYS = "MY",
	NLD = "NL",
	NOR = "NO",
	NZL = "NZ",
	PAN = "PA",
	PER = "PE",
	PHL = "PH",
	POL = "PL",
	PRK = "KP",
	PRT = "PT",
	ROU = "RO",
	RUS = "RU",
	SHN = "SH",
	SMR = "SM",
	SOM = "SO",
	SSD = "SS",
	SVN = "SI",
	SWE = "SE",
	SYR = "SY",
	THA = "TH",
	TKM = "TM",
	TWN = "TW",
	UKR = "UA",
	USA = "US",
	VAT = "VA",
	VNM = "VN",
	WSM = "WS",
	ZAF = "ZA",
} :: {[string]: string}

--[=[
	@prop PassportCodes {string}
	@within PassportExtras
	Union of codes from passport-system `assets/`, `src/assets/`, and `NationDefaults`.
]=]
PassportExtras.PassportCodes = {
	"AFG",
	"ALB",
	"ANT",
	"ARM",
	"AUS",
	"AZE",
	"BEL",
	"BIH",
	"BLR",
	"BMU",
	"BRA",
	"BRN",
	"CAN",
	"CHN",
	"COL",
	"DEU",
	"DNK",
	"ESP",
	"EST",
	"FIN",
	"FJI",
	"FLK",
	"FRA",
	"GBR",
	"GGY",
	"GIB",
	"GRC",
	"HKG",
	"IDN",
	"IND",
	"IRL",
	"ISL",
	"ISR",
	"ITA",
	"JEY",
	"JOR",
	"JPN",
	"KOR",
	"LAO",
	"LBY",
	"LTU",
	"LUX",
	"MAR",
	"MEX",
	"MKD",
	"MLT",
	"MMR",
	"MNE",
	"MNG",
	"MYS",
	"NLD",
	"NOR",
	"NZL",
	"PAN",
	"PER",
	"PHL",
	"POL",
	"PRK",
	"PRT",
	"PSM",
	"ROU",
	"RUS",
	"SHN",
	"SMR",
	"SOM",
	"SSD",
	"SVN",
	"SWE",
	"SYR",
	"THA",
	"TKM",
	"TWN",
	"UKR",
	"UNO",
	"USA",
	"VAT",
	"VNM",
	"WSM",
	"ZAF",
} :: {string}

--[=[
	@prop Overrides {[string]: PassportExtra}
	@within PassportExtras
	Custom nations (e.g. `UNO`) and extras that need an explicit texture or name.
]=]
PassportExtras.Overrides = {
	UNO = { code = "UNO", name = "United Nations", flagAssetId = 17265982049, iso2 = nil },
	PSM = { code = "PSM", name = "Philippines (Samahan)", flagAssetId = nil, iso2 = "PH" },
	AZE = { code = "AZE", name = "Artsakh", flagAssetId = nil, iso2 = nil },
	FLK = { code = "FLK", name = "Falkland Islands", flagAssetId = nil, iso2 = "FK" },
	ANT = { code = "ANT", name = "Antarctica", flagAssetId = 86502219446467, iso2 = "AQ" },
} :: {[string]: PassportExtra}

return PassportExtras
