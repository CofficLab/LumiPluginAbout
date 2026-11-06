// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "LumiPluginAppDirectory",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "PluginAppDirectory",
            targets: ["PluginAppDirectory"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/CofficLab/LumiKernel.git", from: "1.1.0"),
        .package(url: "https://github.com/CofficLab/LumiLogging.git", from: "1.0.1"),
        .package(url: "https://github.com/CofficLab/LumiSettings.git", from: "1.1.0"),
        .package(url: "https://github.com/CofficLab/LumiUI.git", from: "1.12.0"),
        .package(url: "https://github.com/CofficLab/LumiLocalization.git", from: "1.0.1"),
    ],
    targets: [
        .target(
            name: "PluginAppDirectory",
            dependencies: [
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "LumiLoggingKit", package: "LumiLogging"),
                .product(name: "ProviderSettingView", package: "LumiSettings"),
                .product(name: "LumiUI", package: "LumiUI"),
                .product(name: "LumiLocalizationKit", package: "LumiLocalization"),
            ],
            path: "Sources/PluginAppDirectory",
            resources: [.process("../../Resources/Localizable.xcstrings")]
        ),
        .testTarget(
            name: "PluginAppDirectoryTests",
            dependencies: [
                "PluginAppDirectory",
                .product(name: "KernelCore", package: "LumiKernel"),
                .product(name: "ProviderSettingView", package: "LumiSettings"),
            ],
            path: "Tests/PluginAppDirectoryTests"
        ),
    ]
)
