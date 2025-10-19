import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "webSearch"

    StyledText {
        width: parent.width
        text: "Web Search Settings"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Search the web with built-in and custom search engines directly from the launcher."
        font.pixelSize: Theme.fontSizeMedium
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.outlineVariant
    }

    Column {
        spacing: 12
        width: parent.width

        StyledText {
            text: "Trigger Configuration"
            font.pixelSize: Theme.fontSizeLarge
            font.weight: Font.Medium
            color: Theme.surfaceText
        }

        StyledText {
            text: noTriggerToggle.checked ? "Items will always show in the launcher (no trigger needed)." : "Set the trigger text to activate web search. Type the trigger in the launcher followed by your search query."
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            wrapMode: Text.WordWrap
            width: parent.width
        }

        Row {
            spacing: 12

            CheckBox {
                id: noTriggerToggle
                text: "No trigger (always show)"
                checked: root.loadValue("noTrigger", false)

                contentItem: StyledText {
                    text: noTriggerToggle.text
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.surfaceText
                    leftPadding: noTriggerToggle.indicator.width + 8
                    verticalAlignment: Text.AlignVCenter
                }

                indicator: StyledRect {
                    implicitWidth: 20
                    implicitHeight: 20
                    radius: Theme.cornerRadiusSmall
                    border.color: noTriggerToggle.checked ? Theme.primary : Theme.outline
                    border.width: 2
                    color: noTriggerToggle.checked ? Theme.primary : "transparent"

                    StyledRect {
                        width: 12
                        height: 12
                        anchors.centerIn: parent
                        radius: 2
                        color: Theme.onPrimary
                        visible: noTriggerToggle.checked
                    }
                }

                onCheckedChanged: {
                    root.saveValue("noTrigger", checked)
                    if (checked) {
                        root.saveValue("trigger", "")
                    } else {
                        root.saveValue("trigger", triggerField.text || "?")
                    }
                }
            }
        }

        Row {
            spacing: 12
            width: parent.width
            visible: !noTriggerToggle.checked

            StyledText {
                text: "Trigger:"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }

            DankTextField {
                id: triggerField
                width: 100
                height: 40
                text: root.loadValue("trigger", "?")
                placeholderText: "?"
                backgroundColor: Theme.surfaceContainer
                textColor: Theme.surfaceText

                onTextEdited: {
                    const newTrigger = text.trim()
                    root.saveValue("trigger", newTrigger || "?")
                    root.saveValue("noTrigger", newTrigger === "")
                }
            }

            StyledText {
                text: "Examples: ?, /, /search, etc."
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.outlineVariant
    }

    SelectionSetting {
        settingKey: "defaultEngine"
        label: "Default Search Engine"
        description: "The search engine used when no keyword is specified"
        options: [
            {label: "Google", value: "google"},
            {label: "DuckDuckGo", value: "duckduckgo"},
            {label: "Brave Search", value: "brave"},
            {label: "Bing", value: "bing"}
        ]
        defaultValue: "google"
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.outlineVariant
    }

    ListSettingWithInput {
        settingKey: "searchEngines"
        label: "Custom Search Engines"
        description: "Add your own search engines with custom URLs"
        defaultValue: []
        fields: [
            {id: "id", label: "ID", placeholder: "myengine", width: 120, required: true},
            {id: "name", label: "Name", placeholder: "My Engine", width: 150, required: true},
            {id: "icon", label: "Icon", placeholder: "search", width: 100, required: false, default: "search"},
            {id: "url", label: "URL (use %s for query)", placeholder: "https://example.com/search?q=%s", width: 300, required: true},
            {id: "keywords", label: "Keywords (comma separated)", placeholder: "my,engine", width: 200, required: false, default: ""}
        ]
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.outlineVariant
    }

    Column {
        spacing: 8
        width: parent.width

        StyledText {
            text: "Built-in Search Engines:"
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Font.Medium
            color: Theme.surfaceText
        }

        Column {
            spacing: 4
            leftPadding: 16

            StyledText {
                text: "• Google, DuckDuckGo, Brave Search, Bing"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                text: "• YouTube, GitHub, Stack Overflow, Reddit, Wikipedia"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                text: "• Amazon, eBay, Google Maps, Google Images"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                text: "• Twitter/X, LinkedIn, IMDb, Google Translate"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                text: "• Arch Linux, AUR, npm, PyPI, crates.io, MDN"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }
        }
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.outlineVariant
    }

    Column {
        spacing: 8
        width: parent.width

        StyledText {
            text: "Usage:"
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Font.Medium
            color: Theme.surfaceText
        }

        Column {
            spacing: 4
            leftPadding: 16
            bottomPadding: 24

            StyledText {
                text: "1. Open Launcher (Ctrl+Space or click launcher button)"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                text: noTriggerToggle.checked ? "2. Type your search query directly" : "2. Type your trigger (default: ?) followed by search query"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                text: noTriggerToggle.checked ? "3. Example: 'linux kernel' or 'github rust'" : "3. Example: '? linux kernel' or '? github rust'"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                text: "4. Use keywords for specific engines: 'youtube music', 'github project', 'wiki topic'"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                text: "5. Select search engine and press Enter to open in browser"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }
        }
    }

    Column {
        spacing: 8
        width: parent.width

        StyledText {
            text: "Adding Custom Search Engines:"
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Font.Medium
            color: Theme.surfaceText
        }

        Column {
            spacing: 4
            leftPadding: 16
            bottomPadding: 24

            StyledText {
                text: "1. Find the search URL for your desired website"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                text: "2. Replace the search query with %s in the URL"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                text: "3. Example: https://mysite.com/search?q=%s"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                text: "4. Add it using the Custom Search Engines section above"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                text: "5. Set keywords for quick access (e.g., 'mysite' or 'ms')"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }
        }
    }
}
