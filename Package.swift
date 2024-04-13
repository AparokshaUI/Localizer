// swift-tools-version: 5.8
//
//  Package.swift
//  Localizer
//

import PackageDescription

let package = Package(
    name: "Localizer",
    dependencies: [
        .package(url: "https://github.com/AparokshaUI/Adwaita", from: "0.2.5"),
        .package(url: "https://github.com/AparokshaUI/Localized", from: "0.2.2"),
        .package(url: "https://github.com/jpsim/Yams", from: "5.0.6")
    ],
    targets: [
        .executableTarget(
            name: "Localizer",
            dependencies: [
                "Model",
                .product(name: "Adwaita", package: "Adwaita")
            ]
        ),
        .target(
            name: "Model",
            dependencies: [
                .product(name: "Localized", package: "Localized"),
                .product(name: "Yams", package: "Yams")
            ],
            resources: [
                .process("Localized.yml")
            ],
            plugins: [
                .plugin(name: "GenerateLocalized", package: "Localized")
            ]
        )
    ]
)
