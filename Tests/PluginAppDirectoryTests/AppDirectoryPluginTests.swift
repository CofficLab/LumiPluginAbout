import Foundation
import KernelCore
import ProviderSettingView
import Testing
@testable import PluginAppDirectory

/// 插件入口的生命周期测试：注册、撤回、品牌 id 注入。
@MainActor
struct AppDirectoryPluginTests {
    /// 启动时必须把「我们的应用」入口登记到设置 Provider 上。
    @Test
    func bootRegistersSettingsEntry() throws {
        let kernel = KernelCoreContainer()
        let settings = DefaultSettingViewProviding()
        try kernel.registerProvider((any SettingViewProviding).self, settings)

        let plugin = AppDirectoryPlugin()
        try plugin.onBoot(kernel: kernel)

        let entry = try #require(settings.entries.first { $0.id == AppDirectoryPlugin.settingsEntryID })
        #expect(entry.systemImage == "square.grid.2x2")
    }

    /// 关闭时必须撤回入口——否则设置窗口里会留下一个点不动的入口。
    @Test
    func shutdownRemovesSettingsEntry() throws {
        let kernel = KernelCoreContainer()
        let settings = DefaultSettingViewProviding()
        try kernel.registerProvider((any SettingViewProviding).self, settings)

        let plugin = AppDirectoryPlugin()
        try plugin.onBoot(kernel: kernel)
        #expect(settings.entries.contains { $0.id == AppDirectoryPlugin.settingsEntryID })

        try plugin.onShutdown(kernel: kernel)
        #expect(!settings.entries.contains { $0.id == AppDirectoryPlugin.settingsEntryID })
    }

    /// 宿主注入品牌 id 后，插件 id 与元信息 id 同步跟随。
    @Test
    func hostCanInjectBrandID() {
        let plugin = AppDirectoryPlugin(id: "com.coffic.cisum.plugin.app-directory")
        #expect(plugin.id == "com.coffic.cisum.plugin.app-directory")
        #expect(plugin.metadata.id == "com.coffic.cisum.plugin.app-directory")
    }

    /// 默认 id 供未注入品牌的宿主使用。
    @Test
    func defaultIDIsUsedWhenNoBrandInjected() {
        let plugin = AppDirectoryPlugin()
        #expect(plugin.id == AppDirectoryPlugin.defaultPluginID)
        #expect(plugin.metadata.id == AppDirectoryPlugin.defaultPluginID)
    }

    /// 设置入口 id 与品牌无关：深链地址在所有宿主里保持一致。
    @Test
    func settingsEntryIDIsBrandIndependent() {
        let branded = AppDirectoryPlugin(id: "com.coffic.cisum.plugin.app-directory")
        let generic = AppDirectoryPlugin()
        #expect(AppDirectoryPlugin.settingsEntryID == "app-directory")
    }

    /// 宿主没有注册设置 Provider 时优雅降级，不应抛错。
    @Test
    func bootWithoutSettingsProviderDoesNotThrow() throws {
        let kernel = KernelCoreContainer()
        let plugin = AppDirectoryPlugin()
        try plugin.onBoot(kernel: kernel)
    }

    /// 禁用策略会写进元信息，宿主据此让内核彻底排除插件。
    @Test
    func policyIsReflectedInMetadata() {
        let plugin = AppDirectoryPlugin(policy: .disabled)
        #expect(plugin.metadata.policy == .disabled)
        #expect(plugin.policy == .disabled)
    }
}
