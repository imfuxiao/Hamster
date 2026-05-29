# Hamster 二次开发实施计划

本文档用于指导基于当前 `Hamster` 仓库的 iOS 输入法二次开发。目标是在保留 Hamster/librime 专业输入体验的基础上，逐步加入「打字钢琴音」「键盘内设置」「AI 回复建议」「GIF 斗图」等客户需求能力。

---

## 1. 当前决策

- **开发基线**：基于 `D:\test_react\claude_test\Hamster` 中已克隆的 Hamster 仓库二次开发。
- **优先平台**：先做 iOS Keyboard Extension，不再从零启动跨平台输入法骨架。
- **核心原则**：最小修改现有输入法逻辑，优先复用 Hamster 的 Rime、候选栏、工具栏和 App Group 能力。
- **资源来源**：钢琴音频文件已放置在 `assets/audio`。
- **共享存储**：优先沿用仓库已有 App Group：`group.dev.fuxiao.app.Hamster`。
- **网络能力**：AI 与 GIF 功能依赖键盘「允许完全访问」，API Key 不硬编码。

---

## 2. 已确认的关键文件

| 功能区域 | 文件 |
|---|---|
| 键盘扩展入口 | `HamsterKeyboard/HamsterKeyboardInputViewController.swift` |
| 键盘主控制器 | `Packages/HamsterKeyboardKit/Sources/Controller/KeyboardInputViewController.swift` |
| Rime 上下文 | `Packages/HamsterKeyboardKit/Sources/RimeContext/RimeContext.swift` |
| 按键事件处理 | `Packages/HamsterKeyboardKit/Sources/KeyboardKit/Actions/StandardKeyboardActionHandler.swift` |
| 候选区与工具栏 | `Packages/HamsterKeyboardKit/Sources/View/KeyboardToolbarView.swift` |
| 键盘根布局 | `Packages/HamsterKeyboardKit/Sources/View/KeyboardRootView.swift` |
| 主 App entitlement | `Hamster/Hamster.entitlements` |
| 键盘 entitlement | `HamsterKeyboard/HamsterKeyboard.entitlements` |
| 钢琴音资源 | `assets/audio/*.mp3` |

---

## 3. 里程碑规划

### M1：钢琴音按键反馈 MVP

**目标**：用户在键盘中敲击字符时播放钢琴音，形成核心记忆点。

**范围**：

- 新增字符到音符的映射模块。
- 新增低延迟钢琴音播放器。
- 在按键释放事件中触发播放。
- 默认开启钢琴音，后续可通过设置关闭。

**建议新增文件**：

```text
Packages/HamsterKeyboardKit/Sources/MusicKeyboard/Piano/PianoMapping.swift
Packages/HamsterKeyboardKit/Sources/MusicKeyboard/Piano/PianoAudioPlayer.swift
Packages/HamsterKeyboardKit/Sources/MusicKeyboard/Settings/MusicKeyboardSettings.swift
```

**音符映射**：

- 默认使用 C 大调 8 音阶循环：`C4, D4, E4, F4, G4, A4, B4, C5`。
- 字母 `a-z` 按顺序循环映射。
- 数字和符号按 Unicode 标量取模映射。
- 中文输入过程中，如按键本身是拼音字母，则按字母音播放；候选词上屏阶段暂不逐字播放，避免干扰输入体验。

**资源要求**：

`assets/audio` 已存在全音域 mp3 文件。MVP 至少需要以下文件：

```text
c4.mp3
d4.mp3
e4.mp3
f4.mp3
g4.mp3
a4.mp3
b4.mp3
c5.mp3
```

当前目录已包含上述 MVP 所需资源。

**接入点**：

- 优先在 `StandardKeyboardActionHandler.handle(_ gesture: KeyboardGesture, on key: Key)` 中处理。
- 只在 `gesture == .release` 时播放。
- 防御性判断：非字符类、删除键、切换键、空格键是否播放需要单独判断，MVP 建议只播放明确字符输入。

**验收标准**：

- 原有中文输入、英文输入、候选词选择不受影响。
- 连续快速按键无明显卡顿。
- 输入法启动不因缺失音频资源崩溃。
- 未开启完全访问时钢琴音仍能播放，因为音频资源在本地 bundle 内。

---

### M2：键盘工具栏入口

**目标**：在现有工具栏中加入客户功能入口，为设置、GIF、AI 面板提供入口。

**范围**：

- 在 `KeyboardToolbarView.commonFunctionBar` 中增加 3 个按钮：
  - 设置：`gearshape`
  - 表情：`face.smiling`
  - AI 建议：`lightbulb`
- 初期按钮只展示占位面板或触发日志，不直接接网络能力。
- 保留现有 App 图标按钮和收起键盘按钮。

**建议状态模型**：

```text
keyboard       默认键盘
settings       键盘内设置面板
gifs           GIF 面板
aiSuggestions  AI 建议面板
```

