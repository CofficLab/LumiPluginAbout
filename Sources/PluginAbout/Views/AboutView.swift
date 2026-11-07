import LumiUI
import SwiftUI

/// 「关于」页详情视图。
///
/// 两个分组：
/// - **我们的产品**：Coffic Lab 旗下应用与网站，按目录顺序混排；网站条目
///   在名称右侧带一个「网站」标签，说明它不是可安装的 App；
/// - **关于我们**：宿主自己的官网、隐私政策、服务条款，以及无障碍与 AI 使用说明。
///
/// 行一律作为 `AppSettingSection` 的直接子元素（不套 `VStack`）：
/// - macOS：section 内部是 `VStack(spacing: 12)`，行间自动留白；
/// - iOS：section 内部是 `VStack(spacing: 0)`，靠 `AppSettingRow`
///   自带的发丝分隔线区分行（再画一条会变成双线）。
public struct AboutView: View {
    /// 全部产品条目（应用与网站混排）。
    private let entries: [CofficApp]

    /// 宿主配置（官网与法律链接）。
    private let configuration: AboutConfiguration

    /// 「全部产品」入口地址。
    private let allProductsURLString: String

    // MARK: - 文案

    private var ourProductsTitle: String { pluginLocalization.string("Our Products") }
    private var websiteBadgeTitle: String { pluginLocalization.string("Website") }
    private var allProductsTitle: String { pluginLocalization.string("All Products") }
    private var allProductsDescription: String { pluginLocalization.string("Browse the full product catalog on the web.") }
    private var aboutUsTitle: String { pluginLocalization.string("About Us") }
    private var officialWebsiteTitle: String { pluginLocalization.string("Official Website") }
    private var privacyPolicyTitle: String { pluginLocalization.string("Privacy Policy") }
    private var termsOfServiceTitle: String { pluginLocalization.string("Terms of Service") }
    private var accessibilityTitle: String { pluginLocalization.string("Accessibility") }
    private var aiUsageTitle: String { pluginLocalization.string("AI Usage") }

    @Environment(\.openURL) private var openURL

    public init(
        configuration: AboutConfiguration,
        entries: [CofficApp] = CofficApps.all,
        allProductsURLString: String = CofficApps.allProductsURLString
    ) {
        self.configuration = configuration
        self.entries = entries
        self.allProductsURLString = allProductsURLString
    }

    public var body: some View {
        AppSettingsContentScaffold(maxContentWidth: nil) {
            VStack(alignment: .leading, spacing: 16) {
                ourProductsSection
                aboutUsSection
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Sections

    /// 「我们的产品」分组：应用与网站同列，顺序由目录决定。
    private var ourProductsSection: some View {
        AppSettingSection(title: ourProductsTitle) {
            ForEach(entries) { entry in
                linkRow(
                    title: pluginLocalization.string(entry.nameKey),
                    description: pluginLocalization.string(entry.taglineKey),
                    systemImage: entry.systemImage,
                    urlString: entry.urlString,
                    badge: entry.kind == .website ? websiteBadgeTitle : nil
                )
            }

            linkRow(
                title: allProductsTitle,
                description: allProductsDescription,
                systemImage: "square.grid.2x2",
                urlString: allProductsURLString
            )
        }
    }

    /// 「关于我们」分组：宿主自己的官网与法律链接。
    private var aboutUsSection: some View {
        AppSettingSection(title: aboutUsTitle) {
            linkRow(
                title: officialWebsiteTitle,
                description: hostDescription(for: configuration.officialWebsiteURLString),
                systemImage: "globe",
                urlString: configuration.officialWebsiteURLString
            )

            if let privacyURL = configuration.privacyPolicyURLString {
                linkRow(
                    title: privacyPolicyTitle,
                    description: hostDescription(for: privacyURL),
                    systemImage: "hand.raised",
                    urlString: privacyURL
                )
            }

            if let termsURL = configuration.termsOfServiceURLString {
                linkRow(
                    title: termsOfServiceTitle,
                    description: hostDescription(for: termsURL),
                    systemImage: "doc.text",
                    urlString: termsURL
                )
            }

            linkRow(
                title: accessibilityTitle,
                description: hostDescription(for: CofficApps.accessibilityURLString),
                systemImage: "accessibility",
                urlString: CofficApps.accessibilityURLString
            )

            linkRow(
                title: aiUsageTitle,
                description: hostDescription(for: CofficApps.aiUsageURLString),
                systemImage: "sparkles",
                urlString: CofficApps.aiUsageURLString
            )
        }
    }

    // MARK: - Rows

    /// 通用链接行：图标 + 标题 / 说明 + 跳转箭头。
    ///
    /// - Parameter badge: 名称右侧的标签（网站条目用），为空时不占位。
    private func linkRow(
        title: String,
        description: String,
        systemImage: String,
        urlString: String,
        badge: String? = nil
    ) -> some View {
        AppSettingRow(
            title: title,
            description: description,
            icon: systemImage,
            titleSuffix: {
                if let badge {
                    Text(badge)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            },
            action: { open(urlString) }
        ) {
            Image(systemName: "arrow.up.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Helpers

    /// 行内展示的地址文本：去掉 `https://` 前缀，让用户一眼看清域名与路径。
    private func hostDescription(for urlString: String) -> String {
        urlString.replacingOccurrences(of: "https://", with: "")
    }

    /// 在默认浏览器中打开链接。
    private func open(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        openURL(url)
    }
}

#Preview {
    AboutView(
        configuration: AboutConfiguration(
            officialWebsiteURLString: "https://coffic.cn/cisum",
            privacyPolicyURLString: "https://coffic.cn/privacy",
            termsOfServiceURLString: "https://coffic.cn/terms"
        )
    )
    .padding()
    .frame(width: 460)
}
