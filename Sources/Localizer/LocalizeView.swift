//
//  LocalizeView.swift
//  Localizer
//

import Adwaita
import Foundation
import Model
import Yams

struct LocalizeView: View {

    @State private var focusedEntry: String?
    var language: String

    var view: Body {
        ScrollView {
            ForEach(LocInfo.phrases) { phrase in
                LocalizePhraseView(
                    selectedPhrase: focusedEntry,
                    phrase: phrase,
                    language: language
                ) {
                    let index = LocInfo.phrases.firstIndex { $0.key == phrase.key }
                    focusedEntry = LocInfo.phrases[safe: (index ?? -1) + 1]?.key
                    focusedEntry = nil
                }
            }
            .formWidth()
            .padding(20)
        }
    }

}
