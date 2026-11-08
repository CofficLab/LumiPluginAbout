import Foundation
import Testing
#if canImport(AppKit)
import AppKit
#endif
@testable import PluginAbout

/// 应用目录的数据契约测试。
///
/// 这些断言守的是「用户点到的链接必须真的存在」——目录里写错一个
/// slug，用户点下去就是 404。
struct CofficAppsTests {
    @Test
    func catalogContainsExpectedApps() {
        let ids = CofficApps.all.map(\.id)
        #expect(ids.contains("lumi"))
        #expect(ids.contains("gitok"))
        #expect(ids.contains("wakey"))
        #expect(ids.contains("benchly"))
    }

    @Test
    func appIdentifiersAreUnique() {
        let ids = CofficApps.all.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test
    func everyAppUsesHttpsCofficURL() throws {
        for app in CofficApps.apps {
            let url = try #require(URL(string: app.urlString))
            #expect(url.scheme == "https")
            #expect(url.host == "coffic.cn")
        }
    }

    /// 网站条目与 App 条目必须能区分开，页面上才能给网站行加标签。
    @Test
    func websiteEntriesAreMarkedWithWebsiteKind() {
        #expect(CofficApps.apps.allSatisfy { $0.kind == .app })
        #expect(CofficApps.websites.allSatisfy { $0.kind == .website })
        #expect(CofficApps.apps.count + CofficApps.websites.count == CofficApps.all.count)
    }

    /// 网站与 App 同列展示，网站不能排在末尾——否则读起来像附录而不是产品。
    @Test
    func websiteEntryIsNotPushedToTheEnd() throws {
        let index = try #require(CofficApps.all.firstIndex { $0.kind == .website })
        #expect(index > 0)
        #expect(index < CofficApps.all.count - 1)
    }

    /// 网站条目指向站点首页，不得混入 App 的官网路径。
    @Test
    func websiteEntryPointsToKuzee() throws {
        let kuzee = try #require(CofficApps.websites.first { $0.id == "kuzee" })
        #expect(kuzee.nameKey == "Kuzee")

        let url = try #require(URL(string: kuzee.urlString))
        #expect(url.absoluteString == "https://kuaiyizhi.cn")
        #expect(url.scheme == "https")
        #expect(url.host == "kuaiyizhi.cn")
    }

    /// 网站名称必须随系统语言切换：中文显示「快易知」，英文显示 Kuzee。
    ///
    /// 直接读编译产物里的各语言 `.lproj`，断言的是用户实际会看到的文案，
    /// 而不是「catalog 里存在这个 key」。
    @Test
    func websiteNameFollowsSystemLanguage() throws {
        let kuzee = try #require(CofficApps.websites.first { $0.id == "kuzee" })

        for language in ["zh-Hans", "zh-Hant", "zh-HK", "zh-TW"] {
            #expect(try #require(Self.localizedIn(language: language, kuzee.nameKey)) == "快易知")
        }
        #expect(try #require(Self.localizedIn(language: "en", kuzee.nameKey)) == "Kuzee")
    }

    /// App 条目的名称不参与改写：各语言下都应保持品牌原拼写。
    ///
    /// 这些名称没有目录条目，运行时解析会回退为 key 本身——这里按中英文
    /// locale 各取一次，确认回退结果就是品牌名。
    /// 有正式中文名的条目（如「跑分匠」）由单独测试覆盖。
    @Test
    func appNamesStayBrandSpelling() {
        let localizedDisplayNames: Set<String> = ["benchly"]
        for app in CofficApps.apps where !localizedDisplayNames.contains(app.id) {
            #expect(pluginLocalization.string(app.nameKey, locale: Locale(identifier: "zh-Hans")) == app.nameKey)
            #expect(pluginLocalization.string(app.nameKey, locale: Locale(identifier: "en")) == app.nameKey)
        }
    }

    /// Benchly 有正式中文名「跑分匠」，必须随系统语言切换。
    @Test
    func benchlyHasChineseDisplayName() throws {
        let benchly = try #require(CofficApps.apps.first { $0.id == "benchly" })
        #expect(benchly.nameKey == "Benchly")
        #expect(benchly.urlString == "https://coffic.cn/benchly")

        for language in ["zh-Hans", "zh-Hant", "zh-HK", "zh-TW"] {
            #expect(try #require(Self.localizedIn(language: language, benchly.nameKey)) == "跑分匠")
        }
        #expect(try #require(Self.localizedIn(language: "en", benchly.nameKey)) == "Benchly")
    }

    @Test
    func allProductsEntryPointsToCatalogPage() throws {
        let url = try #require(URL(string: CofficApps.allProductsURLString))
        #expect(url.absoluteString == "https://coffic.cn/products")
    }

    /// 关于页的无障碍与 AI 使用说明入口必须指向真实页面。
    ///
    /// 两条链接统一走 `coffic.cn`，不带 `www`：同页里出现两种域名写法
    /// 会让人怀疑是不是两个站点。
    @Test
    func statementEntryPointsToCofficPages() throws {
        let accessibility = try #require(URL(string: CofficApps.accessibilityURLString))
        #expect(accessibility.absoluteString == "https://coffic.cn/accessibility")
        #expect(accessibility.scheme == "https")
        #expect(accessibility.host == "coffic.cn")

        let aiUsage = try #require(URL(string: CofficApps.aiUsageURLString))
        #expect(aiUsage.absoluteString == "https://coffic.cn/ai-usage")
        #expect(aiUsage.scheme == "https")
        #expect(aiUsage.host == "coffic.cn")
    }

    /// 每个应用都必须有名字、图标和简介 key——缺一项列表里就会出现空行。
    @Test
    func everyAppHasCompletePresentationData() {
        for app in CofficApps.all {
            #expect(!app.nameKey.isEmpty)
            #expect(!app.systemImage.isEmpty)
            #expect(!app.taglineKey.isEmpty)
        }
    }

    /// 图标名必须是真实存在的 SF Symbol。
    ///
    /// GitOK 曾写成不存在的 `git-branch`，`Image(systemName:)` 不会报错，
    /// 只是把这一行渲染成没有图标的空白——只能靠断言符号可解析来兜住。
    @Test
    func everySystemImageResolvesToRealSymbol() {
        #if canImport(AppKit)
        for app in CofficApps.all {
            #expect(
                NSImage(systemSymbolName: app.systemImage, accessibilityDescription: nil) != nil,
                "\(app.id) 的图标 \(app.systemImage) 不是有效的 SF Symbol"
            )
        }
        #endif
    }

