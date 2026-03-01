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

    signal itemsChanged

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

        // Use _preScored to ensure DMS preserves our item ordering
        // Higher _preScored = appears first in results (DMS Scorer.js respects this)
        // This requires DMS fix: ItemTransformers.js must preserve _preScored
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
