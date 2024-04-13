//
//  Translation.swift
//  Localizer
//

import Foundation

/// A translation.
public struct Translation: Identifiable {

    /// The translation's language.
    public var language: String
    /// The conditions for the translation.
    public var conditions: [String]
    /// The translation string.
    public var translation: String

    /// A unique identifier representing the translation.
    public var id: String {
        language + "::" + conditions.joined(separator: "::")
    }

    /// The yml syntax for the translation.
    public var code: String {
        var conditions = ""
        for condition in self.conditions {
            conditions += condition + ", "
        }
        if !conditions.isEmpty {
            conditions.removeLast(2)
            conditions = "(\(conditions))"
        }
        return "\(language)\(conditions): \"\(translation.parseInput())\""
    }

}
