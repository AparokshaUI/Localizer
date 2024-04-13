//
//  Phrase.swift
//  Localizer
//

import Foundation

/// A piece of text to be translated.
public struct Phrase: Identifiable {

    /// The phrase's yml key.
    public var key: String
    /// The phrase's arguments.
    public var arguments: [String]
    /// The phrase's translations.
    public var translations: [Translation]

    /// A unique identifier.
    public var id: String { key }

    /// The languages with translations for the phrase.
    public var languages: [String] {
        translations.compactMap { $0.language }
    }
    /// The languages without empty translations.
    public var filteredTranslations: [Translation] {
        translations.filter { !$0.translation.isEmpty }
    }

    /// The code for the phrase.
    public var code: String {
        var arguments = ""
        for argument in self.arguments {
            arguments += argument + ", "
        }
        if !arguments.isEmpty {
            arguments.removeLast(2)
            arguments = "(\(arguments))"
        }
        var content = """
        \(key)\(arguments):

        """
        for translation in translations.sorted(by: { translation1, translation2 in
            if translation1.language == translation2.language {
                return translation1.conditions.count < translation2.conditions.count
            }
            return translation1.language < translation2.language
        }) {
            content.append("""
                \(translation.code)

            """)
        }
        return content
    }

}
