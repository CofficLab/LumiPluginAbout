import LumiUI
import SwiftUI

/// 「Coffic 应用目录」详情视图：列出 Coffic Lab 旗下其他应用。
///
/// 每行左侧为应用图标，中间为品牌名与一句话简介，右侧为跳转箭头——
/// 与其它设置页的行式表达保持一致。
public struct AppDirectoryView: View {
    /// 应用列表（展示顺序即列表顺序）。
    private let apps: [CofficApp]

    /// 「全部产品」入口地址。
    private let allProductsURLString: String

    /// 应用列表标题。
    private let title: String

    /// 区块下方的说明文案。
    private let footer: String

    /// 「全部产品」入口标题。
    private let allProductsTitle: String

    /// 「全部产品」入口说明。
    private let allProductsDescription: String

    @Environment(\.openURL) private var openURL

    public init(
        apps: [CofficApp] = CofficApps.all,
        allProductsURLString: String = CofficApps.allProductsURLString
    ) {
        self.apps = apps
        self.allProductsURLString = allProductsURLString
        self.title = pluginLocalization.string("Our Apps")
        self.footer = pluginLocalization.string("Explore more apps developed by Coffic Lab.")
        self.allProductsTitle = pluginLocalization.string("All Products")
        self.allProductsDescription = pluginLocalization.string("Browse the full product catalog on the web.")
    }

    public var body: some View {
        AppSettingSection(title: title, footer: footer) {
            VStack(spacing: 0) {
                ForEach(Array(apps.enumerated()), id: \.element.id) { index, app in
                    if index > 0 {
                        Divider()
                            .padding(.vertical, 8)
                    }

                    appRow(app)
                }

                Divider()
                    .padding(.vertical, 8)

                linkRow(
                    title: allProductsTitle,
                    description: allProductsDescription,
                    systemImage: "square.grid.2x2",
                    urlString: allProductsURLString
                )
            }
        }
    }

    // MARK: - Rows

    /// 单个应用行：图标 + 品牌名 / 简介 + 跳转箭头。
    private func appRow(_ app: CofficApp) -> some View {
        linkRow(
            title: app.name,
            description: pluginLocalization.string(app.taglineKey),
            systemImage: app.systemImage,
            urlString: app.urlString
        )
    }

    /// 通用链接行。
    private func linkRow(
        title: String,
        description: String,
        systemImage: String,
        urlString: String
    ) -> some View {
        AppSettingRow(
            title: title,
            description: description,
            icon: systemImage,
            action: { open(urlString) }
        ) {
            Image(systemName: "arrow.up.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Actions

    /// 在默认浏览器中打开链接。
    private func open(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        openURL(url)
    }
}

#Preview {
    AppDirectoryView()
        .padding()
        .frame(width: 460)
}
