---
sidebar_position: 6
---

# Documentation (Moonwave)

API pages are generated from Moonwave comments in `src/`.

## Local preview

```bash
npm i -g moonwave@latest
moonwave dev
```

## Build

```bash
moonwave build
```

## Publish to GitHub Pages

```bash
moonwave build --publish
```

Or push to `main` with [`.github/workflows/publish-docs.yml`](https://github.com/metricrb/nation-flag-system/blob/main/.github/workflows/publish-docs.yml) enabled and GitHub Pages set to **GitHub Actions**.

## Writing API docs

Use Moonwave tags in Luau sources:

```lua
--[=[
	@class MyModule
	Short description.
]=]

--[=[
	Resolves something.

	@within MyModule
	@param name string
	@return boolean
]=]
function MyModule.doThing(name: string): boolean
```

See the [Moonwave docs](https://eryn.io/moonwave/).
