# LumiPluginAppDirectory

Coffic 应用目录插件的**共享远程包**，供 Lumi / Cisum / GameFactory / GitOK / Wakey
等 CofficLab 兄弟应用共同消费。

在宿主设置界面注入一个独立入口「我们的应用」，展示 Coffic Lab 旗下其他应用，
每款应用链接到官网的对应产品页。

> **重要规则：本插件包不能依赖其他插件包，也不能被其他插件包依赖。**
>
> 插件之间只通过 Provider 契约通信：共享能力放入 `Provider*` / `Kit*` 包，
> 由宿主（`Factory*`）统一装配；跨插件互相引用会破坏插件的独立装配与卸载。

## Package

- Manifest 包名：`LumiPluginAppDirectory`（与仓库名一致，符合远程插件包命名规范）
- Product / Target：`PluginAppDirectory`（不带 `Lumi` 前缀）
- Platform: macOS 14+ / iOS 17+
- Swift tools: 6.0

## 命名规范

CofficLab 的远程插件包统一遵循：

| 仓库名 | manifest `name:` | product / target |
| --- | --- | --- |
| `LumiPluginAppDirectory` | `LumiPluginAppDirectory` | `PluginAppDirectory` |
| `LumiPluginPluginManager` | `LumiPluginPluginManager` | `PluginPluginManager` |
| `LumiPluginActivityBar` | `LumiPluginActivityBar` | `PluginActivityBar` |
| `LumiPluginToast` | `LumiPluginToast` | `PluginToast` |

理由：Xcode 的包依赖列表显示的是上游 manifest 里的 `Package(name:)`，不是仓库名。
manifest 包名不带 `Lumi` 前缀会让用户在 Xcode 里看不到前缀。仓库名保持与包名一致，
消费方 `.product(name:package:)` 的 `package:` 参数按 URL basename 匹配，必须写仓库名。

## 提供什么

- 「我们的应用」设置入口（通过 `ProviderSettingView` 注入）
- 应用目录详情视图：每行一款应用（图标 + 品牌名 + 一句话简介），点击跳转官网
- 「全部产品」入口：指向官网的完整产品目录页

## 目录数据

应用列表是**编译期固定的静态数据**（`CofficApps.all`）。产品列表变化频率极低
（按月计），走网络请求反而会带来「设置页在离线时是空的」这种负体验。

链接使用官网短地址（`https://coffic.cn/lumi`、`https://coffic.cn/gitok` 等），
站点的短路径会按浏览器语言跳转到对应语言的产品页。

新增一款应用：在 `Sources/PluginAppDirectory/Models/CofficApps.swift` 里追加一条
`CofficApp`，并在 `Resources/Localizable.xcstrings` 里补上简介 key 的五种语言译文。
测试会守住「每个简介 key 必须有中文译文」这条底线。

## 依赖与集成

```swift
dependencies: [
    .package(url: "https://github.com/CofficLab/LumiPluginAppDirectory.git", from: "1.0.0"),
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "PluginAppDirectory", package: "LumiPluginAppDirectory"),
        ],
    ),
]
```

注意 `package:` 必须是仓库名 `LumiPluginAppDirectory`，不是 product 名。

宿主还需要在 Factory 里装配这个插件：

```swift
import PluginAppDirectory

plugins.append(
    AppDirectoryPlugin(id: "com.coffic.cisum.plugin.app-directory")
)
```

## 品牌化：注入自己的插件 id

宿主应用可以用自己的品牌 id 复用本包（与 `PluginPluginManager` / `PluginStorage`
的做法一致）。不传参时使用默认的 `com.coffic.lumi.plugin.app-directory`。

```swift
AppDirectoryPlugin(id: "com.coffic.wakey.plugin.app-directory")
```

注入后以下两处同步跟随：

| 位置 | 取值 |
| --- | --- |
| `AppDirectoryPlugin.id` | 注入的 id |
| `AppDirectoryPlugin.metadata.id` | 注入的 id |
| 日志 subsystem（`Logger`） | 注入的 id |

设置入口 id 恒为 `"app-directory"`（与品牌无关，供设置深链使用）。

> 更换 id 会同时更换插件的启用状态存储键：宿主切换 id 前需确认历史状态是否需要迁移。

## 启用策略

默认 `.alwaysOn`：应用目录是「我们的其它作品」入口，宿主几乎总是需要它。

宿主若不希望它出现，可传 `.disabled` —— 内核启动时会彻底排除这个插件，
它贡献的设置入口也随之消失：

```swift
AppDirectoryPlugin(policy: .disabled)
```

## 链接跳转

详情视图用 SwiftUI 的 `openURL` 环境值打开链接，天然跨平台（含 visionOS），
不需要 AppKit / UIKit 分支——`UIApplication.shared.open` 在 visionOS 上不可用。

## Testing

From this package directory:

```sh
swift test
```

测试覆盖入口注册与撤回、品牌 id 注入、目录数据契约（id 唯一、URL 合法），
以及「每条文案在字符串目录里有中文译文」这条底线。详见 `Tests/TestPlan.md`。
