import QtQuick

QtObject {
    readonly property var engines: [
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
            id: "kagi",
            name: "Kagi",
            icon: "material:star_shine",
            url: "https://kagi.com/search?q=%s",
            keywords: ["kagi", "privacy"]
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
            icon: "unicode:",
            url: "https://github.com/search?q=%s",
            keywords: ["github", "code", "git"]
        },
        {
            id: "stackoverflow",
            name: "Stack Overflow",
            icon: "unicode:",
            url: "https://stackoverflow.com/search?q=%s",
            keywords: ["stackoverflow", "stack", "coding"]
        },
        {
            id: "reddit",
            name: "Reddit",
            icon: "unicode:",
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
            icon: "unicode:",
            url: "https://twitter.com/search?q=%s",
            keywords: ["twitter", "x", "social"]
        },
        {
            id: "linkedin",
            name: "LinkedIn",
            icon: "unicode:",
            url: "https://www.linkedin.com/search/results/all/?keywords=%s",
            keywords: ["linkedin", "job", "professional"]
        },
        {
            id: "imdb",
            name: "IMDb",
            icon: "unicode:",
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
            icon: "unicode:",
            url: "https://aur.archlinux.org/packages?K=%s",
            keywords: ["aur", "arch", "packages"]
        },
        {
            id: "npmjs",
            name: "npm",
            icon: "unicode:",
            url: "https://www.npmjs.com/search?q=%s",
            keywords: ["npm", "node", "javascript"]
        },
        {
            id: "pypi",
            name: "PyPI",
            icon: "unicode:",
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
}
