//
//  DestinationURL.swift
//  Localizer
//

import Foundation

/// The destination URL for navigation.
public enum DestinationURL: CustomStringConvertible {

    /// The overview.
    case overview
    /// The languages list.
    case languages
    /// The localization view.
    case localize(language: String)

    /// The title for a destination view.
    public var description: String {
        switch self {
        case .overview:
            Loc.overview
        case .languages:
            Loc.languages(count: "undefined")
        case let .localize(language):
            Loc.localizeLanguage(language: language)
        }
    }

}
