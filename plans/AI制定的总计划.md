# Music Keyboard 跨平台钢琴键盘开发总览计划

一份从零开始构建跨平台「打字即弹琴 + AI 智能回复 + 斗图 skill」键盘应用的总体路线图，最终交付物为自用的 APK 与 IPA。

---

## 1. 项目定位

- **形态**：Android 系统输入法（IME） + iOS Keyboard Extension，宿主主 App 提供设置、AI 对话区与「演奏会」音乐播放器。
- **核心玩法**：
  1. 打字时每个字符触发钢琴音（参考 [typatone.com](https://typatone.com)）；
  2. 把任意文字复制到主 App 内可重新「演奏」出来；
  3. 输入法集成 GLM-4.6 给出 3 条回复建议，支持「自动回复」开关；
  4. AI 提供斗图 skill：根据上下文输出关键词 → 拉取公开 GIF API → 用户挑选 10 张中的一张发送。
- **不上架商店**，仅自用；产物仅 APK + IPA。

## 2. 已确认的关键决策（决策记录 / ADR）

| 主题 | 决策 |
|---|---|
| 技术栈 | Flutter 3.x（主 App）+ 原生 IME / Keyboard Extension（Kotlin / Swift） + Riverpod 状态管理 |
| 后端 | **无后端**，纯客户端；GLM / GIF API Key 由你在 App 设置里填，使用 `flutter_secure_storage` 本地加密存储 |
| 打包 | GitHub Actions：`ubuntu-latest` 构 APK、`macos-latest` 构 IPA |
| Android 取微信上下文 | 无障碍服务自动读取最近若干条消息 |
| iOS 取微信上下文 | 微信内长按多选复制 → 键盘上的「读剪贴板」按钮 |
| 音乐分享方式 | 仅在主 App 内重放，不做隐写、不做云端分享（MVP 范围） |
| 自动回复 | 三条建议右上角各有「自动回复」开关；开启后键盘保持在该页面，监听到对方新消息即直接发送（仅在键盘激活时生效） |
| 会话标识 | 「对方最近 N 条消息 hash 指纹」自动识别 + 顶部下拉菜单手动覆盖/重命名 |
| 斗图来源 | 公开 GIF API（**首选 Tenor**，备选 Giphy / Soutushen），Key 由开发者填；默认根据 AI 关键词展示 10 个候选 |
| 钢琴音映射 | 多模式：Typatone 同款 C 大调（默认）/ 拼音首字母 + 声调控音高 / 五声音阶 |
| AI 模型 | 文本：GLM-4.6；图像理解（截图/GIF）：GLM-4V 系列 |
| LICENSE | **PolyForm Noncommercial 1.0.0**，附 `AI_TRAINING.md` 注明「AI 训练需先 follow + star，否则禁止」 |

## 3. 全局架构

```
┌────────────────────────────────────────────────────────────┐
│ 主 App (Flutter)                                            │
│  ├ 设置中心: API Key / 钢琴音模式 / 联系人白名单 / 无障碍引导  │
│  ├ AI 对话调试区: 全屏聊天界面 (可不经键盘也能与 GLM 对话)    │
│  ├ 演奏会: 粘贴文字 → 实时合成钢琴音 → 播放/暂停/导出 wav      │
│  └ 会话历史: 各会话上下文缓存、命名、删除、导出                │
├────────────────────────────────────────────────────────────┤
│ 共享数据层 (SQLite via drift + flutter_secure_storage)      │
│  - sessions / messages / settings / piano_profiles          │
│  - Android: SharedPreferences/Room 同库; iOS: App Group     │
├────────────────────────────────────────────────────────────┤
│ Android IME (Kotlin)         │  iOS Keyboard Ext (Swift)     │
│  - InputMethodService         │  - UIInputViewController     │
│  - 钢琴音播放 (SoundPool)     │  - 钢琴音播放 (AVAudioPlayer) │
│  - 无障碍服务读对话           │  - 「读剪贴板」按钮            │
│  - 调 GLM / Tenor 出建议      │  - 调 GLM / Tenor 出建议      │
│  - 自动回复 (无障碍点发送键)  │  - 仅展示建议, 不自动发        │
└────────────────────────────────────────────────────────────┘
```

**关键架构权衡**：IME / Keyboard Extension **不嵌入 Flutter 引擎**（避免冷启动慢与内存爆），UI 用原生写（Android Jetpack Compose / iOS SwiftUI），仅通过共享数据库与主 App 通信。

## 4. 版本路线图

### V0.1 - 环境与骨架（1~2 天）
- Flutter 镜像源配置、Android SDK / JDK 安装、Gradle 镜像
- 创建 Flutter 项目 + Android IME 原生模块 + iOS Keyboard Extension target
- 「Hello World」键盘能在系统设置中启用并输出字符

### V0.2 - 钢琴音引擎（2~3 天）
- 集成 Salamander Grand Piano SoundFont（CC0/CC-BY）
- 实现 Typatone 同款 C 大调循环映射
- 字符 → 音 → 即时播放（< 30ms 延迟目标）

### V0.3 - 演奏会播放器（1~2 天）
- 主 App 「演奏会」Tab：粘贴 / 录制打字节奏 / 播放 / 导出 wav
- 支持音色与映射模式切换

### V0.4 - GLM 接入与会话缓存（2~3 天）
- GLM-4.6 文本接入，OpenAI 风格 API
- 会话指纹算法（近 5 条对方消息 SHA-256 截断 hash + 用户可命名）
- 主 App 内 AI 对话调试区跑通

### V0.5 - 键盘上的 AI 建议条（3~4 天）
- 键盘上方区域：复制对方消息 → 点「AI 建议」按钮 → 出 3 条
- 每条右上角自动回复开关
- 长按复制到输入框，点击则直接发送（Android）/ 填入输入区（iOS）

### V0.6 - Android 无障碍与自动回复（3~4 天）
- 无障碍服务：监听微信 ListView，提取最近对方消息
- 「保持在建议页面 + 自动发送」工作流
- 引导用户开启无障碍权限的友好流程

### V0.7 - 斗图 Skill（2~3 天）
- Tenor API 客户端
- AI prompt 工程：让 GLM 给出 3~5 个搜索关键词
- 键盘上 GIF 选择面板：10 候选 → 点击发送
- 发送方式：复制 GIF → 用户切回微信粘贴（最稳）

### V0.8 - 图像理解（2 天）
- 用户在 iOS 截屏 → 分享到主 App → GLM-4V 读图 → 转文字描述塞入上下文
- Android 复用无障碍 + 截图分享路径

### V0.9 - LICENSE 与文档（0.5 天）
- 把 `LICENSE` 替换为 PolyForm Noncommercial 1.0.0
- 新增 `AI_TRAINING.md`、`NOTICE`、`robots.txt`、`README.md`（含 follow+star 说明）

### V1.0 - CI 打包与发布（1~2 天）
- GitHub Actions workflow：APK + IPA（ad-hoc 或 development 证书）
- IPA 自签方案：用 `AltStore` / `Sideloadly` 旁加载到自己 iPhone（无需开发者账户也能 7 天签）

**总计预估：~21 天专注开发**，业余时间约 1.5~2 个月可完成 V1.0。

## 5. 计划文件拆分清单（实施阶段会逐个创建在 `plans/` 目录下）

```
plans/
├── 00_总览.md                   ← 本文件落地版（含决策日志）
├── 01_环境与镜像源.md           ← Flutter / Android SDK / Gradle / pub 镜像
├── 02_项目骨架.md               ← 目录结构、模块划分、状态管理
├── 03_钢琴音引擎.md             ← 字符映射表、采样、播放调度
├── 04_演奏会播放器.md           ← 主 App 内的音乐重放入口
├── 05_Android-IME.md            ← InputMethodService + 与主 App 通信
├── 06_iOS-Keyboard-Ext.md       ← UIInputViewController + App Group
├── 07_GLM接入与会话缓存.md      ← API 客户端、指纹算法、本地存储 schema
├── 08_AI建议条UI.md             ← 三条建议 + 自动回复开关交互细节
├── 09_Android无障碍服务.md      ← 微信 UI tree 解析、自动发送
├── 10_斗图Skill.md              ← Tenor API、GIF 面板、关键词工程
├── 11_图像理解.md               ← GLM-4V、截屏分享流程
├── 12_LICENSE与防滥用.md        ← PolyForm + AI_TRAINING + robots
├── 13_CI与打包.md               ← GitHub Actions workflow YAML
└── 14_测试与自签上机.md         ← 真机测试清单、AltStore 旁加载
```

## 6. 镜像源与工具链速查

| 工具 | 推荐镜像 |
|---|---|
| Flutter SDK | `https://storage.flutter-io.cn`（FLUTTER_STORAGE_BASE_URL） |
| pub.dev | `https://pub.flutter-io.cn`（PUB_HOSTED_URL） |
| Gradle / Maven | 阿里云 `https://maven.aliyun.com/repository/public` |
| Android SDK | 清华 TUNA / 中科大镜像 |
| 智谱 GLM | `https://open.bigmodel.cn/api/paas/v4/`（官方，无需镜像） |
| Tenor | 官方，需科学上网或备 Giphy 国内代理 |

具体环境变量与 `gradle/init.d` 写法在 `01_环境与镜像源.md` 内。

## 7. 风险与待办

- **iOS 键盘扩展沙箱**：不能直接打开 URL、内存上限严（30~60MB），需把钢琴音采样压缩到 ~5MB，AI 调用必须用户在键盘里开「完全访问」。
- **Android 无障碍服务**：识别成微信「外挂/辅助工具」存在封号风险，需明确告知用户为个人测试用途。
- **自动回复风险**：网络波动 / AI 幻觉可能导致内容不当；建议默认延迟 3~5 秒并可一键中断。
- **GIF API Key 暴露**：纯客户端架构下 Key 必然能被反编译看到，需限制 Key 来源域/速率（Tenor 控制台可设）。
- **会话指纹冲突**：不同人发同样消息会撞 hash，需在 UI 上明显暴露「当前会话」状态并允许手动切换。
- **PolyForm 与商用边界**：你自用没问题；如果将来想给朋友安装，要确认朋友也是非商业使用。

## 8. 立即可启动的第一步（待你说出「可以执行」后再动）

1. 把当前仓库 LICENSE 由 Apache 2.0 替换为 **PolyForm Noncommercial 1.0.0**，新增 `AI_TRAINING.md`。
2. 在仓库根生成 `plans/00_总览.md`（即本文件的精简正式版）。
3. 给出 Windows 上安装 Flutter + Android Studio 的镜像源配置指令清单（写入 `plans/01_环境与镜像源.md`）。
4. `flutter create` 初始化项目骨架，提交首个 commit（含 gitmoji，例如 `🎉 init: bootstrap project skeleton`）。

后续每完成一个模块，更新对应的 `plans/XX_*.md` 并按功能点分多次 commit。
