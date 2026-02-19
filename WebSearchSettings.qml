import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "webSearch"

    property int editingIndex: -1
    property var customEngines: []
    property var disabledEngineIds: []
    property var defaultEngineOptions: []

    property var builtInEnginesList: {
        const enginesComponent = Qt.createComponent("SearchEngines.qml");
        if (enginesComponent.status === Component.Ready) {
            const enginesObj = enginesComponent.createObject(root);
            return enginesObj.engines;
        }
        return [];
    }

    Component.onCompleted: {
        syncSettingsState();
    }

    function buildDefaultEngineOptions(engines) {
        const builtInOptions = root.builtInEnginesList.map(engine => ({
            label: engine.name,
            value: engine.id
        }));

        const customOptions = engines.map(engine => ({
            label: engine.name + " (Custom)",
            value: engine.id
        }));

        return builtInOptions.concat(customOptions);
    }

    function syncSettingsState() {
        customEngines = root.loadValue("searchEngines", []);
        disabledEngineIds = root.loadValue("disabledEngines", []);
        defaultEngineOptions = buildDefaultEngineOptions(customEngines);
    }

    function setCustomEngines(engines) {
        customEngines = engines;
        defaultEngineOptions = buildDefaultEngineOptions(customEngines);
        root.saveValue("searchEngines", customEngines);
    }

    function setDisabledEngineIds(ids) {
        disabledEngineIds = ids;
        root.saveValue("disabledEngines", disabledEngineIds);
    }

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
        id: triggerSetting
        width: parent.width
        spacing: Theme.spacingS
        property string value: "@"
        property bool isInitialized: false
        property bool hasFieldFocus: false
        property bool isDirty: false

        function loadValue() {
            const loadedValue = root.loadValue("trigger", "@");
            const normalizedValue = loadedValue && loadedValue.trim().length > 0 ? loadedValue : "@";
            if ((hasFieldFocus || isDirty) && isInitialized)
                return;
            value = normalizedValue;
            triggerField.text = normalizedValue;
            isInitialized = true;
            isDirty = false;
        }

        function commit() {
            if (!isInitialized)
                return;
            const cleaned = triggerField.text.trim().length > 0 ? triggerField.text.trim() : "@";
            if (cleaned !== value) {
                value = cleaned;
                root.saveValue("trigger", value);
            }
            triggerField.text = value;
            isDirty = false;
        }

        Component.onCompleted: {
            Qt.callLater(loadValue);
        }

        StyledText {
            text: "Trigger"
            font.pixelSize: Theme.fontSizeMedium
            font.weight: Font.Medium
            color: Theme.surfaceText
        }

        StyledText {
            text: "Examples: @, !, ws, etc. Avoid triggers reserved by DMS or other plugins (e.g., / for file search)."
            font.pixelSize: Theme.fontSizeSmall
            color: Theme.surfaceVariantText
            width: parent.width
            wrapMode: Text.WordWrap
        }

        Row {
            width: parent.width
            spacing: Theme.spacingS

            DankTextField {
                id: triggerField
                width: parent.width - saveTriggerButton.width - Theme.spacingS
                text: triggerSetting.value
                placeholderText: "@"
                onTextEdited: triggerSetting.isDirty = (triggerField.text !== triggerSetting.value)
                onEditingFinished: triggerSetting.commit()
                onFocusStateChanged: hasFocus => {
                    triggerSetting.hasFieldFocus = hasFocus;
                    if (!hasFocus)
                        triggerSetting.commit();
                }
            }

            DankButton {
                id: saveTriggerButton
                anchors.verticalCenter: triggerField.verticalCenter
                text: "Save"
                iconName: "save"
                onClicked: triggerSetting.commit()
            }
        }
    }

    StyledRect {
        width: parent.width
        height: 1
        color: Theme.outlineVariant
    }

    SelectionSetting {
        id: defaultEngineSetting
        settingKey: "defaultEngine"
        label: "Default Search Engine"
        description: "The search engine used when no keyword is specified. Includes all built-in and custom engines."
        options: root.defaultEngineOptions
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
                text: root.editingIndex === -1 ? "Create Custom Search Engine" : "Edit Custom Search Engine"
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
                            if (hasFocus)
                                root.ensureItemVisible(idField);
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
                            if (hasFocus)
                                root.ensureItemVisible(nameField);
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
                            if (hasFocus)
                                root.ensureItemVisible(iconField);
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
                            if (hasFocus)
                                root.ensureItemVisible(urlField);
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
                        if (hasFocus)
                            root.ensureItemVisible(keywordsField);
                    }
                }

                StyledText {
                    text: "Use these keywords to trigger this engine (e.g., '@ keyword query')"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }

            Row {
                spacing: Theme.spacingM

                DankButton {
                    id: addButton
                    text: root.editingIndex === -1 ? "Create Engine" : "Update Engine"
                    iconName: root.editingIndex === -1 ? "add" : "save"

                    onClicked: {
                        const id = idField.text.trim();
                        const name = nameField.text.trim();
                        const url = urlField.text.trim();

                        if (!id || !name || !url) {
                            if (typeof ToastService !== "undefined") {
                                ToastService.showError("Please fill in required fields (ID, Name, URL)");
                            }
                            return;
                        }

                        const keywordsText = keywordsField.text.trim();
                        const keywords = keywordsText ? keywordsText.split(",").map(k => k.trim()).filter(k => k.length > 0) : [];

                        const engine = {
                            id: id,
                            name: name,
                            icon: iconField.text.trim() || "unicode:🔍",
                            url: url,
                            keywords: keywords
                        };

                        const currentEngines = root.customEngines;
                        if (root.editingIndex === -1) {
                            const updatedEngines = currentEngines.concat([engine]);
                            root.setCustomEngines(updatedEngines);
                        } else {
                            const updatedEngines = currentEngines.slice();
                            updatedEngines[root.editingIndex] = engine;
                            root.setCustomEngines(updatedEngines);
                            root.editingIndex = -1;
                        }

                        idField.text = "";
                        nameField.text = "";
                        iconField.text = "";
                        urlField.text = "";
                        keywordsField.text = "";

                        idField.forceActiveFocus();
                    }
                }

                DankButton {
                    text: "Cancel"
                    iconName: "close"
                    visible: root.editingIndex !== -1
                    onClicked: {
                        root.editingIndex = -1;
                        idField.text = "";
                        nameField.text = "";
                        iconField.text = "";
                        urlField.text = "";
                        keywordsField.text = "";
                    }
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

                model: root.variantsModel.count > 0 ? root.variantsModel : root.customEngines

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
                                visible: false // Workaround for DankMaterialShell bug with unicode/material icons

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
                                width: parent.width - editButton.width - deleteButton.width - Theme.spacingM * 3

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
                                        const kw = model.keywords;
                                        if (kw && kw.length > 0) {
                                            let result = [];
                                            for (let i = 0; i < kw.length; i++) {
                                                result.push(kw[i]);
                                            }
                                            return "Keywords: " + result.join(", ");
                                        }
                                        return "No keywords";
                                    }
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    width: parent.width
                                    elide: Text.ElideRight
                                }
                            }

                            Rectangle {
                                id: editButton
                                anchors.verticalCenter: parent.verticalCenter
                                width: 32
                                height: 32
                                radius: 16
                                color: editArea.containsMouse ? Theme.primary : "transparent"

                                DankIcon {
                                    anchors.centerIn: parent
                                    name: "edit"
                                    size: 16
                                    color: editArea.containsMouse ? Theme.onPrimary : Theme.surfaceVariantText
                                }

                                MouseArea {
                                    id: editArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.editingIndex = index;
                                        const engine = root.customEngines[index];
                                        idField.text = engine.id;
                                        nameField.text = engine.name;
                                        iconField.text = engine.icon;
                                        urlField.text = engine.url;
                                        keywordsField.text = Array.isArray(engine.keywords) ? engine.keywords.join(", ") : "";
                                        root.ensureItemVisible(idField);
                                    }
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
                                        const currentEngines = root.customEngines;
                                        const updatedEngines = currentEngines.filter((_, i) => i !== index);
                                        root.setCustomEngines(updatedEngines);
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

    StyledRect {
        width: parent.width
        height: builtInEnginesColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: builtInEnginesColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
                text: "Built-in Search Engines"
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            StyledText {
                text: "Enable or disable search engines. Disabled engines will not appear in search results."
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
                width: parent.width
            }

            ListView {
                width: parent.width
                height: Math.max(200, contentHeight)
                clip: true
                spacing: Theme.spacingXS

                model: root.builtInEnginesList

                delegate: StyledRect {
                    required property var modelData
                    required property int index

                    width: ListView.view.width
                    height: engineToggleRow.implicitHeight + Theme.spacingS * 2
                    radius: Theme.cornerRadius
                    color: engineToggleMouseArea.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainer

                    Row {
                        id: engineToggleRow
                        anchors.fill: parent
                        anchors.margins: Theme.spacingS
                        spacing: Theme.spacingM

                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 2
                            width: parent.width - toggleSwitch.width - Theme.spacingM

                            StyledText {
                                text: modelData.name
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.surfaceText
                                width: parent.width
                                elide: Text.ElideRight
                            }

                            StyledText {
                                text: "Keywords: " + (Array.isArray(modelData.keywords) ? modelData.keywords.join(", ") : modelData.keywords)
                                font.pixelSize: Theme.fontSizeSmall
                                color: Theme.surfaceVariantText
                                width: parent.width
                                elide: Text.ElideRight
                            }
                        }

                        Rectangle {
                            id: toggleSwitch
                            anchors.verticalCenter: parent.verticalCenter
                            width: 48
                            height: 24
                            radius: 12
                            color: {
                                const isEnabled = !root.disabledEngineIds.includes(modelData.id);
                                return isEnabled ? Theme.primary : Theme.surfaceVariant;
                            }

                            Rectangle {
                                width: 20
                                height: 20
                                radius: 10
                                color: Theme.surface
                                x: {
                                    const isEnabled = !root.disabledEngineIds.includes(modelData.id);
                                    return isEnabled ? parent.width - width - 2 : 2;
                                }
                                y: 2

                                Behavior on x {
                                    NumberAnimation { duration: 150 }
                                }
                            }

                            MouseArea {
                                id: toggleArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    const disabled = root.disabledEngineIds;
                                    const isEnabled = !disabled.includes(modelData.id);

                                    if (isEnabled) {
                                        // Disable the engine
                                        root.setDisabledEngineIds(disabled.concat([modelData.id]));
                                    } else {
                                        // Enable the engine
                                        const updated = disabled.filter(id => id !== modelData.id);
                                        root.setDisabledEngineIds(updated);
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: engineToggleMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                    }
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
                text: "2. Type your trigger (default: @) followed by search query"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
            }

            StyledText {
                text: "3. Example: '@ linux kernel' or '@ github rust'"
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
