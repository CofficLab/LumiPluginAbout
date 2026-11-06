# TestPlan — LumiPluginAppDirectory

## 包概述

Coffic 应用目录插件：在宿主设置界面注入「我们的应用」入口，展示 Coffic Lab
旗下其他应用，每款应用链接到官网的对应产品页。

公开类型:
- `AppDirectoryPlugin` — `@MainActor final class` conforming to `SuperPlugin, SuperLog`
- `AppDirectoryView` — 目录详情视图
- `CofficApp` / `CofficApps` — 应用目录数据模型与静态目录

## 测试用例清单

下表由 `Tests/` 下的真实 `@Test` 声明自动生成，方法名与代码一一对应。

| ID | 类别 | 描述 | 优先级 | 状态 | 测试文件 | 测试方法 |
|----|------|------|--------|------|----------|----------|
| 1 | 插件生命周期 | Boot registers the settings entry | P0 | ✅ 已覆盖 | `AppDirectoryPluginTests.swift` | `bootRegistersSettingsEntry` |
| 2 | 插件生命周期 | Shutdown removes the settings entry | P0 | ✅ 已覆盖 | `AppDirectoryPluginTests.swift` | `shutdownRemovesSettingsEntry` |
| 3 | 品牌化 | Host can inject brand ID | P0 | ✅ 已覆盖 | `AppDirectoryPluginTests.swift` | `hostCanInjectBrandID` |
| 4 | 品牌化 | Default ID is used when no brand injected | P1 | ✅ 已覆盖 | `AppDirectoryPluginTests.swift` | `defaultIDIsUsedWhenNoBrandInjected` |
| 5 | 品牌化 | Settings entry ID is brand independent | P1 | ✅ 已覆盖 | `AppDirectoryPluginTests.swift` | `settingsEntryIDIsBrandIndependent` |
| 6 | 退化路径 | Boot without settings provider does not throw | P1 | ✅ 已覆盖 | `AppDirectoryPluginTests.swift` | `bootWithoutSettingsProviderDoesNotThrow` |
| 7 | 策略 | Policy is reflected in metadata | P1 | ✅ 已覆盖 | `AppDirectoryPluginTests.swift` | `policyIsReflectedInMetadata` |
| 8 | 应用目录 | Catalog contains the expected apps | P0 | ✅ 已覆盖 | `CofficAppsTests.swift` | `catalogContainsExpectedApps` |
| 9 | 应用目录 | App identifiers are unique | P1 | ✅ 已覆盖 | `CofficAppsTests.swift` | `appIdentifiersAreUnique` |
| 10 | 应用目录 | Every app URL is a valid https coffic.cn link | P0 | ✅ 已覆盖 | `CofficAppsTests.swift` | `everyAppUsesHttpsCofficURL` |
| 11 | 应用目录 | "All Products" entry points at the product catalog page | P1 | ✅ 已覆盖 | `CofficAppsTests.swift` | `allProductsEntryPointsToCatalogPage` |
| 12 | 应用目录 | Every app has complete presentation data | P2 | ✅ 已覆盖 | `CofficAppsTests.swift` | `everyAppHasCompletePresentationData` |
| 13 | 国际化 | Every app tagline has a Chinese translation in the catalog | P0 | ✅ 已覆盖 | `CofficAppsTests.swift` | `everyAppTaglineHasChineseTranslation` |
| 14 | 国际化 | Section title and "All Products" have Chinese translations | P1 | ✅ 已覆盖 | `CofficAppsTests.swift` | `sectionStringsHaveChineseTranslation` |

## 覆盖率统计

- P0: 6 / 6 ✅
- P1: 7 / 7 ✅
- P2: 1 / 1 ✅

**总计: 14 / 14**（本包 `Tests/` 中已声明的 `@Test` 全部登记）

## 测试文件

- `AppDirectoryPluginTests.swift` — 7 条用例
- `CofficAppsTests.swift` — 7 条用例

## 优先级说明

- **P0**: 主路径行为（入口注册与撤回、品牌 id 注入、链接合法性）
- **P1**: 边界与退化（Provider 缺失、默认策略、id 唯一性）
- **P2**: 视图 / 布局 / 系统集成相关，依赖真实窗口或系统环境

## 跨平台说明

- 测试以 `swift test`（macOS 主机）运行为基准
- 视图层端到端行为需在 iOS 模拟器或真机验证，不在单测清单内
- 链接跳转使用 SwiftUI 的 `openURL` 环境值，天然跨平台（含 visionOS），
  不需要 AppKit / UIKit 分支

## 测试执行

```bash
cd LumiPluginAppDirectory
swift test
```

## 维护规则

1. **新增公开 API** → 先在 TestPlan 登记测试用例,再写实现
2. **Bug 修复** → 追加回归用例,标注触发条件
3. **删除用例** → 在 commit message 说明理由
4. **状态同步** → 实现后更新 TestPlan,标记 ✅ 并填写测试方法名
