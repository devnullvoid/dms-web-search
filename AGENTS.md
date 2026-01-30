# AGENTS.md - DMS Web Search

## Project Overview
A DankMaterialShell (DMS) launcher plugin for searching the web with 23+ built-in search engines and support for custom search engines.

**Language**: QML (Qt Modeling Language)
**Type**: Launcher plugin for DankMaterialShell
**Default Trigger**: `@`
**Version**: 1.2.2

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│  Built-in Search Engines                            │
│  Defined in WebSearch.qml                           │
│  23+ engines with keywords and URL templates        │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  User Settings (Persistent Storage)                 │
│  - Custom search engines                            │
│  - Default engine preference                        │
│  - Trigger configuration                            │
└─────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────┐
│  Query Processing                                    │
│  1. Check for keyword prefix (e.g., "github rust")  │
│  2. Match to specific engine or use default         │
│  3. Generate search URL with encoded query          │
│  4. Launch in browser via xdg-open                  │
└─────────────────────────────────────────────────────┘
```

## File Structure

### Core Files
- **plugin.json** - Plugin metadata, version, trigger, capabilities
- **WebSearch.qml** - Main component (~350 lines)
  - Built-in engine definitions
  - Query processing and keyword matching
  - Browser launching logic
- **WebSearchSettings.qml** - Settings UI (~700 lines)
  - Default engine selection
  - Custom engine management
  - Trigger configuration

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

### Engine Categories
Engines are organized by purpose:

**General Search**: Google, DuckDuckGo, Brave, Bing, Kagi
**Development**: GitHub, Stack Overflow, npm, PyPI, crates.io, MDN
**Linux**: Arch Wiki, AUR
**Social/Media**: YouTube, Reddit, Twitter, LinkedIn
**Reference**: Wikipedia, Google Translate, IMDb
**Shopping**: Amazon, eBay
**Utilities**: Google Maps, Google Images

### Keyword Matching
The plugin supports keyword-based engine selection:
1. User types: `@ github rust async`
2. Plugin detects "github" keyword at start
3. Matches to GitHub engine
4. Searches for "rust async" on GitHub

If no keyword matches, the default engine is used.

### URL Encoding
Queries are encoded using simple space-to-plus conversion:
```javascript
function encodeQuery(str) {
    return str.replace(/ /g, "+");
}
```

For complex encoding needs, this could be enhanced with `encodeURIComponent()`.

## Development Workflow

### 1. Adding Built-in Search Engines

**Location**: `WebSearch.qml` lines 15-184

Add new engine to `builtInEngines` array:

```qml
{
    id: "rustdoc",
    name: "Rust Documentation",
    icon: "unicode:🦀",
    url: "https://doc.rust-lang.org/std/?search=%s",
    keywords: ["rust", "docs", "documentation"]
}
```

**Important**:
- `id` must be unique
- `url` must contain `%s` placeholder
- `keywords` are optional but recommended
- Icons can be `material:icon_name` or `unicode:🔍`

### 2. Modifying Query Processing

**Location**: `WebSearch.qml` lines 201-275

The `getItems(query)` function:
1. Handles empty queries (shows all engines)
2. Matches keywords in query
3. Extracts search terms
4. Generates result items

**Key logic**:
```javascript
// Keyword matching (lines 232-246)
for (let i = 0; i < allEngines.length; i++) {
    const engine = allEngines[i];
    for (let k = 0; k < engine.keywords.length; k++) {
        const keyword = engine.keywords[k];
        if (searchQuery.toLowerCase().startsWith(keyword + " ")) {
            matchedEngineId = engine.id;
            searchQuery = searchQuery.substring(keyword.length + 1).trim();
            break;
        }
    }
}
```

### 3. Testing Changes

**After modifying WebSearch.qml:**
1. Save changes
2. Restart DMS
3. Test with `@ [query]` in launcher
4. Verify correct engine is selected
5. Verify browser opens with correct search

**Testing checklist**:
- [ ] Empty query shows all engines
- [ ] Keyword matching works (e.g., `@ github test`)
- [ ] Default engine used when no keyword
- [ ] URL encoding handles special characters
- [ ] Toast notifications appear
- [ ] Browser launches successfully

### 4. Custom Engines (User-Added)

Users can add custom engines via settings UI. These are stored in DMS settings and merged with built-in engines at runtime.

**Storage location**: DMS plugin settings (managed by pluginService)
**Settings keys**:
- `webSearch.searchEngines` - Array of custom engines
- `webSearch.defaultEngine` - Default engine ID
- `webSearch.trigger` - Trigger string

## Common Tasks

### Add a new built-in engine
1. Open `WebSearch.qml`
2. Add object to `builtInEngines` array (line ~184)
3. Include id, name, icon, url, keywords
4. Restart DMS
5. Test with keyword search

### Change default engine
1. Modify `defaultEngine` property (line 11)
2. Or let users configure via Settings UI

### Add new icon types
Icons support two formats:
- `material:icon_name` - Material Symbols
- `unicode:🔍` - Unicode emoji or Nerd Font glyphs

### Debug keyword matching
Add console logging in `getItems()`:
```javascript
console.log("Matched engine:", matchedEngineId);
console.log("Search query:", searchQuery);
```

## Important QML Details

### Settings Persistence
**Location**: Lines 193-199, 329-348

Settings are loaded/saved using `pluginService`:
```javascript
function loadSettings() {
    trigger = pluginService.loadPluginData("webSearch", "trigger", "@");
    defaultEngine = pluginService.loadPluginData("webSearch", "defaultEngine", "google");
    searchEngines = pluginService.loadPluginData("webSearch", "searchEngines", []);
}
```

Changes automatically save when properties change:
```javascript
onTriggerChanged: {
    pluginService.savePluginData("webSearch", "trigger", trigger);
}
```

### Browser Launch
**Location**: Lines 294-311

Uses Quickshell's `execDetached()` with `xdg-open`:
```javascript
Quickshell.execDetached(["xdg-open", url]);
```

This launches the user's default browser with the search URL.

### Toast Notifications
**Location**: Lines 313-317

Optional toast notifications via ToastService (if available):
```javascript
function showToast(message) {
    if (typeof ToastService !== "undefined") {
        ToastService.showInfo("Web Search", message);
    }
}
```

## Troubleshooting

### Searches not opening in browser
1. Verify `xdg-open` is installed: `which xdg-open`
2. Check default browser is set: `xdg-settings get default-web-browser`
3. Test manually: `xdg-open "https://google.com"`

### Keywords not matching
1. Verify keyword is in engine's `keywords` array
2. Check keyword is lowercase (matching is case-insensitive)
3. Ensure space after keyword: `github rust` (not `githubrust`)

### Custom engines not appearing
1. Check Settings UI saved the engine
2. Verify engine has required fields (id, name, url)
3. Restart DMS to reload settings

### URL encoding issues
For special characters (?, &, =), the current simple encoding may fail. Consider using:
```javascript
function encodeQuery(str) {
    return encodeURIComponent(str);
}
```

## Configuration

### plugin.json
- **id**: `webSearch`
- **trigger**: `@` (configurable by user)
- **type**: `launcher`
- **capabilities**: `["web-search", "custom-engines"]`

### Settings Storage Keys
- `webSearch.trigger` - Trigger character/string
- `webSearch.defaultEngine` - Default engine ID
- `webSearch.searchEngines` - Array of custom engines

## Version Bumping

**Location**: `plugin.json` line 5

**Versioning scheme**: Semantic versioning
- Patch (1.2.x): Bug fixes, icon updates
- Minor (1.x.0): New built-in engines, new features
- Major (x.0.0): Breaking changes, architecture changes

## Dependencies

**Runtime**:
- DankMaterialShell >= 0.1.0
- xdg-open (xdg-utils package)
- Web browser (any)
- Wayland compositor

**Build**: None (pure QML, no build process)

## Git Workflow

### Commit Message Format
Use conventional commits:
- `feat:` - New search engines, features
- `fix:` - Bug fixes, URL corrections
- `docs:` - Documentation only
- `style:` - Icon updates, formatting

### Example Commits
```bash
# Add new search engine
git commit -m "feat: add Perplexity AI search engine

