// swift-tools-version: 5.5

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "NoteFlier",
    platforms: [
        .iOS("15.2")
    ],
    products: [
        .iOSApplication(
            name: "NoteFlier",
            targets: ["AppModule"],
            bundleIdentifier: "to.itstheguy.NoteFlier",
            teamIdentifier: "5Y5W2JVDEP",
            displayVersion: "0.1",
            bundleVersion: "1",
            iconAssetName: "AppIcon",
            accentColorAssetName: "AccentColor",
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
            exclude: ["README.md"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)