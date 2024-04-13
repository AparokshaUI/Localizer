//
//  Overview.swift
//  Localizer
//

import Adwaita
import Foundation
import Model

struct Overview: View {

    @Binding var destination: NavigationStack<DestinationURL>

    var view: Body {
        HStack {
            field(data: LocInfo.phrases.count, text: Loc.phrases(count: LocInfo.phrases.count))
            field(data: LocInfo.languages.count, text: Loc.languages(count: LocInfo.languages.count))
        }
        .halign(.center)
        .padding(30, .bottom)
        Button(Loc.localizeProject) {
            destination.push(.languages)
        }
        .style("suggested-action")
        .style("pill")
        .horizontalCenter()
    }

    func field(data: Int, text: String) -> View {
        VStack {
            Text("\(data)")
                .style("title-1")
            Text(text)
        }
        .padding()
    }

}
