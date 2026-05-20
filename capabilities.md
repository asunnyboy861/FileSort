# FileSort — 配置文档

生成时间：2026-05-20

---

## 一、⚠️ 手动配置（需你操作才能生效）

### 🔴 Capabilities 配置

#### iCloud CloudKit Container

**影响功能**：不配置则 iCloud Drive 文件访问功能不可用

**已自动配置部分**：
- ✅ Xcode Signing & Capabilities 中已启用 iCloud
- ✅ .entitlements 中已添加 iCloud container identifiers（iCloud.com.zzoutuo.FileSort）

**仍需手动配置**：
1. 打开 [Apple Developer](https://developer.apple.com)
2. 进入 **Certificates, Identifiers & Profiles** → **Identifiers**
3. 找到 `com.zzoutuo.FileSort` → 点击编辑
4. 在 **iCloud** 下，确认 CloudKit container `iCloud.com.zzoutuo.FileSort` 已注册
5. 如果没有，点击 **"+"** 创建，Container ID 填写 `iCloud.com.zzoutuo.FileSort`
6. 回到 Xcode → **Signing & Capabilities** → **iCloud** → 确认 CloudKit container 已勾选
7. ⚠️ 配置完成后需要重新 Build 验证

#### App Group Container

**影响功能**：不配置则 Widget 小组件无法与主应用共享数据

**已自动配置部分**：
- ✅ Widget 代码已创建（FileSortWidget.swift）

**仍需手动配置**：
1. 打开 [Apple Developer](https://developer.apple.com)
2. 进入 **Certificates, Identifiers & Profiles** → **Identifiers**
3. 找到 `com.zzoutuo.FileSort` → 点击编辑
4. 在 **App Groups** 下，点击 **"+"** 创建，Group ID 填写 `group.com.zzoutuo.FileSort`
5. 如果有 Widget Extension target（如 `com.zzoutuo.FileSort.Widget`），同样为其启用 App Groups，勾选 `group.com.zzoutuo.FileSort`
6. 回到 Xcode → 主 target 和 Widget target 的 **Signing & Capabilities** → 确认 App Group 已勾选
7. ⚠️ 配置完成后需要重新 Build 验证

---

### 🔵 IAP StoreKit 配置

**影响功能**：不创建 IAP 产品则用户无法完成订阅购买

**配置步骤**：
1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 进入你的 App → **Features** → **In-App Purchases**
3. 点击 **"+"** 创建订阅组，名称填 `FileSort Premium`
4. 按以下信息创建订阅产品：

| 产品 | Reference Name | Product ID | 价格 |
|------|---------------|-----------|------|
| 月付 | Monthly Premium | `com.zzoutuo.FileSort.monthly` | $3.99/月 |
| 年付 | Yearly Premium | `com.zzoutuo.FileSort.yearly` | $19.99/年 |
| 终身 | Lifetime Access | `com.zzoutuo.FileSort.lifetime` | $39.99 一次性 |

5. 填写每个产品的 Display Name 和 Description（从 `price.md` 复制）
6. 为月付订阅添加 3 天免费试用
7. ⚠️ 创建后需要等待 Apple 审核（通常1-2小时）
8. 在 Xcode 中创建 StoreKit Configuration File（File → New → File → StoreKit Configuration File）用于本地测试，添加上述 3 个 Product ID
9. 在 SettingsView 中点击 **"Restore Purchases"** 验证流程

---

### 🟢 App Store Connect 审核信息配置

**影响功能**：不配置则 Apple 审核员无法测试订阅功能，可能导致审核拒绝

**配置步骤**：
1. 在 App Store Connect → 你的 App → **App Review Information**
2. 在 **Notes** 字段中说明：此应用为文件自动整理工具，核心功能包括一键整理、规则引擎、重复文件检测。订阅解锁高级功能（自定义规则、重复检测、Widget、Shortcuts）
3. ⚠️ 确保 **Privacy Policy URL** 字段填写：`https://asunnyboy861.github.io/FileSort/privacy.html`
4. ⚠️ 确保 **Support URL** 字段填写：`https://asunnyboy861.github.io/FileSort/support.html`
5. ⚠️ 确保订阅产品的 **EULA** 或 App Description 中包含 Terms of Use 链接：`https://asunnyboy861.github.io/FileSort/terms.html`

---

## 二、✅ 自动配置记录（已由系统完成，无需操作）

### Capabilities 自动配置

| Capability | 说明 | 状态 |
|------------|------|------|
| iCloud (iCloud Drive) | Entitlements 已配置 iCloud container identifiers | ✅ 已配置 |
| In-App Purchase | Entitlements 已配置 IAP 权限 | ✅ 已配置 |
| File Access (User Selected) | Entitlements 已配置 com.apple.security.files.user-selected.read-write | ✅ 已配置 |
| Network (Outgoing) | Entitlements 已配置 com.apple.security.network.client | ✅ 已配置 |
| Photo Library | Info.plist 已配置 NSPhotoLibraryUsageDescription | ✅ 已配置 |
| Documents Folder | Info.plist 已配置 NSDocumentsFolderUsageDescription | ✅ 已配置 |
| App Intents (Siri/Shortcuts) | iOS 17+ 框架自带，无需 entitlement | ✅ 已配置 |
| Widget | FileSortWidget.swift 已创建 | ✅ 已配置 |

### 后端服务

| 服务 | 说明 | 状态 |
|------|------|------|
| GitHub Pages | 政策页面已部署至 asunnyboy861.github.io/FileSort | ✅ 已部署 |
| Landing Page | 已部署（App Store ID 为占位符，发布后替换） | ✅ 已部署 |
| Support Page | https://asunnyboy861.github.io/FileSort/support.html | ✅ 已部署 |
| Privacy Policy | https://asunnyboy861.github.io/FileSort/privacy.html | ✅ 已部署 |
| Terms of Use | https://asunnyboy861.github.io/FileSort/terms.html | ✅ 已部署 |

### 代码生成

| 模块 | 说明 | 状态 |
|------|------|------|
| 核心功能 | MVVM架构，文件扫描/规则引擎/文件移动/重复检测 | ✅ 已完成 |
| PurchaseManager | StoreKit 2 集成，3个订阅产品ID | ✅ 已完成 |
| PaywallView | 订阅页面，3档选择 | ✅ 已完成 |
| OnboardingView | 首次启动引导 | ✅ 已完成 |
| FileSortWidget | 主屏幕小组件 | ✅ 已完成 |
| FileSortIntents | Siri Shortcuts 集成 | ✅ 已完成 |
| SettingsView | 政策页面链接、客服入口 | ✅ 已完成 |
| QA迭代 | 质量保证循环已完成 | ✅ 已完成 |

### 部署

| 项目 | 说明 | 状态 |
|------|------|------|
| GitHub仓库 | 代码已推送至 github.com/asunnyboy861/FileSort | ✅ 已完成 |
| GitHub Pages | 政策页面已部署 | ✅ 已完成 |
| App Store元数据 | keytext.md 已生成验证 | ✅ 已完成 |
| 定价配置 | price.md 已生成 | ✅ 已完成 |

---

## 三、能力检测详情

### Analysis

Based on operation guide analysis, the following capabilities are required:
- "iCloud" / "同步" / "iCloud Drive" → iCloud capability
- "Widget" / "桌面小组件" → App Groups (for shared data)
- "订阅" / "会员" / "premium" / "Pro" → In-App Purchase
- "Shortcuts" / "快捷指令" / "Siri" → Siri/App Intents
- "照片" / "照片库" → Photo Library access
- "文件" / "Downloads" / "Documents" → File access

### No Configuration Needed

- HealthKit (not used)
- Location Services (not used)
- Camera (not used)
- Apple Watch (not used)
- Push Notifications (not used)
- Background Modes (not used)

### Verification

- Build succeeded on iPhone 16 Pro Max simulator: ✅
- Build succeeded on iPad Pro 13-inch (M4) simulator: ✅
- All entitlements correct: ✅
- Info.plist usage descriptions added: ✅
