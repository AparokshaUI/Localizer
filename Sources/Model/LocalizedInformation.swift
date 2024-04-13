//
//  LocalizedInformation.swift
//  Localizer
//

import Foundation
import Yams

/// A type containing variables and functions for reading and writing the yml data.
public enum LocalizedInformation {

    /// The prefix for empty languages.
    static var emptyPrefix: String { "# empty: " }
    /// The key for the default language.
    static var defaultKey: String { "default" }
    /// The yml file's URL.
    public static var url: URL? {
        didSet {
            cache.reset()
        }
    }

    /// The closure that updates the views.
    public static var updateClosure: () -> Void = { }
    /// The cache data.
    static var cache: LocalizedCache = .init()

    /// The content of the yml file.
    static var content: String {
        guard let url else {
            return ""
        }
        if let cache = cache.content {
            return cache
        }
        let data = (try? String(contentsOf: url)) ?? ""
        cache.content = data
        return data
    }

    static var ymlDictionary: [String: Any] {
        if let cache = cache.dictionary, url != nil {
            return cache
        }
        if let dict = try? Yams.load(yaml: content) as? [String: Any] {
            cache.dictionary = dict
            return dict
        }
        return [:]
    }

    /// The default language.
    public static var defaultLanguage: String {
        if let defaultLanguage = ymlDictionary[defaultKey] as? String {
            return defaultLanguage
        }
        return "en"
    }

    /// The available languages.
    public static var languages: [String] {
        if let cache = cache.languages, url != nil {
            return cache
        }
        var languages: Set<String> = []
        for key in phrases {
            languages = languages.union(key.languages)
        }
        for var line in content.split(separator: "\n") where line.hasPrefix(emptyPrefix) {
            line.removeFirst(emptyPrefix.count)
            let language = parseKey(.init(line))
            languages.insert(language.key)
        }
        let sorted = languages.sorted()
        cache.languages = sorted
        return sorted
    }

    /// The available phrases.
    public static var phrases: [Phrase] {
        if let cache = cache.phrases, url != nil {
            return cache
        }
        var dict = ymlDictionary
        dict[defaultKey] = nil
        if let dictionary = dict as? [String: [String: String]] {
            let phrases: [Phrase] = dictionary.map { entry in
                let key = parseKey(entry.key)
                return .init(
                    key: key.key,
                    arguments: key.arguments,
                    translations: entry.value.reduce(into: [Translation]()) { result, value in
                        let key = parseKey(value.key)
                        result.append(
                            .init(language: key.key, conditions: key.arguments, translation: parseValue(value.value))
                        )
                    }
                    .sorted { $0.id < $1.id }
                )
            }
            .sorted { $0.key < $1.key }
            cache.phrases = phrases
            return phrases
        }
        return []
    }

    /// The cache data's structure.
    struct LocalizedCache {

        // swiftlint:disable discouraged_optional_collection
        /// The content of the yml file.
        var content: String?
        /// The file's content parsed as a dictionary.
        var dictionary: [String: Any]?
        /// The languages defined in the file.
        var languages: [String]?
        /// The phrases in the file.
        var phrases: [Phrase]?
        // swiftlint:enable discouraged_optional_collection

        /// Reset the cache.
        mutating func reset() {
            content = nil
            dictionary = nil
            languages = nil
            phrases = nil
        }

    }

    /// Get the available translations for a language.
    /// - Parameter language: The language.
    /// - Returns: The keys and translations in the given language for the phrases.
    public static func translations(for language: String) -> [(String, [Translation])] {
        phrases.map { ($0.key, $0.translations.filter { $0.language == language }) }
    }

    /// Get the percentage of completion for a language.
    /// - Parameter language: The language.
    /// - Returns: The percentage.
    public static func completion(for language: String) -> Int {
        Int(Double(translations(for: language).filter { !$0.1.isEmpty }.count) / .init(phrases.count) * 100)
    }

    /// Add a new language.
    /// - Parameter language: The language.
    public static func addLanguage(_ language: String) throws {
        let content = emptyPrefix + language + "\n" + content
        guard let url else {
            return
        }
        try content.write(to: url, atomically: true, encoding: String.Encoding.utf8)
        updateViews()
    }

    /// Add a new phrase.
    /// - Parameters:
    ///     - id: The phrase's identifier.
    ///     - defaultTranslation: The translation in the default language.
    ///     - arguments: The arguments for the translation.
    public static func addPhrase(id: String, default defaultTranslation: String, arguments: [String]) throws {
        var content = content
        var argumentsCode = arguments.joined(separator: ", ")
        if !arguments.isEmpty {
            argumentsCode = "(\(argumentsCode))"
        }
        content.append("""

        \(id)\(argumentsCode):
            \(defaultLanguage): "\(defaultTranslation.parseInput())"

        """)
        guard let url else {
            return
        }
        try content.write(to: url, atomically: true, encoding: .utf8)
        updateViews()
    }

    /// Update a translation.
    /// - Parameters:
    ///     - phrase: The identifier of the phrase.
    ///     - lang: The identifier of the language.
    ///     - conditions: The new conditions for the translation.
    ///     - previousConditions: The conditions for the translation before the update.
    ///     - translation: The translation string.
    public static func updateTranslation(
        phrase: String,
        lang: String,
        translation: String,
        conditions: [String] = [],
        previousConditions: [String] = []
    ) throws {
        var newPhrases = phrases
        if let index = newPhrases.firstIndex(where: { $0.id == phrase }) {
            if let translationIndex = newPhrases[index].translations.firstIndex(
                where: { $0.language == lang && $0.conditions == previousConditions }
            ) {
                newPhrases[index].translations[translationIndex].conditions = conditions
                newPhrases[index].translations[translationIndex].translation = translation
            } else {
                newPhrases[index].translations.append(
                    .init(language: lang, conditions: conditions, translation: translation)
                )
            }
        }
        var content = ""
        content += """
        default: \(defaultLanguage)


        """
        for phrase in newPhrases {
            content += """
            \(phrase.code)

            """
        }
        content.removeLast()
        guard let url else {
            return
        }
        try content.write(to: url, atomically: true, encoding: .utf8)
        updateViews()
    }

    /// Parse a translation string from the yml file.
    /// - Parameter value: The string.
    /// - Returns: The parsed string.
    static func parseValue(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\\"", with: "\"")
    }

    /// Parse the key for a phrase.
    /// - Parameter key: The key definition including parameters.
    /// - Returns: The key.
    static func parseKey(_ key: String) -> (key: String, arguments: [String]) {
        let parts = key.split(separator: "(")
        if parts.count == 1 {
            return (key, [])
        }
        let arguments = parts[1].dropLast().split(separator: ", ").map { String($0) }
        return (.init(parts[0]), arguments)
    }

    static func updateViews() {
        cache.reset()
        updateClosure()
    }

}

/// A short form for the localized information.
public typealias LocInfo = LocalizedInformation
