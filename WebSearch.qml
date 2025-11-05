import QtQuick
import Quickshell
import qs.Services

Item {
    id: root

    property var pluginService: null
    property string trigger: "?"
    property var searchEngines: []
    property string defaultEngine: "google"

    signal itemsChanged()

    property var builtInEngines: [
        {
            id: "google",
            name: "Google",
            icon: "material:travel_explore",
            url: "https://www.google.com/search?q=%s",
            keywords: ["google", "search"]
        },
        {
            id: "duckduckgo",
            name: "DuckDuckGo",
            icon: "material:shield",
            url: "https://duckduckgo.com/?q=%s",
            keywords: ["ddg", "duckduckgo", "privacy"]
        },
        {
            id: "brave",
            name: "Brave Search",
            icon: "material:security",
            url: "https://search.brave.com/search?q=%s",
            keywords: ["brave", "privacy"]
        },
        {
            id: "bing",
            name: "Bing",
            icon: "material:language",
            url: "https://www.bing.com/search?q=%s",
            keywords: ["bing", "microsoft"]
        },
        {
            id: "youtube",
            name: "YouTube",
            icon: "material:youtube_activity",
            url: "https://www.youtube.com/results?search_query=%s",
            keywords: ["youtube", "video", "yt"]
        },
        {
            id: "github",
            name: "GitHub",
            icon: "unicode:",
            url: "https://github.com/search?q=%s",
            keywords: ["github", "code", "git"]
        },
        {
            id: "stackoverflow",
            name: "Stack Overflow",
            icon: "unicode:",
            url: "https://stackoverflow.com/search?q=%s",
            keywords: ["stackoverflow", "stack", "coding"]
        },
        {
            id: "reddit",
            name: "Reddit",
            icon: "unicode:",
            url: "https://www.reddit.com/search?q=%s",
            keywords: ["reddit"]
        },
        {
            id: "wikipedia",
            name: "Wikipedia",
            icon: "material:menu_book",
            url: "https://en.wikipedia.org/wiki/Special:Search?search=%s",
            keywords: ["wikipedia", "wiki"]
        },
        {
            id: "amazon",
            name: "Amazon",
            icon: "material:shopping_cart",
            url: "https://www.amazon.com/s?k=%s",
            keywords: ["amazon", "shop", "shopping"]
        },
        {
            id: "ebay",
            name: "eBay",
            icon: "material:local_mall",
            url: "https://www.ebay.com/sch/i.html?_nkw=%s",
            keywords: ["ebay", "shop", "auction"]
        },
        {
            id: "maps",
            name: "Google Maps",
            icon: "material:map",
            url: "https://www.google.com/maps/search/%s",
            keywords: ["maps", "location", "directions"]
        },
        {
            id: "images",
            name: "Google Images",
            icon: "material:photo_library",
            url: "https://www.google.com/search?tbm=isch&q=%s",
            keywords: ["images", "pictures", "photos"]
        },
        {
            id: "twitter",
            name: "Twitter/X",
            icon: "unicode:",
            url: "https://twitter.com/search?q=%s",
            keywords: ["twitter", "x", "social"]
        },
        {
            id: "linkedin",
            name: "LinkedIn",
            icon: "unicode:",
            url: "https://www.linkedin.com/search/results/all/?keywords=%s",
            keywords: ["linkedin", "job", "professional"]
        },
        {
            id: "imdb",
            name: "IMDb",
            icon: "unicode:",
            url: "https://www.imdb.com/find?q=%s",
            keywords: ["imdb", "movies", "tv"]
        },
        {
            id: "translate",
            name: "Google Translate",
            icon: "material:g_translate",
            url: "https://translate.google.com/?text=%s",
            keywords: ["translate", "translation"]
        },
        {
            id: "archlinux",
            name: "Arch Linux Wiki",
            icon: "material:terminal",
            url: "https://wiki.archlinux.org/index.php?search=%s",
            keywords: ["arch", "linux", "packages"]
        },
        {
            id: "aur",
            name: "AUR",
            icon: "unicode:",
            url: "https://aur.archlinux.org/packages?K=%s",
            keywords: ["aur", "arch", "packages"]
        },
        {
            id: "npmjs",
            name: "npm",
            icon: "unicode:",
            url: "https://www.npmjs.com/search?q=%s",
            keywords: ["npm", "node", "javascript"]
        },
        {
            id: "pypi",
            name: "PyPI",
            icon: "unicode:",
            url: "https://pypi.org/search/?q=%s",
            keywords: ["pypi", "python", "pip"]
        },
        {
            id: "crates",
            name: "crates.io",
            icon: "material:inventory_2",
            url: "https://crates.io/search?q=%s",
            keywords: ["crates", "rust", "cargo"]
        },
        {
            id: "mdn",
            name: "MDN Web Docs",
            icon: "material:code_blocks",
            url: "https://developer.mozilla.org/en-US/search?q=%s",
            keywords: ["mdn", "mozilla", "web", "docs"]
        }
    ]

    Component.onCompleted: {
        loadSettings()
    }

    onPluginServiceChanged: {
        if (pluginService) {
            loadSettings()
        }
    }

    function loadSettings() {
        if (pluginService) {
            trigger = pluginService.loadPluginData("webSearch", "trigger", "?")
            defaultEngine = pluginService.loadPluginData("webSearch", "defaultEngine", "google")
            searchEngines = pluginService.loadPluginData("webSearch", "searchEngines", [])
        }
    }

    function getItems(query) {
        const items = []
        const allEngines = builtInEngines.concat(searchEngines)

        if (!query || query.trim().length === 0) {
            items.push({
                name: "Type a search query",
                icon: "unicode:🔍",
                comment: "Search the web with your default engine (" + getEngineName(defaultEngine) + ")",
                action: "noop",
                categories: ["Web Search"]
            })

            for (let i = 0; i < allEngines.length; i++) {
                const engine = allEngines[i]
                items.push({
                    name: engine.name,
                    icon: engine.icon || "unicode:🔍",
                    comment: engine.keywords ? engine.keywords.join(", ") : "Search engine",
                    action: "noop",
                    categories: ["Web Search"]
                })
            }

            return items
        }

        let matchedEngineId = null
        let searchQuery = query.trim()
        let fallbackQuery = query.trim()

        for (let i = 0; i < allEngines.length; i++) {
            const engine = allEngines[i]
            if (engine.keywords) {
                for (let k = 0; k < engine.keywords.length; k++) {
                    const keyword = engine.keywords[k]
                    if (searchQuery.toLowerCase().startsWith(keyword + " ")) {
                        matchedEngineId = engine.id
                        searchQuery = searchQuery.substring(keyword.length + 1).trim()
                        break
                    }
                }
                if (matchedEngineId) break
            }
        }

        const primaryEngineId = matchedEngineId || defaultEngine
        const primaryEngineObj = allEngines.find(e => e.id === primaryEngineId)

        if (primaryEngineObj) {
            items.push({
                name: "Search with " + primaryEngineObj.name + ": " + searchQuery,
                icon: primaryEngineObj.icon || "unicode:🔍",
                comment: "Open in browser",
                action: "search:" + primaryEngineId + ":" + searchQuery,
                categories: ["Web Search"]
            })
        }

        for (let i = 0; i < allEngines.length; i++) {
            const engine = allEngines[i]
            if (engine.id !== primaryEngineId) {
                items.push({
                    name: "Search with " + engine.name + ": " + (matchedEngineId ? fallbackQuery : searchQuery),
                    icon: engine.icon || "material:search",
                    comment: "Open in browser",
                    action: "search:" + engine.id + ":" + (matchedEngineId ? fallbackQuery : searchQuery),
                    categories: ["Web Search"]
                })
            }
        }

        return items
    }

    function executeItem(item) {
        if (!item || !item.action) {
            console.warn("WebSearch: Invalid item or action")
            return
        }

        console.log("WebSearch: Executing item:", item.name, "with action:", item.action)

        const actionParts = item.action.split(":")
        const actionType = actionParts[0]

        switch (actionType) {
            case "noop":
                return
            case "search":
                performSearch(actionParts)
                break
            default:
                console.warn("WebSearch: Unknown action type:", actionType)
                showToast("Unknown action: " + actionType)
        }
    }

    function performSearch(actionParts) {
        const engineId = actionParts[1]
        const query = actionParts.slice(2).join(":")

        const allEngines = builtInEngines.concat(searchEngines)
        const engine = allEngines.find(e => e.id === engineId)

        if (engine) {
            const encodedQuery = encodeQuery(query)
            const url = engine.url.replace("%s", encodedQuery)

            Quickshell.execDetached(["xdg-open", url])
            showToast("Searching " + engine.name + " for: " + query)
        } else {
            console.warn("WebSearch: Engine not found:", engineId)
            showToast("Search engine not found: " + engineId)
        }
    }

    function showToast(message) {
        if (typeof ToastService !== "undefined") {
            ToastService.showInfo("Web Search", message)
        } else {
            console.log("WebSearch Toast:", message)
        }
    }

    function getEngineName(engineId) {
        const allEngines = builtInEngines.concat(searchEngines)
        const engine = allEngines.find(e => e.id === engineId)
        return engine ? engine.name : "Unknown"
    }

    function encodeQuery(str) {
        return str.replace(/ /g, "+")
    }

    onTriggerChanged: {
        if (pluginService) {
            pluginService.savePluginData("webSearch", "trigger", trigger)
        }
        itemsChanged()
    }

    onDefaultEngineChanged: {
        if (pluginService) {
            pluginService.savePluginData("webSearch", "defaultEngine", defaultEngine)
        }
        itemsChanged()
    }

    onSearchEnginesChanged: {
        if (pluginService) {
            pluginService.savePluginData("webSearch", "searchEngines", searchEngines)
        }
        itemsChanged()
    }
}
