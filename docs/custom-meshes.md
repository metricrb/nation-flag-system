---
sidebar_position: 5
---

# Custom mesh flag integration

Nation Flag System swaps nations by setting **`MeshPart.TextureID`**. Custom draped / hanging flag meshes work as long as the cloth surface is a `MeshPart` and its UVs expect a rectangular flag image.

If you use `SurfaceAppearance`, Decals, or Texture instances instead, this path will not drive them — stick to `TextureID` on the mesh.

## What the registry looks for

Each pole is a **`Model`**. [`FlagRegistry`](/api/FlagRegistry) picks one `MeshPart` inside it:

1. Prefer a descendant whose name contains **`flag`** (case-insensitive), e.g. `Meshes/flagpiece (1)`
2. Else the first `MeshPart` that already has a non-empty `TextureID`
3. Else the first `MeshPart` in the model

A `ProximityPrompt` named `FlagChangePrompt` is parented to that mesh.

## Model layout

```text
Workspace.Flags                -- or Config.FlagFolderPath
└── MyDelegatePole (Model)     -- optional: CollectionService tag CustomizableFlag
    ├── Pole (Part)            -- geometry only; ignored for textures
    └── Meshes/flagpiece (1) (MeshPart)   -- TextureID is swapped here
```

Outside the flags folder, tag the Model `CustomizableFlag` (see `Config.CollectionTag`).

## TextureID requirements

When a nation is applied, the server writes roughly:

```lua
mesh.TextureID = "http://www.roblox.com/asset/?id=" .. assetId
```

So:

| Requirement | Why |
| --- | --- |
| Target is a **`MeshPart`** | Only `TextureID` is updated |
| No **`SurfaceAppearance`** on that mesh | SurfaceAppearance overrides / ignores `TextureID` |
| Mesh UVs map a **full rectangle** across the cloth | Catalog flags are rectangular images |
| Asset is a Roblox **Image** (AssetType Image) | Same as typical flag decals / textures |

You can seed a default look by setting `TextureID` in Studio before play; the prompt ObjectText will reverse-match known catalog textures when possible.

## UV tips for custom cloth meshes

- Author UVs so the **entire flag face** uses `0–1` UV space (one nation image fills the cloth).
- Avoid packing pole/hardware into the same UV island as the flag — those pixels will show flag colors when swapped.
- Square vs wide flags: most catalog assets are wider than tall; hanging meshes that compress horizontally still work, but emblems may look squeezed.
- Double-sided cloth: one `MeshPart` with both sides sharing UVs is fine; two meshes need both named with `flag` or only one will update.

## Checklist

1. Build or import your flag as a **`MeshPart`**
2. Put it under a **`Model`** (pole + flag)
3. Name the cloth mesh with **`flag`** in the name
4. Parent the Model under `Workspace.Flags` **or** tag `CustomizableFlag`
5. Confirm there is **no** `SurfaceAppearance` on the cloth mesh
6. Play, use the prompt, pick a nation — `TextureID` should change on the mesh

## Verifying in Studio

Select the cloth `MeshPart` after a successful change:

- `TextureID` should contain the new asset id
- Model attribute `CurrentNation` should be the nation id (e.g. `US`, `UNO`)
- Prompt `ObjectText` should show the nation display name

If the prompt works but the mesh does not visually update, almost always: wrong mesh selected, `SurfaceAppearance` present, or UVs not on the visible cloth.
