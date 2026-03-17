// DDGBangWorker.js
WorkerScript.onMessage = function(message) {
    const query = message.query.toLowerCase();
    const bangs = message.bangs; // This will be the large array
    const limit = 10;
    
    if (!query) {
        WorkerScript.sendMessage({ results: [] });
        return;
    }

    const exactMatches = [];
    const prefixMatches = [];
    const otherMatches = [];

    for (let i = 0; i < bangs.length; i++) {
        const bang = bangs[i];
        const trigger = bang.t.toLowerCase();
        const name = bang.s.toLowerCase();

        if (trigger === query) {
            exactMatches.push({
                id: "ddg_" + bang.t,
                name: bang.s,
                url: bang.u,
                trigger: bang.t,
                icon: "material:search"
            });
        } else if (trigger.startsWith(query)) {
            prefixMatches.push({
                id: "ddg_" + bang.t,
                name: bang.s,
                url: bang.u,
                trigger: bang.t,
                icon: "material:search"
            });
        } else if (name.indexOf(query) !== -1) {
            otherMatches.push({
                id: "ddg_" + bang.t,
                name: bang.s,
                url: bang.u,
                trigger: bang.t,
                icon: "material:search"
            });
        }
    }

    // Sort: shorter triggers first for prefix matches
    prefixMatches.sort((a, b) => a.trigger.length - b.trigger.length);

    const allResults = exactMatches.concat(prefixMatches).concat(otherMatches);
    const results = allResults.slice(0, limit);

    WorkerScript.sendMessage({ results: results });
}
