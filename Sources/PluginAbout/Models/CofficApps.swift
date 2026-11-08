import Foundation

/// Coffic Lab 官方应用目录。
///
/// 目录是编译期固定的静态数据：产品列表变化频率极低（按月计），走网络请求
/// 反而会带来「设置页在离线时是空的」这种负体验。
public enum CofficApps {
    /// 全部条目（应用与网站混排；数组顺序即页面上从上到下的顺序）。
    public static let all: [CofficApp] = [
        CofficApp(
            id: "lumi",
            nameKey: "Lumi",
            taglineKey: "An AI-powered personal desktop assistant for macOS",
            systemImage: "sparkles",
            urlString: "https://coffic.cn/lumi"
        ),
        CofficApp(
            id: "gitok",
            nameKey: "GitOK",
            taglineKey: "Project management on macOS",
            // `git-branch` 不是有效的 SF Symbol（SwiftUI 会静默渲染空白），
            // 分支图标的正确名称是 `arrow.triangle.branch`。
            systemImage: "arrow.triangle.branch",
            urlString: "https://coffic.cn/gitok"
        ),
        CofficApp(
            id: "wakey",
            nameKey: "Wakey",
            taglineKey: "Keep your Mac awake",
            systemImage: "cup.and.saucer.fill",
            urlString: "https://coffic.cn/wakey"
        ),
        CofficApp(
            id: "travelmode",
            nameKey: "TravelMode",
            taglineKey: "Control your network on macOS",
            systemImage: "network",
            urlString: "https://coffic.cn/travelmode"
        ),
        // 网站条目：不是可安装的 App，与其它产品同列展示，行内带「网站」标签。
        // 位置按产品线自然穿插，不放在列表末尾，避免被读成「附录」。
        CofficApp(
            id: "kuzee",
            nameKey: "Kuzee",
            taglineKey: "Pursuing the Pure Light of Knowledge",
            systemImage: "lightbulb",
            urlString: "https://kuaiyizhi.cn",
            kind: .website
        ),
        CofficApp(
            id: "booklet-maker",
            nameKey: "BookletMaker",
            taglineKey: "Turn a PDF into a fold-and-staple booklet",
            systemImage: "book.closed",
            urlString: "https://coffic.cn/booklet"
        ),
        CofficApp(
            id: "benchly",
            nameKey: "Benchly",
            taglineKey: "Local CPU, memory and disk benchmarks",
            systemImage: "speedometer",
            urlString: "https://coffic.cn/benchly"
        )
    ]

    /// 应用条目。
    public static var apps: [CofficApp] {
        all.filter { $0.kind == .app }
    }

    /// 网站条目。
    public static var websites: [CofficApp] {
        all.filter { $0.kind == .website }
    }

    /// 「全部产品」入口。
    public static let allProductsURLString = "https://coffic.cn/products"

    /// 无障碍声明入口。
    public static let accessibilityURLString = "https://coffic.cn/accessibility"

    /// AI 使用说明入口。
    public static let aiUsageURLString = "https://coffic.cn/ai-usage"
}
