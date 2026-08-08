# Nation Flag System

[![release](https://github.com/metricrb/nation-flag-system/actions/workflows/release.yml/badge.svg)](https://github.com/metricrb/nation-flag-system/actions/workflows/release.yml)
[![publish-docs](https://github.com/metricrb/nation-flag-system/actions/workflows/publish-docs.yml/badge.svg)](https://github.com/metricrb/nation-flag-system/actions/workflows/publish-docs.yml)

ProximityPrompt + searchable ScreenGui for setting flag-hall poles to any nation.

Docs are built with [Moonwave](https://eryn.io/moonwave/) — see [`docs/`](docs/intro.md) and run `moonwave dev`.

## Features

- **Auth**: global or per-pole `Group` / `Team` / `Either` / `Anyone`
- **Nations**: ~250 world flags + every [passport-system](https://github.com/metricrb/passport-system) asset nation
- **Picker**: searchable list (passport nations sorted first)

## Setup

### From GitHub Releases (recommended)

1. Open the latest release and download **`nation-flag-system.rbxm`**.
2. In Studio, drag it into the viewport (or **Insert from File**).
3. Move the folder contents into your place:

| From the release Folder | Move into |
| --- | --- |
| `ReplicatedStorage.NationFlagSystem` | `ReplicatedStorage` |
| `ServerScriptService.NationFlagSystem` | `ServerScriptService` |
| `StarterPlayerScripts.NationFlagSystem` | `StarterPlayer.StarterPlayerScripts` |

4. Edit `Config`, then play. Poles under `Workspace.Flags` (or `Config.FlagFolderPath`) are auto-wired.

Tagged releases (`v*`) publish this `.rbxm` via CI (`rojo build release.project.json`).

### From source (Rojo)

```bash
git clone https://github.com/metricrb/nation-flag-system.git
cd nation-flag-system
aftman install
rojo serve default.project.json
```

Build the release model locally:

```bash
rojo build release.project.json --output nation-flag-system.rbxm
```

### Per-pole attributes

| Attribute | Description |
|---|---|
| `AuthMode` | `Group`, `Team`, `Either`, `Anyone` |
| `GroupId` | Roblox group id |
| `MinGroupRank` | Minimum group rank |
| `TeamName` | Exact team name |

## Config defaults

- `AuthMode = "Either"`
- `TeamName = "Staff"`
- `GroupId = 0` (disabled until set)

## Documentation

```bash
npm i -g moonwave@latest
moonwave dev          # local preview
moonwave build        # static site
moonwave build --publish  # GitHub Pages
```

Guides live in [`docs/`](docs/intro.md). API reference is generated from Moonwave comments in `src/`.
