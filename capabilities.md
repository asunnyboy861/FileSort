# Capabilities Configuration

## Analysis
Based on operation guide analysis, the following capabilities are required:
- "iCloud" / "同步" / "iCloud Drive" → iCloud capability
- "Widget" / "桌面小组件" → App Groups (for shared data)
- "订阅" / "会员" / "premium" / "Pro" → In-App Purchase
- "Shortcuts" / "快捷指令" / "Siri" → Siri/App Intents
- "照片" / "照片库" → Photo Library access
- "文件" / "Downloads" / "Documents" → File access

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| iCloud (iCloud Drive) | ✅ Configured | Entitlements file + NSUbiquitousContainers |
| App Groups | ⏳ Pending (needs Widget target) | Will configure in PHASE 4+5 |
| In-App Purchase | ✅ Configured | Entitlements file |
| File Access (User Selected) | ✅ Configured | Entitlements file (com.apple.security.files.user-selected.read-write) |
| Network (Outgoing) | ✅ Configured | Entitlements file (com.apple.security.network.client) |
| Photo Library | ✅ Configured | Info.plist NSPhotoLibraryUsageDescription |
| Documents Folder | ✅ Configured | Info.plist NSDocumentsFolderUsageDescription |
| App Intents (Siri/Shortcuts) | ✅ Configured | Framework available in iOS 17+ (no entitlement needed) |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| iCloud Container | ⏳ Pending | 1. Log into Apple Developer Portal 2. Create CloudKit container "iCloud.com.zzoutuo.FileSort" 3. Enable CloudKit in project capabilities |
| App Group Container | ⏳ Pending | 1. Create App Group "group.com.zzoutuo.FileSort" in Developer Portal 2. Add to main app and Widget extension entitlements |
| IAP Products | ⏳ Pending | 1. Create subscription products in App Store Connect 2. Configure product IDs matching code |

## No Configuration Needed
- HealthKit (not used)
- Location Services (not used)
- Camera (not used)
- Apple Watch (not used)
- Push Notifications (not used)
- Background Modes (not used for now)

## Verification
- Build succeeded after configuration: Pending (will verify after code generation)
- All entitlements correct: ✅
- Info.plist usage descriptions added: ✅
