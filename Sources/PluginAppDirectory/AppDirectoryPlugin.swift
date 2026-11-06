import KernelCore
import LumiLoggingKit
import ProviderSettingView
import SwiftUI
import os

/// Coffic 应用目录插件。
///
/// 在宿主设置界面注入一个独立入口，点击后展示 Coffic Lab 旗下其他应用，
/// 每款应用链接到官网的对应产品页。
///
/// 宿主可注入自己的品牌 id 复用本包（与 `PluginPluginManager` / `PluginStorage`
/// 的做法一致）。
@MainActor
public final class AppDirectoryPlugin: SuperPlugin, SuperLog {
    /// 默认插件标识。宿主可在装配时传入自己的 id。
    public static let defaultPluginID = "com.coffic.lumi.plugin.app-directory"

    /// 插件唯一标识。宿主可注入自己的品牌 id。
    public let id: String

    /// 插件加载顺序。排在通用设置之后，避免抢在宿主自己的核心入口前面。
    public let order = 95

    /// 插件元信息。
    public let metadata: PluginMetadata

    /// 日志子系统跟随插件 id，便于宿主在系统日志中区分品牌。
    nonisolated let logger: Logger

    /// 设置入口的稳定 ID。恒为固定值（与品牌无关），供设置深链使用。
    public static let settingsEntryID = "app-directory"

    /// 插件自身的启用策略。
    ///
    /// 默认 `.alwaysOn`：应用目录是「我们的其它作品」入口，宿主几乎总是
    /// 需要它。宿主若不希望它出现，可传 `.disabled` —— 内核启动时会彻底
    /// 排除这个插件，入口也随之消失。
    public let policy: PluginEnablePolicy

    /// 创建应用目录插件。
    ///
    /// - Parameters:
    ///   - id: 插件唯一标识，决定 `PluginMetadata.id` 与日志子系统。
    ///   - policy: 插件自身的启用策略。
    public init(
        id: String = AppDirectoryPlugin.defaultPluginID,
        policy: PluginEnablePolicy = .alwaysOn
    ) {
        self.id = id
        self.policy = policy
        self.metadata = PluginMetadata(
            id: id,
            name: pluginLocalization.string("Our Apps"),
            description: pluginLocalization.string("Explore more apps developed by Coffic Lab."),
            version: "1.0.0",
            category: .general,
            stage: .stable,
            policy: policy
        )
        self.logger = Logger(subsystem: id, category: "AppDirectory")
    }

    // MARK: - Lifecycle

    public func onBoot(kernel: KernelCoreContainer) throws {
        guard let settings = kernel.resolveProvider((any SettingViewProviding).self) else {
            logger.error("\(Self.t) SettingViewProviding not found, settings entry skipped")
            return
        }

        let entry = SettingEntryItem(
            id: Self.settingsEntryID,
            title: pluginLocalization.string("Our Apps"),
            systemImage: "square.grid.2x2",
            order: 95
        ) {
            AppDirectoryView()
        }
        settings.addEntries([entry])
    }

    public func onShutdown(kernel: KernelCoreContainer) throws {
        kernel.resolveProvider((any SettingViewProviding).self)?
            .removeEntries(ids: [Self.settingsEntryID])
    }
}
