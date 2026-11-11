# LumiPluginAbout

📖 English | [中文版](README_zh.md)

Shared **remote package** for the "About" plugin, consumed by Lumi family sibling apps such as Lumi / Cisum / GameFactory / GitOK / Wakey.

It injects a standalone "About" entry into the host settings interface. The page contains two sections (top to bottom):

- **About Us**: the host's own official website, privacy policy, terms of service, plus accessibility and AI usage statements;
- **Our Products**: other apps under Lumi Softworks, each linking to its product page on the official website.

> **Important rule: this plugin package must not depend on other plugin packages, and must not be depended on by other plugin packages.**
>
> Plugins communicate only through Provider contracts: shared capabilities go into `Provider*` / `Kit*` packages, assembled uniformly by the host (`Factory*`); cross-plugin references break independent plugin assembly and uninstallation.

## Package

- Manifest package name: `LumiPluginAbout` (matches the repository name, per the remote plugin package naming convention)
- Product / Target: `PluginAbout` (without the `Lumi` prefix)
- Platform: macOS 14+ / iOS 17+
- Swift tools: 6.0

## Naming Convention

Lumi Softworks remote plugin packages follow this convention uniformly:

| Repository | manifest `name:` | product / target |
| --- | --- | --- |
| `LumiPluginAbout` | `LumiPluginAbout` | `PluginAbout` |
| `LumiPluginPluginManager` | `LumiPluginPluginManager` | `PluginPluginManager` |
| `LumiPluginActivityBar` | `LumiPluginActivityBar` | `PluginActivityBar` |
| `LumiPluginToast` | `LumiPluginToast` | `PluginToast` |

Why: Xcode's package dependency list shows the upstream manifest's `Package(name:)`, not the repository name. Without the `Lumi` prefix in the manifest package name, users would not see the prefix in Xcode. The repository name stays consistent with the package name, and the consumer's `.product(name:package:)` `package:` argument matches the URL basename, so it must be the repository name.

## What It Provides

- An "About" settings entry (injected via `ProviderSettingView`)
- An "About Us" section: host official website, privacy policy, terms of service, accessibility and AI usage statements
- An "Our Products" section: one row per app (icon + brand name + one-line intro), tapping jumps to the official website
- An "All Products" entry: points to the full product catalog page on the official website

## Page Structure

The page has exactly two sections, ordered by `AboutSection.allCases`:

| Order | Section | Content |
| --- | --- | --- |
| 1 | `aboutUs` | Information about this app itself (website, privacy, terms, statements) |
| 2 | `ourProducts` | Lumi Softworks' other products (pushed to the very bottom of the page) |

"Our Products" sits at the bottom: it presents other products from the same lab rather than information about the app the user is currently in — putting it first would drown out the page's actual subject. The order is declared by the `AboutSection` enum, so changing the enum changes the page structure, and `Tests/PluginAboutTests/AboutSectionTests.swift` guards this decision.

## Host Configuration

The "About Us" section content varies by host and must be injected by the host:

```swift
AboutConfiguration(
    officialWebsiteURLString: "https://coffic.cn/cisum",
    privacyPolicyURLString: "https://coffic.cn/privacy",
    termsOfServiceURLString: "https://coffic.cn/terms"
)
```

- `officialWebsiteURLString`: **required**, the host's own product page URL.
- `privacyPolicyURLString` / `termsOfServiceURLString`: optional; when absent, the corresponding row is not shown.

`CofficApps.all` (the list of Lumi family apps) is identical for all hosts and maintained by this package.

## Dependencies and Integration

```swift
dependencies: [
    .package(url: "https://github.com/lumi-softworks/LumiPluginAbout.git", from: "2.0.0"),
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "PluginAbout", package: "LumiPluginAbout"),
        ],
    ),
]
```

Note that `package:` must be the repository name `LumiPluginAbout`, not the product name.

The host also needs to assemble this plugin in its Factory:

```swift
import PluginAbout

plugins.append(
    AboutPlugin(
        id: "com.coffic.cisum.plugin.about",
        configuration: AboutConfiguration(
            officialWebsiteURLString: "https://coffic.cn/cisum",
            privacyPolicyURLString: "https://coffic.cn/privacy",
            termsOfServiceURLString: "https://coffic.cn/terms"
        )
    )
)
```

## Branding: Inject Your Own Plugin ID

Host apps can reuse this package with their own brand ID (consistent with the `PluginPluginManager` / `PluginStorage` approach). When not passed, the default `com.coffic.lumi.plugin.about` is used.

```swift
AboutPlugin(id: "com.coffic.wakey.plugin.about", configuration: ...)
```

After injection, the following follow along:

| Location | Value |
| --- | --- |
| `AboutPlugin.id` | Injected ID |
| `AboutPlugin.metadata.id` | Injected ID |
| Log subsystem (`Logger`) | Injected ID |

The settings entry ID is always `"about"` (brand-independent, for settings deep links).

> Changing the ID also changes the plugin's enabled-state storage key: before switching IDs, hosts should confirm whether historical state needs migration.

## Enable Policy

Defaults to `.alwaysOn`: the About page is the app's identity page, which hosts almost always need.

If the host does not want it to appear, pass `.disabled` — the kernel will completely exclude this plugin at startup, and its contributed settings entry disappears with it:

```swift
AboutPlugin(configuration: ..., policy: .disabled)
```

## Link Handling

The detail view opens links via SwiftUI's `openURL` environment value, which is naturally cross-platform (including visionOS) and needs no AppKit / UIKit branching — `UIApplication.shared.open` is unavailable on visionOS.

## Catalog Data

The app list is **static data fixed at compile time** (`CofficApps.all`). The product list changes very rarely (on the order of months); going through network requests would instead bring the negative experience of "the settings page is empty when offline".

Links use official website short addresses (`https://coffic.cn/lumi`, `https://coffic.cn/gitok`, etc.); the site's short paths redirect to the corresponding language product page based on browser language.

To add an app: append a `CofficApp` entry in `Sources/PluginAbout/Models/CofficApps.swift`, and add translations of the intro key in all five languages in `Resources/Localizable.xcstrings`. Tests guard the bottom line that "every intro key must have a Chinese translation".

## Testing

From this package directory:

```sh
swift test
```

Tests cover entry registration and withdrawal, brand ID injection, host website injection, catalog data contracts (unique IDs, valid URLs), and the bottom line that "every string has a Chinese translation in the string catalog". See `Tests/TestPlan.md` for details.