**验收标准**：

- 工具栏布局不遮挡候选词。
- 有候选词时仍优先显示 Hamster 原候选栏。
- 无候选词时显示新增功能入口。
- 按钮具备无障碍标签，方便 VoiceOver 识别。

---

### M3：键盘内设置与共享配置

**目标**：支持用户在键盘中开关钢琴音和调整音量。

**范围**：

- 使用现有 App Group `group.dev.fuxiao.app.Hamster` 保存设置。
- 新增设置 key：
  - `music_keyboard_piano_enabled`
  - `music_keyboard_piano_volume`
  - `music_keyboard_glm_api_key`
  - `music_keyboard_tenor_api_key`
- 键盘设置面板只管理无敏感配置，如钢琴音开关、音量。
- API Key 推荐放在主 App 配置，键盘内只提示是否已配置。

**验收标准**：

- 重启键盘后钢琴音开关仍生效。
- 未读到 App Group 时有默认值，不崩溃。
- 音量变化能实时影响后续按键音。

---

### M4：AI 回复建议

**目标**：点击 AI 建议按钮后，基于输入框前文生成 3 条回复建议。

**范围**：

- 读取 `textDocumentProxy.documentContextBeforeInput`。
- 截取最近 200 字作为上下文。
- 调用 GLM OpenAI-compatible API。
- 展示 3 条建议。
- 点击建议插入输入框。
- 长按建议可复制到输入框或剪贴板，后续再细化。

**接口配置**：

- Endpoint：`https://open.bigmodel.cn/api/paas/v4/chat/completions`
- Model：优先 `GLM-4-Flash`
- 鉴权：`Authorization: Bearer <apiKey>`

**限制说明**：

- iOS 键盘扩展联网必须开启「允许完全访问」。
- 不支持自动读取微信完整对话，只能使用输入框上下文或用户复制内容。
- 不建议 iOS 自动发送消息，避免权限与误发风险。

**验收标准**：

- 未配置 API Key 时给出明确提示。
- 网络失败时不影响正常输入。
- 返回内容最多展示 3 条，并过滤空行。

---

### M5：GIF 斗图

**目标**：点击表情按钮后，根据上下文推荐关键词并展示 GIF 候选。

**范围**：

- 使用 GLM 生成 3 个英文 GIF 关键词。
- 使用 Tenor API 搜索 GIF。
- 展示 10 个候选。
- MVP 点击 GIF 后复制 GIF URL 到剪贴板，并提示用户粘贴。

**接口配置**：

- Base URL：`https://tenor.googleapis.com/v2`
- Search：`/search?q={query}&key={apiKey}&limit=10&media_filter=gif,tinygif`

**限制说明**：

- iOS 输入法不能像普通 App 一样直接插入图片。
- 后续可尝试把 GIF 数据写入 `UIPasteboard`，但不同聊天 App 支持不一致。

**验收标准**：

- 未配置 Tenor Key 时给出明确提示。
- GIF 加载失败时可返回搜索页。
- 点击 GIF 不导致键盘扩展崩溃。

---

## 4. 风险与处理策略

| 风险 | 影响 | 策略 |
|---|---|---|
| 输入法扩展内存限制 | 音频池过大导致崩溃 | MVP 只预加载 8 个音符，每个音符小池化 |
| 音频资源未加入 target | 真机无声音 | 检查 Xcode Copy Bundle Resources |
| App Group 签名不匹配 | 设置无法共享 | 先沿用现有 `group.dev.fuxiao.app.Hamster` |
| 键盘无完全访问 | AI/GIF 无法联网 | UI 提示用户开启完全访问 |
| GLM/Tenor Key 暴露 | 纯客户端无法完全防护 | 不硬编码，用户本地配置，自用场景接受 |
| 修改核心输入逻辑引入回归 | 影响 Hamster 原功能 | 只在事件后置阶段播放声音，不改变 Rime 输入路径 |

---

## 5. 建议执行顺序

1. **M1 钢琴音 MVP**：先让打字有声音。
2. **M2 工具栏入口**：加入 ⚙️ / 😊 / 💡。
3. **M3 设置共享**：钢琴音开关与音量持久化。
4. **M4 AI 建议**：GLM 生成 3 条回复。
5. **M5 GIF 斗图**：Tenor 搜索与复制分享。

---

## 6. 下一步执行清单

若确认开始 M1，建议按以下步骤执行：

1. 检查 `assets/audio` 是否已加入 Xcode 工程资源。
2. 新增 `PianoMapping.swift`。
3. 新增 `PianoAudioPlayer.swift`。
4. 新增 `MusicKeyboardSettings.swift`。
5. 在 `StandardKeyboardActionHandler` 中注入钢琴音播放。
6. 在模拟器或真机验证原输入逻辑不受影响。

每一步完成后都应暂停确认，再继续下一步，避免一次性改动过大。
