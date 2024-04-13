//
//  ArgumentsRow.swift
//  Localizer
//

import Adwaita
import Model

struct ArgumentsRow: View {

    @Binding var arguments: [String]
    @State private var expanded = false
    @State private var focus = Signal()

    var view: Body {
        ExpanderRow()
            .title(Loc.arguments)
            .subtitle(Loc.argumentsDescription)
            .suffix {
                VStack {
                    Button(icon: .default(icon: .listAdd)) {
                        arguments.append("")
                        expanded = true
                        focus.signal()
                    }
                    .style("flat")
                    .tooltip(Loc.addArgument)
                }
                .valign(.center)
            }
            .rows {
                List(.init(arguments.indices), selection: nil) { index in
                    let keyword = arguments[safe: index] ?? ""
                    EntryRow(Loc.argument, text: .init {
                        keyword
                    } set: { newValue in
                        arguments[safe: index] = newValue
                    })
                    .suffix {
                        VStack {
                            Button(icon: .default(icon: .userTrash)) {
                                arguments = arguments.filter { $0 != keyword }
                            }
                            .style("flat")
                            .tooltip(Loc.removeArgument)
                        }
                        .valign(.center)
                    }
                    .entryActivated {
                        arguments.append("")
                        focus.signal()
                    }
                    .focus(index == arguments.count - 1 ? focus : .init())
                }
                .style("boxed-list")
                .padding()
            }
            .enableExpansion(.constant(!arguments.isEmpty))
            .expanded($expanded)
    }

}
