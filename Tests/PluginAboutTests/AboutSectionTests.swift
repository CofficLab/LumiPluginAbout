import Foundation
import Testing
@testable import PluginAbout

/// 「关于」页分组顺序的契约测试。
///
/// 分组顺序是产品决策，不是实现细节：页面底部必须留给「我们的产品」，
/// 上方才是关于本应用自身的信息。这条断言防止后来者顺手把两个分组换回去。
struct AboutSectionTests {
    /// 「关于我们」在前，「我们的产品」在后。
    @Test
    func aboutUsComesBeforeOurProducts() throws {
        let order = AboutSection.allCases
        let aboutUsIndex = try #require(order.firstIndex(of: .aboutUs))
        let ourProductsIndex = try #require(order.firstIndex(of: .ourProducts))
        #expect(aboutUsIndex < ourProductsIndex)
    }

    /// 「我们的产品」必须落在最后一个位置（页面最底部）。
    @Test
    func ourProductsIsTheLastSection() {
        #expect(AboutSection.allCases.last == .ourProducts)
    }

    /// 分组枚举的原始值必须稳定：它们可能被用于深链与持久化标识。
    @Test
    func rawValuesAreStable() {
        #expect(AboutSection.aboutUs.rawValue == "aboutUs")
        #expect(AboutSection.ourProducts.rawValue == "ourProducts")
    }
}
