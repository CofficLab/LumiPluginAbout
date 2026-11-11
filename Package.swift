// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LumiPluginAbout",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAbout",
            targets: ["PluginAbout"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/lumi-softworks/LumiKernel.git", from: "1.1.0"),
        .package(url: "https://github.com/lumi-softworks/LumiLogging.git", from: "1.0.1"),
        .package(url: "https://github.com/lumi-softworks/LumiSettings.git", from: "1.1.0"),
        .package(url: "https://github.com/lumi-softworks/LumiUI.git", from: "1.12.0"),
        .package(url: "https://github.com/lumi-softworks/LumiLocalization.git", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "PluginAbout",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiLoggingKit", package: "LumiLogging"),
                .product(name: "ProviderSettingView", package: "LumiSettings"),
                .product(name: "LumiUI", package: "LumiUI"),
                .product(name: "LumiLocalizationKit", package: "LumiLocalization"),
            ],
            path: "Sources/PluginAbout",
            resources: [.process("../../Resources/Localizable.xcstrings")]
        ),
        .testTarget(
            name: "PluginAboutTests",
            dependencies: [
                "PluginAbout",
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "ProviderSettingView", package: "LumiSettings"),
            ],
            path: "Tests/PluginAboutTests"
        ),
    ]
)
