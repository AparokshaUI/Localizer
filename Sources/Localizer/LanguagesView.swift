//
//  LanguagesView.swift
//  Localizer
//

import Adwaita
import Foundation
import Model
import Yams

struct LanguagesView: View {

    @Binding var stack: NavigationStack<DestinationURL>

    var view: Body {
        ScrollView {
            List(LocInfo.languages, selection: nil) { language in
                let isDefault = LocInfo.defaultLanguage == language
                let percentage = isDefault ? Loc.defaultLanguage : Loc.complete(
                    percentage: LocInfo.completion(for: language)
                )
                ActionRow()
                    .title("<b>\(language)</b>")
                    .subtitle(percentage)
                    .suffix {
                        ButtonContent()
                            .iconName(Icon.default(icon: .goNext).string)
                    }
                    .activatableWidget {
                        Button()
                            .activate {
                                stack.push(.localize(language: language))
                            }
                    }
            }
            .style("boxed-list")
            .formWidth()
            .padding(20)
            Text("")
        }
    }

}