Adds Perplexity AI with keywords 'perplexity', 'ai', 'chat'
for AI-powered web search."

# Fix URL encoding
git commit -m "fix: use encodeURIComponent for query encoding

Replaces simple space-to-plus conversion with proper URI
encoding to handle special characters correctly."
```

## Future Enhancement Ideas

- **Search suggestions** - Show autocomplete suggestions
- **Search history** - Track and reuse previous searches
- **Quick search** - Search without trigger using keywords
- **Regional engines** - Support regional variants (google.de, google.fr)
- **POST requests** - Support engines requiring POST instead of GET
- **Custom headers** - Add custom headers for API-based searches
- **Engine groups** - Organize engines into categories in UI

## Testing Checklist

- [ ] All built-in engines work
- [ ] Keyword matching accurate
- [ ] Default engine selection works
- [ ] Custom engines can be added/edited/deleted
- [ ] URL encoding handles special characters
- [ ] Browser launches successfully
- [ ] Toast notifications appear
- [ ] Settings persist across restarts
- [ ] Trigger configuration works

## Resources

- [DankMaterialShell](https://github.com/AvengeMedia/DankMaterialShell)
- [Plugin Registry](https://github.com/AvengeMedia/dms-plugin-registry)
- [Material Symbols](https://fonts.google.com/icons)
- [Search Engine URL Patterns](https://github.com/validcube/searx-instances)

---

**Last Updated**: 2026-01-30
**Maintainer**: devnullvoid
**AI-Friendly**: This document helps AI agents quickly understand and work with this plugin.