    /// 已下架的产品不应再出现在列表里。
    @Test
    func retiredAppsAreRemoved() {
        let ids = Set(CofficApps.all.map(\.id))
        #expect(!ids.contains("juice-note"))
        #expect(!ids.contains("juice-editor"))
        #expect(!ids.contains("buddy"))
    }

    /// 每个应用的简介都必须在字符串目录里有中文译文，
    /// 否则中文用户会看到英文原句（甚至直接看到 key）。
    @Test
    func everyAppTaglineHasChineseTranslation() throws {
        for app in CofficApps.all {
            let translated = try #require(Self.localizedIn(language: "zh-Hans", app.taglineKey))
            #expect(translated != app.taglineKey)
        }
    }

    /// 区块标题、网站标签与「全部产品」入口也必须有中文译文。
    @Test
    func sectionStringsHaveChineseTranslation() throws {
        #expect(try #require(Self.localizedIn(language: "zh-Hans", "Our Products")) == "我们的产品")
        #expect(try #require(Self.localizedIn(language: "zh-Hans", "Website")) == "网站")
        #expect(try #require(Self.localizedIn(language: "zh-Hans", "All Products")) == "全部产品")
    }

    /// 繁体环境下区块标题与网站标签要写成繁体，不能回落到简体或英文。
    @Test
    func sectionStringsHaveTraditionalChineseTranslation() throws {
        for language in ["zh-Hant", "zh-HK", "zh-TW"] {
            #expect(try #require(Self.localizedIn(language: language, "Our Products")) == "我們的產品")
            #expect(try #require(Self.localizedIn(language: language, "Website")) == "網站")
        }
    }

    /// 「关于」页新增的法律链接文案也必须有中文译文。
    @Test
    func aboutStringsHaveChineseTranslation() throws {
        #expect(try #require(Self.localizedIn(language: "zh-Hans", "About")) == "关于")
        #expect(try #require(Self.localizedIn(language: "zh-Hans", "About Us")) == "关于我们")
        #expect(try #require(Self.localizedIn(language: "zh-Hans", "Official Website")) == "官方网站")
        #expect(try #require(Self.localizedIn(language: "zh-Hans", "Privacy Policy")) == "隐私政策")
        #expect(try #require(Self.localizedIn(language: "zh-Hans", "Terms of Service")) == "服务条款")
        #expect(try #require(Self.localizedIn(language: "zh-Hans", "Accessibility")) == "无障碍")
        #expect(try #require(Self.localizedIn(language: "zh-Hans", "AI Usage")) == "AI 使用说明")
    }

    /// 按编译产物里的 `.lproj` 解析字符串，验证译文确实被打包进去。
    private static func localizedIn(language: String, _ key: String) -> String? {
        guard let path = Bundle.module.path(forResource: language, ofType: "lproj"),
              let languageBundle = Bundle(path: path) else { return nil }
        let value = languageBundle.localizedString(forKey: key, value: "\u{FFFF}", table: "Localizable")
        return value == "\u{FFFF}" ? nil : value
    }
}
