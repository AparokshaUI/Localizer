//
//  Localizer.swift
//  Localizer
//

import Adwaita
import Foundation
import Model

@main
struct Localizer: App {

    static let localizerID = "io.github.AparokshaUI.Localizer"

    @State private var destination = NavigationStack<DestinationURL>()
    @State private var appendingLanguage = false
    @State private var languageEntry = ""
    @State private var appendingPhrase = false
    @State private var idEntry = ""
    @State private var defaultLanguageEntry = ""
    @State private var defaultLanguageEntryFocus = Signal()
    @State private var arguments: [String] = []

    @State("width", folder: localizerID)
    private var width = 600
    @State("height", folder: localizerID)
    private var height = 450

    let id = localizerID
    var app: GTUIApp!

    var scene: Scene {
        mainWindow
        dialog
    }

    @SceneBuilder var mainWindow: Scene {
        Window(id: "main") { window in
            NavigationView($destination, Loc.openFile) { destination in
                switch destination {
                case .overview:
                    Overview(destination: $destination)
                        .valign(.center)
                        .padding()
                        .topToolbar {
                            ToolbarView()
                        }
                case .languages:
                    LanguagesView(stack: $destination)
                        .topToolbar {
                            ToolbarView()
                        }
                        .modifyContent(HeaderBar.self) { languagesHeaderBar(headerBar: $0) }
                case let .localize(language: language):
                    LocalizeView(language: language)
                        .topToolbar {
                            ToolbarView()
                        }
                        .modifyContent(HeaderBar.self) { localizeHeaderBar(headerBar: $0, lang: language) }
                }
            } initialView: {
                openFile(window: window)
            }
        }
        .size(width: $width, height: $height)
        .closeShortcut()
        .quitShortcut()
    }

    @SceneBuilder var dialog: Scene {
        FileDialog(
            importer: "open",
            extensions: ["yml", "yaml"]
        ) { url in
            LocInfo.url = url
            destination.push(.overview)
        } onClose: {
        }
    }

    init() {
        LocInfo.updateClosure = {
            State<Any>.updateViews(force: true)
        }
    }

    func openFile(window: GTUIApplicationWindow) -> View {
        StatusPage(
            Loc.localizeApp,
            icon: .custom(name: "io.github.AparokshaUI.Localizer"),
            description: Loc.openFileDescription
        ) {
            Button(Loc.openFile) {
                app.addWindow("open", parent: window)
            }
            .style("suggested-action")
            .style("pill")
            .horizontalCenter()
        }
        .topToolbar {
            ToolbarView()
        }
    }

    @ViewBuilder
    func languagesHeaderBar(headerBar: HeaderBar) -> View {
        let insensitive = LocInfo.languages.contains { $0 == languageEntry }
        headerBar
            .start {
                Button(icon: .default(icon: .listAdd)) {
                    appendingLanguage.toggle()
                }
                .tooltip(Loc.addLanguage)
                .popover(visible: $appendingLanguage) {
                    languagePopover(insensitive: insensitive)
                }
            }
    }

    @ViewBuilder
    func localizeHeaderBar(headerBar: HeaderBar, lang: String) -> View {
        let insensitive = idEntry.isEmpty || defaultLanguageEntry.isEmpty
        headerBar
            .titleWidget {
                WindowTitle(
                    subtitle: Loc.complete(percentage: LocInfo.completion(for: lang)),
                    title: Loc.localizeLanguage(language: lang)
                )
            }
            .start {
                Button(icon: .default(icon: .listAdd)) {
                    appendingPhrase.toggle()
                }
                .tooltip(Loc.addPhrase)
                .popover(visible: $appendingPhrase) {
                    phrasePopover(insensitive: insensitive)
                }
            }
    }

    func languagePopover(insensitive: Bool) -> View {
        VStack {
            Text(Loc.addLanguage)
                .style("title-2")
            Form {
                EntryRow(Loc.languages(count: 1), text: $languageEntry)
                    .entryActivated {
                        if !insensitive {
                            addLanguage()
                        }
                    }
            }
            HStack {
                Button(Loc.cancel) {
                    cancelLanguage()
                }
                Text("")
                    .hexpand()
                Button(Loc.add) {
                    addLanguage()
                }
                .style("suggested-action")
                .insensitive(insensitive)
            }
        }
        .spacing(20)
        .popoverWidth()
        .padding(20)
    }

    func phrasePopover(insensitive: Bool) -> View {
        VStack {
            Text(Loc.addPhrase)
                .style("title-2")
            Form {
                EntryRow(Loc.key, text: $idEntry)
                    .entryActivated {
                        defaultLanguageEntryFocus.signal()
                    }
                EntryRow(Loc.translationInDefaultLanguage, text: $defaultLanguageEntry)
                    .entryActivated {
                        if !insensitive {
                            addPhrase()
                        }
                    }
                    .focus(defaultLanguageEntryFocus)
                ArgumentsRow(arguments: $arguments)
            }
            HStack {
                Button(Loc.cancel) {
                    cancelPhrase()
                }
                Text("")
                    .hexpand()
                Button(Loc.add) {
                    addPhrase()
                }
                .style("suggested-action")
                .insensitive(insensitive)
            }
        }
        .spacing(20)
        .popoverWidth()
        .padding(20)
    }

    func addLanguage() {
        try? LocInfo.addLanguage(languageEntry)
        cancelLanguage()
    }

    func cancelLanguage() {
        languageEntry = ""
        appendingLanguage = false
    }

    func addPhrase() {
        try? LocInfo.addPhrase(id: idEntry, default: defaultLanguageEntry, arguments: arguments)
        cancelPhrase()
    }

    func cancelPhrase() {
        idEntry = ""
        defaultLanguageEntry = ""
        appendingPhrase = false
        arguments = []
    }

}
