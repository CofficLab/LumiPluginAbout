import Foundation

/// 「关于」页的分组顺序。
///
/// 顺序是产品决策，不是实现细节，因此显式建模成可断言的数据：
/// 「关于我们」在前，「我们的产品」沉到页面最底部。
///
/// `allCases` 的声明顺序即页面从上到下的顺序，改动这里就是改页面结构。
public enum AboutSection: String, CaseIterable, Sendable {
    /// 关于我们：宿主自己的官网、隐私政策、服务条款与声明。
    case aboutUs

    /// 我们的产品：Coffic Lab 旗下应用与网站。
    case ourProducts
}
