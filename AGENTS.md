# AGENTS.md - DMS Web Search

## Project Overview
A DankMaterialShell (DMS) launcher plugin for searching the web with 23+ built-in search engines and support for custom search engines, including integration with 13,000+ DuckDuckGo !bangs.

**Language**: QML (Qt Modeling Language)
**Type**: Launcher plugin for DankMaterialShell
**Default Trigger**: `@`
**Version**: 1.4.0

## Recent Maintenance Notes (2026-03-17)
- Added DuckDuckGo !bang functionality (#14).
- Implemented `DDGBangWorker.js` for off-thread bang filtering to maintain UI performance.
- Added `DDGSyncHelper.js` for fetching and local caching of the 13k+ DDG bang database.
- Integrated sync UI and status in `WebSearchSettings.qml`.
- Added fallback logic in `WebSearch.qml` to handle `!` prefixed queries.

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│  Built-in Search Engines                            │
│  Defined in SearchEngines.qml                       │
│  23+ engines with keywords and URL templates        │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  DuckDuckGo !Bangs (Optional Sync)                  │
│  - Synced from duckduckgo.com/bang.js               │
│  - Cached locally in plugin data                    │
│  - Filtered off-thread via DDGBangWorker.js         │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  User Settings (Persistent Storage)                 │
│  - Custom search engines                            │
│  - Default engine preference                        │
│  - Trigger configuration                            │
│  - Synced DDG bangs and last sync timestamp         │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  Query Processing                                    │
│  1. Check for '!' prefix (DDG Bangs)                │
│  2. Check for keyword prefix (e.g., "github rust")  │
│  3. Match to specific engine or use default         │
│  4. Generate search URL with encoded query          │
│  5. Launch in browser via xdg-open                  │
└─────────────────────────────────────────────────────┘
```

## File Structure

### Core Files
- **plugin.json** - Plugin metadata, version, trigger, capabilities
- **WebSearch.qml** - Main component (~400 lines)
  - Core search orchestration
  - Integrated `WorkerScript` for DDG bangs
  - Browser launching logic
- **WebSearchSettings.qml** - Settings UI (~950 lines)
  - Management of engines and trigger
  - DDG Bang sync control
- **SearchEngines.qml** - Built-in engine definitions
- **DDGBangWorker.js** - Off-thread logic for filtering 13k+ bangs
- **DDGSyncHelper.js** - Utility for fetching and optimizing DDG bang JSON

## Key Concepts

### Search Engine Structure
Each search engine is defined as a JavaScript object:

```javascript
{
    id: "google",                              // Unique identifier
    name: "Google",                            // Display name
    icon: "material:travel_explore",           // Icon (material: or unicode:)
    url: "https://www.google.com/search?q=%s", // URL template with %s placeholder
    keywords: ["google", "search"]             // Keywords for quick access
}
```

### DuckDuckGo !Bangs
Bangs are handled as a fallback mechanism:
1. User types query starting with `!`.
2. `WebSearch.qml` sends trigger part to `DDGBangWorker.js`.
3. Worker filters cached bangs (prioritizing exact matches and prefix matches).
4. Suggestions are returned to the UI.
5. Search execution bypasses DDG redirects by using the direct URL template.

### Keyword Matching
The plugin supports keyword-based engine selection:
1. User types: `@ github rust async`
2. Plugin detects "github" keyword at start
3. Matches to GitHub engine
4. Searches for "rust async" on GitHub

If no keyword matches and it's not a `!` query, the default engine is used.

## Development Workflow

### 1. Adding Built-in Search Engines

**Location**: `SearchEngines.qml`

Add new engine to `engines` array:

```qml
{
    id: "rustdoc",
    name: "Rust Documentation",
    icon: "unicode:🦀",
    url: "https://doc.rust-lang.org/std/?search=%s",
    keywords: ["rust", "docs", "documentation"]
}
```

### 2. Modifying Bang Logic

**Location**: `DDGBangWorker.js`

The worker handles the heavy lifting of searching 13,000+ items. Filtering should always prioritize:
1. Exact trigger matches (`trigger === query`)
2. Prefix matches (`trigger.startsWith(query)`)
3. Name matches (`name.includes(query)`)

### 3. Testing Changes

**Testing checklist**:
- [ ] Sync DDG bangs successfully in Settings
- [ ] `!` queries provide relevant suggestions instantly
- [ ] Keyword matching works (e.g., `@ github test`)
- [ ] Default engine used when no keyword/bang
- [ ] Browser launches successfully with correct URL

## Important QML Details

### WorkerScript Integration
In `WebSearch.qml`, the worker must be assigned to a property to avoid `QtObject` child assignment errors:

```qml
property WorkerScript bangWorker: WorkerScript {
    source: "DDGBangWorker.js"
    onMessage: (message) => { ... }
}
```

### Settings Persistence
Settings include the massive `ddgBangs` array. Ensure `PluginService` can handle the data size (optimized in `DDGSyncHelper.js` by stripping unused fields).

## Troubleshooting

### Bangs not showing
1. Verify "Last Sync" in Settings is not "Never".
2. Check if query starts with `!` (the trigger for bangs).
3. Ensure `DDGBangWorker.js` is correctly linked/available.

### Slow UI during search
If the UI stutters while typing `!`, check that `DDGBangWorker.js` is actually running off-thread and not being called synchronously somehow.

## Version Bumping

**Location**: `plugin.json` line 5

- **1.4.0**: Added DDG Bangs integration.

## Author

**Maintainer**: devnullvoid
**Last Updated**: 2026-03-17
**AI-Friendly**: This document helps AI agents quickly understand the hybrid architecture of static engines + off-thread filtered dynamic bangs.
