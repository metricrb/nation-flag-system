---
sidebar_position: 2
---

# Installation

## From GitHub Releases (recommended)

1. Open the latest release and download **`nation-flag-system.rbxm`**.
2. In Studio, drag it into the viewport (or **Insert from File**).
3. Move contents into your place:

| From the release Folder | Move into |
| --- | --- |
| `ReplicatedStorage.NationFlagSystem` | `ReplicatedStorage` |
| `ServerScriptService.NationFlagSystem` | `ServerScriptService` |
| `StarterPlayerScripts.NationFlagSystem` | `StarterPlayer.StarterPlayerScripts` |

Tagged releases (`v*`) build this model with `rojo build release.project.json`.

## From source (Rojo)

```bash
git clone https://github.com/metricrb/nation-flag-system.git
cd nation-flag-system
aftman install
rojo serve default.project.json
```

Connect the Rojo plugin in Studio. Trees sync to:

| Source | Studio |
| --- | --- |
| `src/ReplicatedStorage/NationFlagSystem` | `ReplicatedStorage.NationFlagSystem` |
| `src/ServerScriptService/NationFlagSystem` | `ServerScriptService.NationFlagSystem` |
| `src/StarterPlayerScripts/NationFlagSystem` | `StarterPlayer.StarterPlayerScripts.NationFlagSystem` |

Local release build:

```bash
rojo build release.project.json --output nation-flag-system.rbxm
```

## Place requirements

1. Flag poles live under `Workspace.Flags` (or change `Config.FlagFolderPath`).
2. Each pole is a `Model` with a flag `MeshPart` (name containing `flag` preferred).
3. Optional: tag extra poles with CollectionService tag `CustomizableFlag`.
4. Edit [`Config`](/api/Config) for auth defaults.
5. Create a Team named `Staff` (or change `Config.TeamName`) if using Team / Either mode.

Custom draped meshes: see [Custom mesh flag integration](./custom-meshes) (`TextureID` only).

`FlagService` starts automatically as a Script under `ServerScriptService.NationFlagSystem`.
