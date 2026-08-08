---
sidebar_position: 4
---

# Authorization

Resolved by [`FlagAuth`](/api/FlagAuth) from pole attributes, falling back to [`Config`](/api/Config).

## Modes

| Mode | Allowed when |
| --- | --- |
| `Group` | Player rank in `GroupId` ≥ `MinGroupRank` |
| `Team` | `player.Team.Name == TeamName` |
| `Either` | Group **or** Team passes |
| `Anyone` | Always (useful for testing) |

With default `Either` + `GroupId = 0`, only the Team check can succeed until you set a group id.

## Flow

1. Player triggers the pole `ProximityPrompt`
2. Server checks `FlagAuth.isAuthorized`
3. Denied → `Notify` toast with `Config.DenyMessage`
4. Allowed → `OpenPicker` with `poleId`
5. Client selects a nation → `RequestSetNation`
6. Server re-checks auth and applies `TextureID`
