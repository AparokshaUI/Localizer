//
//  ToolbarView.swift
//  Localizer
//

import Adwaita
import Model

struct ToolbarView: View {

    @State private var about = false

    var view: Body {
        HeaderBar.end {
            Button(icon: .custom(name: "io.github.AparokshaUI.Localizer.about-symbolic")) {
                about = true
            }
            .tooltip(Loc.mainMenu)
            .aboutDialog(
                visible: $about,
                app: "Localizer",
                developer: "david-swift",
                version: "0.1.0",
                icon: .custom(name: "io.github.AparokshaUI.Localizer"),
                website: .init(string: "https://github.com/AparokshaUI/Localizer"),
                issues: .init(string: "https://github.com/AparokshaUI/Localizer/issues")
            )
        }
    }

}
