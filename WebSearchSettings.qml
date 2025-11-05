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

    StyledRect {
        width: parent.width
        height: addEngineColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: addEngineColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
                text: "Create Custom Search Engine"
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            Row {
                width: parent.width
                spacing: Theme.spacingM

                Column {
                    width: (parent.width - Theme.spacingM) / 2
                    spacing: Theme.spacingXS

                    StyledText {
                        text: "Engine ID *"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }

                    DankTextField {
                        id: idField
                        width: parent.width
                        placeholderText: "e.g., myengine"
                        keyNavigationTab: nameField
                        onFocusStateChanged: hasFocus => {
                            if (hasFocus) root.ensureItemVisible(idField)
                        }
                    }
                }

                Column {
                    width: (parent.width - Theme.spacingM) / 2
                    spacing: Theme.spacingXS

                    StyledText {
                        text: "Display Name *"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }

                    DankTextField {
                        id: nameField
                        width: parent.width
                        placeholderText: "e.g., My Engine"
                        keyNavigationBacktab: idField
                        keyNavigationTab: iconField
                        onFocusStateChanged: hasFocus => {
                            if (hasFocus) root.ensureItemVisible(nameField)
                        }
                    }
                }
            }

            Row {
                width: parent.width
                spacing: Theme.spacingM

                Column {
                    width: (parent.width - Theme.spacingM) / 2
                    spacing: Theme.spacingXS

                    StyledText {
                        text: "Icon"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }

                    DankTextField {
                        id: iconField
                        width: parent.width
                        placeholderText: "e.g., unicode:🔍"
                        keyNavigationBacktab: nameField
                        keyNavigationTab: urlField
                        onFocusStateChanged: hasFocus => {
                            if (hasFocus) root.ensureItemVisible(iconField)
                        }
                    }

                    StyledText {
                        text: "Prefix with 'material:' for Material Symbols or 'unicode:' for emoji/Nerd Font glyphs."
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }

                Column {
                    width: (parent.width - Theme.spacingM) / 2
                    spacing: Theme.spacingXS

                    StyledText {
                        text: "Search URL *"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }

                    DankTextField {
                        id: urlField
                        width: parent.width
                        placeholderText: "e.g., https://example.com/search?q=%s"
                        keyNavigationBacktab: iconField
                        keyNavigationTab: keywordsField
                        onFocusStateChanged: hasFocus => {
                            if (hasFocus) root.ensureItemVisible(urlField)
                        }
                    }

                    StyledText {
                        text: "Use %s as placeholder for search query"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                        wrapMode: Text.WordWrap
                        width: parent.width
                    }
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingXS

                StyledText {
                    text: "Keywords (comma separated)"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }

                DankTextField {
                    id: keywordsField
                    width: parent.width
                    placeholderText: "e.g., my,engine,search"
                    keyNavigationBacktab: urlField
                    onFocusStateChanged: hasFocus => {
                        if (hasFocus) root.ensureItemVisible(keywordsField)
                    }
                }

                StyledText {
                    text: "Use these keywords to trigger this engine (e.g., '? keyword query')"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }

            DankButton {
                id: addButton
                text: "Create Engine"
                iconName: "add"

                onClicked: {
                    const id = idField.text.trim()
                    const name = nameField.text.trim()
                    const url = urlField.text.trim()

                    if (!id || !name || !url) {
                        if (typeof ToastService !== "undefined") {
                            ToastService.showError("Please fill in required fields (ID, Name, URL)")
                        }
                        return
                    }

                    const keywordsText = keywordsField.text.trim()
                    const keywords = keywordsText ? keywordsText.split(",").map(k => k.trim()).filter(k => k.length > 0) : []

                    const newEngine = {
                        id: id,
                        name: name,
                        icon: iconField.text.trim() || "unicode:🔍",
                        url: url,
                        keywords: keywords
                    }

                    const currentEngines = root.loadValue("searchEngines", [])
                    const updatedEngines = currentEngines.concat([newEngine])
                    root.saveValue("searchEngines", updatedEngines)

                    idField.text = ""
                    nameField.text = ""
                    iconField.text = ""
                    urlField.text = ""
                    keywordsField.text = ""

                    idField.forceActiveFocus()
                }
            }
        }
    }

    StyledRect {
        width: parent.width
        height: Math.max(200, enginesColumn.implicitHeight + Theme.spacingL * 2)
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: enginesColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
                text: "Existing Custom Engines"
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            ListView {
                width: parent.width
                height: Math.max(100, contentHeight)
                clip: true
                spacing: Theme.spacingXS

                model: root.variantsModel.count > 0 ? root.variantsModel : root.loadValue("searchEngines", [])

                delegate: StyledRect {
                    required property var model
                    required property int index

                    width: ListView.view.width
                    height: engineColumn.implicitHeight + Theme.spacingM * 2
                    radius: Theme.cornerRadius
                    color: engineMouseArea.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainer

                    Column {
                        id: engineColumn
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingXS

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            Item {
                                width: Theme.iconSize
                                height: Theme.iconSize
                                anchors.verticalCenter: parent.verticalCenter

                                DankIcon {
                                    anchors.centerIn: parent
                                    name: model.icon || "unicode:🔍"
                                    size: Theme.iconSize
                                    color: Theme.surfaceText
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                width: parent.width - Theme.iconSize - deleteButton.width - Theme.spacingM * 3

                                StyledText {
                                    text: model.name || "Unnamed"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    width: parent.width
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    text: "ID: " + (model.id || "") + " | URL: " + (model.url || "")
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    width: parent.width
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    text: {
                                        const kw = model.keywords
                                        if (Array.isArray(kw) && kw.length > 0) {
                                            return "Keywords: " + kw.join(", ")
                                        }
                                        return "No keywords"
                                    }
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    width: parent.width
                                    elide: Text.ElideRight
                                }
                            }

                            Rectangle {
                                id: deleteButton
                                anchors.verticalCenter: parent.verticalCenter
                                width: 32
                                height: 32
                                radius: 16
                                color: deleteArea.containsMouse ? Theme.error : "transparent"

                                DankIcon {
                                    anchors.centerIn: parent
                                    name: "delete"
                                    size: 16
                                    color: deleteArea.containsMouse ? Theme.onError : Theme.surfaceVariantText
                                }

                                MouseArea {
                                    id: deleteArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        const currentEngines = root.loadValue("searchEngines", [])
                                        const updatedEngines = currentEngines.filter((_, i) => i !== index)
                                        root.saveValue("searchEngines", updatedEngines)
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: engineMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    text: "No custom engines created yet"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    visible: parent.count === 0
                }
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
