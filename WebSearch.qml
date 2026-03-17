import QtQuick
import Quickshell
import qs.Services

QtObject {
    id: root

    property var pluginService: null
    property string trigger: "@"
    property var searchEngines: []
    property string defaultEngine: "google"
    property var disabledEngines: []
    property var ddgBangs: []
    property var cachedDdgBangs: []
    property string lastBangQuery: ""

    signal itemsChanged

    property WorkerScript bangWorker: WorkerScript {
        source: "DDGBangWorker.js"
        onMessage: (message) => {
            if (message.results) {
                root.ddgBangs = message.results;
                root.itemsChanged();
            }
        }
    }

    property var builtInEngines: {
        const enginesComponent = Qt.createComponent("SearchEngines.qml");
        if (enginesComponent.status === Component.Ready) {
            const enginesObj = enginesComponent.createObject(root);
            return enginesObj.engines;
        }
        return [];
    }

    Component.onCompleted: loadSettings()

    onPluginServiceChanged: {
        if (pluginService)
            loadSettings();
    }

    function loadSettings() {
        if (!pluginService)
            return;
        trigger = pluginService.loadPluginData("webSearch", "trigger", "@");
        defaultEngine = pluginService.loadPluginData("webSearch", "defaultEngine", "google");
        searchEngines = pluginService.loadPluginData("webSearch", "searchEngines", []);
        disabledEngines = normalizeIdList(pluginService.loadPluginData("webSearch", "disabledEngines", []));
        cachedDdgBangs = pluginService.loadPluginData("webSearch", "ddgBangs", []);
    }

    function normalizeIdList(value) {
        if (Array.isArray(value))
            return value.slice();
        if (value === null || value === undefined)
            return [];
        if (typeof value === "string")
            return value.length > 0 ? [value] : [];
        if (typeof value.length === "number") {
            const out = [];
            for (let i = 0; i < value.length; i++) {
                out.push(value[i]);
            }
            return out;
        }
        return [];
    }

    function getItems(query) {
        const items = [];
        const disabled = normalizeIdList(disabledEngines);
        const allEngines = builtInEngines.concat(searchEngines).filter(e => disabled.indexOf(e.id) === -1);
        const keywordMatchEngines = searchEngines.concat(builtInEngines).filter(e => disabled.indexOf(e.id) === -1);

        if (!query || query.trim().length === 0) {
            for (let i = 0; i < allEngines.length; i++) {
                const engine = allEngines[i];
                items.push({
                    name: engine.name,
                    icon: engine.icon || "unicode:🔍",
                    comment: engine.keywords ? engine.keywords.join(", ") : "Search engine",
                    action: "noop",
                    categories: ["Web Search"]
                });
            }

            return items;
        }

        let matchedEngineId = null;
        let searchQuery = query.trim();
        let fallbackQuery = query.trim();
        let exactMatchedEngineIds = [];
        let prefixMatchedEngineIds = [];

        // Check if query starts with '!' for DDG Bangs
        if (fallbackQuery.startsWith("!") && cachedDdgBangs.length > 0) {
            const firstSpace = fallbackQuery.indexOf(" ");
            const bangPart = firstSpace === -1 ? fallbackQuery.substring(1) : fallbackQuery.substring(1, firstSpace);
            const bangQuery = firstSpace === -1 ? "" : fallbackQuery.substring(firstSpace + 1).trim();

            if (bangPart !== lastBangQuery) {
                lastBangQuery = bangPart;
                bangWorker.sendMessage({ query: bangPart, bangs: cachedDdgBangs });
            }

            // If we have suggestions from last message, show them
            if (ddgBangs.length > 0) {
                for (let i = 0; i < ddgBangs.length; i++) {
                    const bang = ddgBangs[i];
                    items.push({
                        name: "Search " + bang.name + " (" + bang.trigger + "): " + (bangQuery || "..."),
                        icon: "material:search",
                        comment: "DuckDuckGo Bang",
                        action: "bangSearch:" + bang.trigger + ":" + bangQuery,
                        categories: ["Web Search"],
                        _preScored: 10000 - i
                    });
                }
                return items;
            }
        }

        const firstSpaceIndex = fallbackQuery.indexOf(" ");
        if (firstSpaceIndex > 0) {
            const keywordToken = fallbackQuery.substring(0, firstSpaceIndex).toLowerCase();

            for (let i = 0; i < keywordMatchEngines.length; i++) {
                const engine = keywordMatchEngines[i];
                if (!Array.isArray(engine.keywords))
                    continue;

                let hasExactMatch = false;
                let hasPrefixMatch = false;
                for (let k = 0; k < engine.keywords.length; k++) {
                    const keyword = String(engine.keywords[k]).toLowerCase();
                    if (keyword === keywordToken) {
                        hasExactMatch = true;
                        break;
                    }
                    if (keyword.startsWith(keywordToken))
                        hasPrefixMatch = true;
                }

                if (hasExactMatch) {
                    exactMatchedEngineIds.push(engine.id);
                } else if (hasPrefixMatch) {
                    prefixMatchedEngineIds.push(engine.id);
                }
            }

            if (exactMatchedEngineIds.length > 0) {
                matchedEngineId = exactMatchedEngineIds[0];
                searchQuery = fallbackQuery.substring(firstSpaceIndex + 1).trim();
            }
        }

        const promotedEngineIds = exactMatchedEngineIds.concat(prefixMatchedEngineIds);
        const promotedEngineIdSet = {};
        for (let i = 0; i < promotedEngineIds.length; i++) {
            promotedEngineIdSet[promotedEngineIds[i]] = true;
        }

        const primaryEngineId = matchedEngineId || defaultEngine;
        const primaryEngineObj = allEngines.find(e => e.id === primaryEngineId);

        const PRIMARY_SCORE = 10000;
        const SECONDARY_SCORE = 1000;

        if (primaryEngineObj) {
            items.push({
                name: "Search with " + primaryEngineObj.name + ": " + searchQuery,
                icon: primaryEngineObj.icon || "unicode:🔍",
                comment: "Press Enter to search",
                action: "search:" + primaryEngineId + ":" + searchQuery,
                categories: ["Web Search"],
                _preScored: PRIMARY_SCORE
            });
        }

        const allEngineIdSet = {};
        for (let i = 0; i < allEngines.length; i++) {
            allEngineIdSet[allEngines[i].id] = true;
        }

        const secondaryEngines = [];
        const secondarySeen = {};
        for (let i = 0; i < keywordMatchEngines.length; i++) {
            const engine = keywordMatchEngines[i];
            if (engine.id === primaryEngineId)
                continue;
            if (!allEngineIdSet[engine.id])
                continue;
            if (!promotedEngineIdSet[engine.id])
                continue;
            if (secondarySeen[engine.id])
                continue;
            secondarySeen[engine.id] = true;
            secondaryEngines.push(engine);
        }

        for (let i = 0; i < allEngines.length; i++) {
            const engine = allEngines[i];
            if (engine.id === primaryEngineId)
                continue;
            if (promotedEngineIdSet[engine.id])
                continue;
            secondaryEngines.push(engine);
        }

        let secondaryIndex = 0;
        for (let i = 0; i < secondaryEngines.length; i++) {
            const engine = secondaryEngines[i];
            const usePromotedQuery = !!promotedEngineIdSet[engine.id];
            const engineQuery = matchedEngineId ? (usePromotedQuery ? searchQuery : fallbackQuery) : searchQuery;
            items.push({
                name: "Search with " + engine.name + ": " + engineQuery,
                icon: engine.icon || "material:search",
                comment: "Open in browser",
                action: "search:" + engine.id + ":" + engineQuery,
                categories: ["Web Search"],
                _preScored: SECONDARY_SCORE - secondaryIndex
            });
            secondaryIndex++;
        }

        return items;
    }

    function executeItem(item) {
        if (!item?.action)
            return;
        const actionParts = item.action.split(":");
        const actionType = actionParts[0];

        switch (actionType) {
        case "noop":
            return;
        case "search":
            performSearch(actionParts);
            break;
        case "bangSearch":
            performBangSearch(actionParts);
            break;
        default:
            showToast("Unknown action: " + actionType);
        }
    }

    function performSearch(actionParts) {
        const engineId = actionParts[1];
        const query = actionParts.slice(2).join(":");

        const allEngines = builtInEngines.concat(searchEngines);
        const engine = allEngines.find(e => e.id === engineId);

        if (!engine) {
            showToast("Search engine not found: " + engineId);
            return;
        }

        const encodedQuery = encodeQuery(query);
        const url = engine.url.replace("%s", encodedQuery);

        Quickshell.execDetached(["xdg-open", url]);
        showToast("Searching " + engine.name + " for: " + query);
    }

    function performBangSearch(actionParts) {
        const triggerPart = actionParts[1];
        const query = actionParts.slice(2).join(":");

        const bang = cachedDdgBangs.find(b => b.t === triggerPart);
        if (!bang) {
            showToast("Bang not found: !" + triggerPart);
            return;
        }

        const encodedQuery = encodeQuery(query);
        const url = bang.u.replace("%s", encodedQuery);

        Quickshell.execDetached(["xdg-open", url]);
        showToast("Searching " + bang.s + " for: " + query);
    }

    function showToast(message) {
        if (typeof ToastService !== "undefined") {
            ToastService.showInfo("Web Search", message);
        }
    }

    function getEngineName(engineId) {
        const allEngines = builtInEngines.concat(searchEngines);
        const engine = allEngines.find(e => e.id === engineId);
        return engine ? engine.name : "Unknown";
    }

    function encodeQuery(str) {
        return str.replace(/ /g, "+");
    }

    onTriggerChanged: {
        if (!pluginService)
            return;
        pluginService.savePluginData("webSearch", "trigger", trigger);
        itemsChanged();
    }

    onDefaultEngineChanged: {
        if (!pluginService)
            return;
        pluginService.savePluginData("webSearch", "defaultEngine", defaultEngine);
        itemsChanged();
    }

    onSearchEnginesChanged: {
        if (!pluginService)
            return;
        pluginService.savePluginData("webSearch", "searchEngines", searchEngines);
        itemsChanged();
    }

    onDisabledEnginesChanged: {
        if (!pluginService)
            return;
        pluginService.savePluginData("webSearch", "disabledEngines", normalizeIdList(disabledEngines));
        itemsChanged();
    }
}
