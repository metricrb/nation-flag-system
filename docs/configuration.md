---
sidebar_position: 3
---

# Configuration

Global defaults live in [`Config`](/api/Config).

| Key | Default | Meaning |
| --- | --- | --- |
| `AuthMode` | `"Either"` | `Group`, `Team`, `Either`, or `Anyone` |
| `GroupId` | `0` | Roblox group id (`0` = group check disabled) |
| `MinGroupRank` | `1` | Minimum rank in that group |
| `TeamName` | `"Staff"` | Exact `Team.Name` |
| `FlagFolderPath` | `"Workspace.Flags"` | Dot path from `game` |
| `CollectionTag` | `"CustomizableFlag"` | Extra poles via CollectionService |
| `PromptActionText` | `"Change Flag"` | ProximityPrompt action text |
| `PromptMaxDistance` | `10` | Activation distance |
| `PromptHoldDuration` | `0` | Hold time (seconds) |
| `DenyMessage` | *(see Config)* | Client toast when unauthorized |

## Per-pole overrides

Set attributes on the pole `Model`:

| Attribute | Type | Description |
| --- | --- | --- |
| `AuthMode` | string | Same values as Config |
| `GroupId` | number | `0` falls back to Config |
| `MinGroupRank` | number | Minimum group rank |
| `TeamName` | string | Empty falls back to Config |
| `PoleId` | string | Stable id (auto-assigned GUID) |
| `CurrentNation` | string | Last applied nation id |

## Nations / textures

- [`WorldFlags`](/api/WorldFlags) — ISO2 → `{ name, flagAssetId }` catalog
- [`PassportExtras`](/api/PassportExtras) — passport-system codes, ISO3→ISO2 map, overrides (e.g. `UNO`)
- [`Nations`](/api/Nations) — merged API used by server and picker

Override a texture by editing `PassportExtras.Overrides` or the place-known entries inside `Nations`.
