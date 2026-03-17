// DDGSyncHelper.js
function syncBangs(pluginService, callback) {
    const url = "https://duckduckgo.com/bang.js";
    const xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
        if (xhr.readyState === XMLHttpRequest.DONE) {
            if (xhr.status === 200) {
                try {
                    const fullList = JSON.parse(xhr.responseText);
                    // Filter: only keep bangs with rank >= 10 to keep the list manageable? 
                    // Or keep all but strip unused fields to save space.
                    // fields: t=trigger, s=name, u=url
                    const optimizedList = fullList.map(b => ({
                        t: b.t,
                        s: b.s,
                        u: b.u.replace("{{{s}}}", "%s")
                    }));
                    
                    pluginService.savePluginData("webSearch", "ddgBangs", optimizedList);
                    pluginService.savePluginData("webSearch", "lastSync", new Date().toISOString());
                    
                    if (callback) callback(true, optimizedList.length);
                } catch (e) {
                    if (callback) callback(false, "Parse error: " + e.message);
                }
            } else {
                if (callback) callback(false, "HTTP error: " + xhr.status);
            }
        }
    };
    xhr.open("GET", url);
    xhr.send();
}
