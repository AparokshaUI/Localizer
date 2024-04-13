//
//  String.swift
//  Localizer
//

extension String: Identifiable {

    /// The identifier for a string.
    public var id: Self { self }

    /// Parse the string as an input.
    public func parseInput() -> String {
        replacingOccurrences(of: "\"", with: "\\\\\\\"")
    }

}
