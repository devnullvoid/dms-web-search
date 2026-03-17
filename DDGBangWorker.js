// DDGBangWorker.js
WorkerScript.onMessage = function(message) {
    const query = message.query.toLowerCase();
    const bangs = message.bangs; // This will be the large array
    const limit = 10;
    const results = [];

    if (!query) {
        WorkerScript.sendMessage({ results: [] });
        return;
    }

    for (let i = 0; i < bangs.length; i++) {
        const bang = bangs[i];
        // bang object structure from DDG: { t: "g", s: "Google", u: "https://www.google.com/search?q={{{s}}}" }
        if (bang.t.toLowerCase().startsWith(query) || bang.s.toLowerCase().indexOf(query) !== -1) {
            results.push({
                id: "ddg_" + bang.t,
                name: bang.s,
                url: bang.u.replace("{{{s}}}", "%s"),
                trigger: bang.t,
                icon: "material:search" // Generic icon for now
            });
            if (results.length >= limit) break;
        }
    }

    WorkerScript.sendMessage({ results: results });
}
