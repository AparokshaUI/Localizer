//
//  LocalizePhraseView.swift
//  Localizer
//

import Adwaita
import Model

struct LocalizePhraseView: View {

    @State private var errorDialog = false
    @State private var showArgumentsDialog = false
    var selectedPhrase: String?
    var phrase: Phrase
    var language: String
    var focusNext: () -> Void

    var defaultLanguage: String { LocInfo.defaultLanguage }
    var translation: Translation? { phrase.translations.first { $0.language == language } }
    var defaultTranslation: String? {
        phrase.translations.first { translation in
            translation.language == self.defaultLanguage && translation.conditions.isEmpty
        }?.translation
    }

    var view: Body {
        Form {
            if let defaultTranslation {
                ActionRow()
                    .title(phrase.id)
                    .subtitle(defaultTranslation)
                    .suffix {
                        argumentsSuffix
                    }
                    .subtitleSelectable()
                    .titleSelectable()
                    .style("property")
            } else {
                noDefaultTranslationRow
            }
            EntryRow(
                Loc.translation,
                text: .init {
                    translation?.translation ?? ""
                } set: { newValue in
                    try? LocInfo.updateTranslation(phrase: phrase.id, lang: language, translation: newValue)
                }
            )
            .entryActivated {
                focusNext()
            }
            .focused(.constant(selectedPhrase == phrase.key))
        }
        .formWidth()
        .padding(10, .vertical)
    }

    var noDefaultTranslationRow: View {
        ActionRow()
            .title(phrase.key)
            .suffix {
                HStack {
                    Button(icon: .default(icon: .dialogError)) {
                        errorDialog = true
                    }
                    .padding(10, .vertical)
                    .style("flat")
                    .tooltip(Loc.noTranslation(defaultLanguage: self.defaultLanguage))
                    .popover(visible: $errorDialog) {
                        Text(Loc.noTranslation(defaultLanguage: self.defaultLanguage))
                            .padding()
                    }
                    if !phrase.arguments.isEmpty {
                        Button(icon: .default(icon: .viewListBullet)) {
                            showArgumentsDialog = true
                        }
                    }
                }
                .modifyContent(VStack.self) { $0.spacing(10) }
            }
            .style("error")
    }

    @ViewBuilder var argumentsSuffix: View {
        if !phrase.arguments.isEmpty {
            Button(icon: .default(icon: .viewListBullet)) {
                showArgumentsDialog = true
            }
            .padding(10, .vertical)
            .style("flat")
            .dialog(
                visible: $showArgumentsDialog,
                title: Loc.conditionalTranslations(phrase: defaultTranslation ?? phrase.key),
                height: 400
            ) {
                argumentsDialog
            }
        }
    }

    var argumentsDialog: View {
        ScrollView {
            ForEach(phrase.arguments) { argument in
                let prefix = "\(argument) == "
                FormSection(argument) {
                    ForEach(
                        phrase.translations.filter { translation in
                            translation.conditions[safe: 0]?.hasPrefix(prefix) ?? false
                            && translation.language == language
                        }
                    ) { translation in
                        argumentsForm(translation: translation, argument: argument)
                    }
                }
                .suffix {
                    Button(icon: .default(icon: .listAdd)) {
                        try? LocInfo.updateTranslation(
                            phrase: phrase.id,
                            lang: language,
                            translation: "",
                            conditions: [prefix + "\"\""]
                        )
                    }
                    .padding(10, .vertical)
                    .style("flat")
                }
            }
            .padding(20)
            .formWidth()
        }
        .topToolbar {
            HeaderBar.empty()
        }
        .stopModifiers()
    }

    @ViewBuilder
    func argumentsForm(translation: Translation, argument: String) -> View {
        let prefix = "\(argument) == "
        Form {
            EntryRow("Value", text: .init {
                var value = translation.conditions[safe: 0] ?? ""
                value.removeFirst(prefix.count + 1)
                value.removeLast()
                return value
            } set: { newValue in
                try? LocInfo.updateTranslation(
                    phrase: phrase.id,
                    lang: language,
                    translation: translation.translation,
                    conditions: [prefix + "\"\(newValue)\""],
                    previousConditions: translation.conditions
                )
            })
            EntryRow(Loc.translation, text: .init {
                translation.translation
            } set: { newValue in
                try? LocInfo.updateTranslation(
                    phrase: phrase.id,
                    lang: language,
                    translation: newValue,
                    conditions: translation.conditions,
                    previousConditions: translation.conditions
                )
            })
        }
        .padding(10, .vertical)
    }

}
