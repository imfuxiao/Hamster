# iOS 输入法移植参考（基于 Hamster 二次开发）

本文档汇总当前 Flutter 项目中已经验证过的逻辑（钢琴音映射、GLM API、Tenor API、设置存储、会话模型等），用于直接移植到基于 [Hamster](https://github.com/imfuxiao/Hamster) Fork 的 iOS 输入法项目。

---

## 一、产品定位

**仓输入法 + 差异化能力**：

| # | 能力 | 价值 |
|---|------|------|
| 1 | 完整拼音输入（继承 Hamster/librime） | 专业级输入体验 |
| 2 | 钢琴音按键反馈（C 大调音阶，可开关） | 趣味性、记忆点 |
| 3 | 候选区下方功能栏：**⚙️ 设置 / 😊 表情 / 💡 AI 建议** | 高频功能一键直达 |
| 4 | 设置面板嵌入键盘区域（无需打开主 App） | 流畅的配置体验 |
| 5 | GIF 斗图（Tenor + GLM 关键词推荐） | 表达力 |
| 6 | AI 回复建议（GLM-4-Flash） | 沟通效率 |
| 7 | 用户自学习词库（继承 librime） | 越用越懂你 |

---

## 二、文件分布与命名约定

```
HamsterKeyboard/                        # Keyboard Extension
├── Sources/
│   ├── Piano/
│   │   ├── PianoMapping.swift         # 字符 → 音符
│   │   └── PianoAudioPlayer.swift     # 音频池化播放
│   ├── AI/
│   │   ├── GLMChatClient.swift        # GLM 调用
│   │   └── AISuggestion.swift         # 数据模型
│   ├── Meme/
│   │   ├── TenorClient.swift          # GIF 搜索
│   │   └── Gif.swift                  # 数据模型
│   ├── Shared/
│   │   ├── SharedSettings.swift       # App Group 共享配置
│   │   └── AppGroupKeys.swift         # 共享常量
│   └── UI/
│       ├── ToolbarView.swift          # 候选区下方功能栏（3 按钮）
│       ├── InlineSettingsView.swift   # 嵌入式设置面板
│       ├── GifPickerView.swift        # 表情面板
│       └── AISuggestionsView.swift    # AI 建议面板

HamsterApp/                             # 主 App
└── Sources/
    └── Keyboard/
        └── ApiKeySettingsView.swift   # API Key 配置入口
```

---

## 三、钢琴音模块（直接照搬）

### 3.1 音符映射规则

- **C 大调 8 音阶循环**：`C4, D4, E4, F4, G4, A4, B4, C5`
- **a-z** 按 ASCII 顺序循环映射：`a→C4, b→D4, ..., h→C5, i→C4, ...`
- **非字母字符**：取 Unicode 标量值取模映射
- **音频文件命名**：小写 + 八度，如 `c4.mp3, d4.mp3, c5.mp3`
- **资源位置**：`assets/audio/` 已包含 a-1 到 c7 全音域采样

### 3.2 Swift 实现

```swift
struct PianoMapping {
    static let cMajorScale = ["C4", "D4", "E4", "F4", "G4", "A4", "B4", "C5"]

    static func mapCharToNote(_ char: Character) -> String {
        let lower = Character(String(char).lowercased())
        if let ascii = lower.asciiValue, (97...122).contains(ascii) {
            return cMajorScale[(Int(ascii) - 97) % cMajorScale.count]
        }
        let scalar = Int(char.unicodeScalars.first?.value ?? 0)
        return cMajorScale[abs(scalar) % cMajorScale.count]
    }
}
```

### 3.3 音频播放器（池化设计）

> 输入法环境内存受限（48MB），用 `.ambient` + `.mixWithOthers` 避免抢占其他音频。每个音符预加载 3 个 `AVAudioPlayer` 实例支持快速连按。

```swift
import AVFoundation

final class PianoAudioPlayer {
    private var pool: [String: [AVAudioPlayer]] = [:]
    private var index: [String: Int] = [:]
    private let poolSize = 3

    init() {
        try? AVAudioSession.sharedInstance().setCategory(
            .ambient, mode: .default, options: [.mixWithOthers]
        )
        try? AVAudioSession.sharedInstance().setActive(true)
        preload()
    }

    private func preload() {
        for note in PianoMapping.cMajorScale {
            let name = note.lowercased()
            guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else { continue }
            var players: [AVAudioPlayer] = []
            for _ in 0..<poolSize {
                if let p = try? AVAudioPlayer(contentsOf: url) {
                    p.prepareToPlay()
                    players.append(p)
                }
            }
            pool[note] = players
            index[note] = 0
        }
    }

    func play(_ note: String) {
        guard var players = pool[note], !players.isEmpty,
              let i = index[note] else { return }
        let p = players[i]
        if p.isPlaying { p.currentTime = 0 }
        p.play()
        index[note] = (i + 1) % players.count
    }
}
```

### 3.4 集成到 Hamster

**关键改造点**：在键盘按键事件触发处插入 `pianoPlayer.play(note)`。

定位方法（在 Hamster Fork 后搜索）：
```bash
# 在 HamsterKeyboardKit 中查找
grep -rn "insertText\|onKeyTap\|keyAction" Packages/HamsterKeyboardKit/Sources
```

通常 Hamster 有一个统一的 `KeyboardActionHandler` 处理按键，找到它的字符输入分支加入 piano 调用。

需要从 `SharedSettings` 读取 `isPianoEnabled` 开关。

---

## 四、GLM AI 建议模块

### 4.1 接口规范

| 项 | 值 |
|---|---|
| Endpoint | `https://open.bigmodel.cn/api/paas/v4/chat/completions` |
| 协议 | OpenAI Compatible |
| Model | `GLM-4-Flash`（免费） |
| 鉴权 | `Authorization: Bearer <apiKey>` |
| 体积上限 | `max_tokens: 1024` |

### 4.2 提示词模板（已验证有效）

```
请基于以下聊天上下文，生成 3 条简洁自然的中文回复建议，
每条建议不超过 30 字。只返回 3 条建议，用换行分隔，不要编号或其他说明。

上下文：{contextText}
```

### 4.3 Swift 实现

```swift
struct AISuggestion: Identifiable {
    let id = UUID()
    let index: Int
    let text: String
}

actor GLMChatClient {
    let baseURL = URL(string: "https://open.bigmodel.cn/api/paas/v4/chat/completions")!
    let model = "GLM-4-Flash"

    func generateSuggestions(context: String) async throws -> [AISuggestion] {
        let apiKey = await SharedSettings.shared.glmApiKey
        guard !apiKey.isEmpty else {
            throw NSError(domain: "GLM", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "GLM API Key 未配置"])
        }

        var req = URLRequest(url: baseURL)
        req.httpMethod = "POST"
        req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let prompt = """
        请基于以下聊天上下文，生成 3 条简洁自然的中文回复建议，每条建议不超过 30 字。\
        只返回 3 条建议，用换行分隔，不要编号或其他说明。

        上下文：\(context)
        """

        let body: [String: Any] = [
            "model": model,
            "max_tokens": 1024,
            "messages": [["role": "user", "content": prompt]]
        ]
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw NSError(domain: "GLM", code: -2)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let raw = message["content"] as? String else {
            throw NSError(domain: "GLM", code: -3)
        }

        let lines = raw.split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        return lines.prefix(3).enumerated().map { idx, text in
            AISuggestion(index: idx, text: text)
        }
    }
}
```

### 4.4 Mock 实现（开发期）

```swift
struct MockGLMChatClient {
    func generateSuggestions(context: String) async -> [AISuggestion] {
        let topic = context.trimmingCharacters(in: .whitespaces).isEmpty ? "这件事" : context
        return [
            .init(index: 0, text: "我理解你的意思，我们可以先从 \(topic) 开始。"),
            .init(index: 1, text: "这个想法不错，我想再补充一点关于 \(topic) 的细节。"),
            .init(index: 2, text: "收到，我晚点认真看看 \(topic)，然后再回复你。"),
        ]
    }
}
```

### 4.5 触发时机

候选区下方功能栏的 **💡 按钮** 点击时：
1. 取 `textDocumentProxy.documentContextBeforeInput`（前文）
2. 截取最近 200 字
3. 调用 `GLMChatClient.generateSuggestions(context:)`
4. 在键盘区域内弹出 `AISuggestionsView` 显示 3 条建议
5. 点击某条 → `textDocumentProxy.insertText(suggestion.text)`

> ⚠️ 输入法需要在 Info.plist 设置 `RequestsOpenAccess: true`，用户需手动在设置中授权"完全访问"才能联网。

---

## 五、Tenor GIF 模块

### 5.1 接口规范

| 项 | 值 |
|---|---|
| Base URL | `https://tenor.googleapis.com/v2` |
| 搜索 | `GET /search?q={query}&key={apiKey}&limit=10` |
| 申请 Key | https://developers.google.com/tenor/guides/quickstart |

### 5.2 Swift 实现

```swift
struct Gif: Identifiable {
    let id: String
    let url: String         // 原始 GIF
    let title: String
    let previewUrl: String  // 预览图（小尺寸）
}

actor TenorClient {
    let baseURL = "https://tenor.googleapis.com/v2"

    func searchGifs(query: String, limit: Int = 10) async throws -> [Gif] {
        let apiKey = await SharedSettings.shared.tenorApiKey
        guard !apiKey.isEmpty else {
            throw NSError(domain: "Tenor", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "Tenor API Key 未配置"])
        }

        var comps = URLComponents(string: "\(baseURL)/search")!
        comps.queryItems = [
            .init(name: "q", value: query),
            .init(name: "key", value: apiKey),
            .init(name: "limit", value: "\(limit)"),
            .init(name: "media_filter", value: "gif,tinygif"),
        ]

        let (data, resp) = try await URLSession.shared.data(from: comps.url!)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw NSError(domain: "Tenor", code: -2)
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let results = json["results"] as? [[String: Any]] else { return [] }

        return results.compactMap { item -> Gif? in
            guard let id = item["id"] as? String,
                  let formats = item["media_formats"] as? [String: [String: Any]],
                  let gif = formats["gif"], let url = gif["url"] as? String else { return nil }
            let title = item["title"] as? String ?? (item["content_description"] as? String ?? "")
            let tiny = formats["tinygif"]?["url"] as? String ?? url
            return Gif(id: id, url: url, title: title, previewUrl: tiny)
        }
    }
}
```

> ⚠️ Tenor v2 字段名实际是 `media_formats`，Flutter 端使用的 `media` 字段是 v1 老格式。Swift 端用 v2 正确字段。

### 5.3 GLM 推荐关键词（增强体验）

点击 😊 按钮时，**先用 GLM 根据上下文推荐 3 个 GIF 关键词**，再去 Tenor 搜：

```
请基于以下聊天上下文，推荐 3 个适合搭配的英文 GIF 关键词，
每个关键词 1-3 个单词，只返回关键词，换行分隔，不要其他说明。

上下文：{contextText}
```

UI 展示：顶部一行关键词芯片（可点击切换），下方瀑布流 GIF。

### 5.4 插入 GIF 到输入框

iOS 不允许输入法直接通过 `textDocumentProxy` 插入图片。两种方案：

**方案 1（简单）**：复制 GIF URL 到剪贴板，提示用户粘贴。

```swift
UIPasteboard.general.string = gif.url
```

**方案 2（推荐）**：下载 GIF 到 App Group 的 Pasteboard，调用 `UIPasteboard.general.setData(_:forPasteboardType:)`，部分聊天应用（微信、iMessage）可识别。

```swift
let (data, _) = try await URLSession.shared.data(from: URL(string: gif.url)!)
UIPasteboard.general.setData(data, forPasteboardType: "com.compuserve.gif")
```

---

## 六、共享存储设计（App Group）

### 6.1 App Group 标识

```
group.com.luckytian.musickeyboard
```

主 App 和 Keyboard Extension 都需要：
- 添加 `com.apple.security.application-groups` entitlement
- 在 Apple Developer 后台注册 App Group

### 6.2 存储内容

| Key | 类型 | 说明 |
|---|---|---|
| `glm_api_key` | String | GLM API Key |
| `tenor_api_key` | String | Tenor API Key |
| `piano_enabled` | Bool | 钢琴音开关，默认 true |
| `piano_volume` | Double | 0.0 - 1.0，默认 0.8 |
| `last_gif_keywords` | [String] | 最近使用的 GIF 关键词 |
| `user_phrases` | [String: Int] | 用户自造词与频次（备用） |

### 6.3 Swift 实现

```swift
enum AppGroupKeys {
    static let identifier = "group.com.luckytian.musickeyboard"

    static let glmApiKey = "glm_api_key"
    static let tenorApiKey = "tenor_api_key"
    static let pianoEnabled = "piano_enabled"
    static let pianoVolume = "piano_volume"
}

actor SharedSettings {
    static let shared = SharedSettings()
    private let defaults = UserDefaults(suiteName: AppGroupKeys.identifier)!

    var glmApiKey: String {
        get { defaults.string(forKey: AppGroupKeys.glmApiKey) ?? "" }
    }
    var tenorApiKey: String {
        get { defaults.string(forKey: AppGroupKeys.tenorApiKey) ?? "" }
    }
    var isPianoEnabled: Bool {
        get { defaults.object(forKey: AppGroupKeys.pianoEnabled) as? Bool ?? true }
    }

    func setGLMApiKey(_ value: String) {
        defaults.set(value, forKey: AppGroupKeys.glmApiKey)
    }
    func setTenorApiKey(_ value: String) {
        defaults.set(value, forKey: AppGroupKeys.tenorApiKey)
    }
    func setPianoEnabled(_ value: Bool) {
        defaults.set(value, forKey: AppGroupKeys.pianoEnabled)
    }
}
```

### 6.4 安全注意事项

- **API Key 仅存 App Group 共享 UserDefaults**：输入法环境无法访问 Keychain（沙盒限制）
- 主 App 可以使用 Keychain 备份，输入法每次启动从 UserDefaults 读取
- ⚠️ App Group UserDefaults 不加密，但同一开发者下 App Group 内是相对安全的

---

## 七、UI 设计规范

### 7.1 整体原则

- **保持 Hamster/iOS 原生简洁感**
- **键盘区域内完成所有交互**（除主 App 中的 API Key 配置）
- **任何面板都可一键返回键盘**（顶部留返回箭头）

### 7.2 候选区下方功能栏布局

```
┌──────────────────────────────────────────┐
│ [拼音 nihao]    候选词1 候选词2 ...      │   ← Hamster 原候选区（不动）
├──────────────────────────────────────────┤
│    ⚙️         😊            💡          │   ← 新增功能栏
├──────────────────────────────────────────┤
│ q w e r t y u i o p                      │
│  a s d f g h j k l                       │   ← Hamster 原键盘（不动）
│ ⇧  z x c v b n m  ⌫                      │
│ 123     space     return                 │
└──────────────────────────────────────────┘
```

### 7.3 设置面板（点击 ⚙️）

```
┌──────────────────────────────────────────┐
│ ← 设置                                    │
├──────────────────────────────────────────┤
│ 🎹 钢琴音                       [ ●━━ ]  │
│ 🔊 音量                         ━●━━━    │
│                                          │
│ 🤖 GLM API Key            [前往主 App]   │
│ 🖼️ Tenor API Key          [前往主 App]   │
│                                          │
│ 📚 用户词库管理                          │
│ 🎨 主题切换                              │
└──────────────────────────────────────────┘
```

> API Key 配置不在输入法内（避免明文输入安全风险），引导用户去主 App 设置。

### 7.4 GIF 面板（点击 😊）

```
┌──────────────────────────────────────────┐
│ ← [开心] [赞] [无语]   🔍 搜索框          │   ← GLM 推荐关键词 + 搜索
├──────────────────────────────────────────┤
│  ┌────┐ ┌────┐ ┌────┐                    │
│  │GIF │ │GIF │ │GIF │                    │
│  └────┘ └────┘ └────┘                    │   ← 瀑布流
│  ┌────┐ ┌────┐ ┌────┐                    │
│  │GIF │ │GIF │ │GIF │                    │
│  └────┘ └────┘ └────┘                    │
└──────────────────────────────────────────┘
```

### 7.5 AI 建议面板（点击 💡）

```
┌──────────────────────────────────────────┐
│ ← AI 建议（基于前文 200 字）              │
├──────────────────────────────────────────┤
│ 1. 我理解你的意思，我们可以先从...         │
│ 2. 这个想法不错，我想再补充...            │
│ 3. 收到，我晚点认真看看...                │
│                                          │
│              [🔄 刷新]                   │
└──────────────────────────────────────────┘
```

---

## 八、Hamster 二次开发关键点（拿到 Fork 后逐步实现）

### 8.1 探索 Hamster 仓库结构

```powershell
# 在 Hamster fork 根目录
ls Packages/                              # 查看 SPM 包
ls HamsterKeyboard/                       # 查看 Keyboard Extension
ls HamsterApp/                            # 查看主 App
cat Hamster.xcworkspace/contents.xcworkspacedata
```

### 8.2 找到候选区视图

```powershell
# 候选区通常包含 "Candidate" 关键字
grep -rn "Candidate" Packages/HamsterKeyboardKit/Sources --include="*.swift" | head -30
```

### 8.3 找到按键事件处理

```powershell
grep -rn "insertText\|performAction" Packages --include="*.swift" | head -30
```

找到后在字符输入分支注入 `PianoAudioPlayer.play()`。

### 8.4 添加候选区下方工具栏

在候选区视图下方插入一个 `ToolbarView`，包含 3 个按钮。点击后通过自定义 Notification 或 Coordinator 通知 `KeyboardViewController` 切换显示面板（设置/GIF/AI）。

### 8.5 弹出面板架构建议

```swift
enum KeyboardPanel {
    case keyboard           // 默认：键盘
    case settings           // 嵌入设置
    case gifs               // GIF
    case aiSuggestions      // AI 建议
}

final class KeyboardViewController: UIInputViewController {
    @Published var panel: KeyboardPanel = .keyboard

    // 监听 panel 切换，动态显示/隐藏对应 view
}
```

---

## 九、CI/CD 配置（用于巨魔安装）

### 9.1 GitHub Actions Workflow（在 Fork 仓库内）

```yaml
name: Build iOS for TrollStore

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: latest-stable
      - name: Install Pods
        run: |
          cd ${{ env.PROJECT_DIR }}
          pod install || true
      - name: Build (no codesign)
        run: |
          xcodebuild -workspace Hamster.xcworkspace \
            -scheme HamsterApp \
            -configuration Release \
            -sdk iphoneos \
            -derivedDataPath build \
            CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
      - name: Package IPA
        run: |
          cd build/Build/Products/Release-iphoneos
          mkdir -p Payload
          cp -R HamsterApp.app Payload/
          zip -r ../../../../Hamster.ipa Payload/
      - uses: actions/upload-artifact@v4
        with:
          name: ios-ipa
          path: Hamster.ipa
          retention-days: 7
```

### 9.2 巨魔安装步骤

1. GitHub Actions 构建完成 → 下载 `ios-ipa.zip` → 解压得 `Hamster.ipa`
2. 通过 iCloud / 隔空投送 / 浏览器下载到 iPhone
3. 巨魔（TrollStore）→ 安装 IPA
4. 系统设置 → 通用 → 键盘 → 添加新键盘 → 选 "Hamster"
5. 点击"Hamster" → 打开"允许完全访问"（联网需要）

---

## 十、开发优先级建议

按这个顺序逐步实现，每完成一项即可在巨魔上测试：

1. **Fork Hamster + 跑通基础构建** → 巨魔安装能用 Hamster 原版
2. **集成 PianoAudioPlayer** → 打字有声音
3. **App Group + SharedSettings** → 主 App 与输入法能共享数据
4. **主 App 加 API Key 配置页**（Hamster 主 App 已有设置框架，加两项即可）
5. **候选区下方工具栏 + 设置面板（钢琴音开关 + 音量）**
6. **AI 建议面板**
7. **GIF 面板**

---

## 十一、Flutter 项目去留

当前 `music-keyboard` (Flutter) 项目：

- ✅ **保留**：演奏会页（独立的钢琴音演奏 demo，无法被输入法替代）
- ✅ **保留**：AI 调试页、Tenor 调试页（作为联调工具）
- ✅ **保留**：会话管理（作为聊天记录管理工具）
- 📝 **文档化**：本文档汇总了所有需要移植到 iOS 的逻辑

iOS 输入法在新 Fork 仓库独立维护，与 Flutter 项目通过本文档保持一致性。

---

## 附录：常用命令速查

```powershell
# 查找 Hamster 中按键事件处理
grep -rn "insertText" Packages --include="*.swift"

# 查找候选区视图
grep -rn "CandidateBar\|CandidateView" Packages --include="*.swift"

# 查找设置入口
grep -rn "SettingsView" HamsterApp --include="*.swift"

# 在 Fork 项目根目录构建（macOS）
xcodebuild -workspace Hamster.xcworkspace -scheme HamsterApp \
  -configuration Debug -sdk iphonesimulator -derivedDataPath build
```

