# Typatone 风格调研与钢琴音设计参考

## 1. 调研目标

本文档用于整理 Typatone 的公开信息、声音设计风格、可借鉴功能，以及在 Hamster 二次开发中的落地建议。

当前项目目标不是复刻 Typatone，而是参考其“输入即音乐”的体验，结合 iOS 键盘扩展限制，形成适合中文输入法场景的钢琴音反馈方案。

## 2. 已尝试访问的信息源

### 2.1 成功读取

- `https://works.jonobr1.com/Typatone`
- `https://www.jono.fyi/Typatone`
- `https://www.lullatone.com/news/typatone/`
- `https://specialspecial.com/blogs/journal/showandtell18`

### 2.2 多次尝试但当前网络未能读取（放在了typetone_references目录了）

- `https://typatone.com/`
- `https://typatone.com/stats.html`
- `https://jonofyi.medium.com/typatone-statistical-analysis-6140f9a73032`

失败原因包括 TLS 握手超时、连接被拒绝、目标主机无响应等。

### 2.3 Cornell 字母频率页面

Jono 作品页引用的 Cornell 页面为：

```text
https://www.math.cornell.edu/~mec/2003-2004/cryptography/subs/frequencies.html
```

当前读取时该链接被重定向到：

```text
https://math.cornell.edu/~mec/2003-2004/cryptography/subs/frequencies.html
```

但重定向后页面返回 `404 Not Found`。

因此本文对 Typatone 精确字母到音符映射表不做断言，仅记录公开页面中可确认的设计原则。

## 3. Typatone 可确认的核心理念

### 3.1 输入文字即生成音乐

Typatone 的基础体验是：

- 每个字母或字符对应一个音乐音符。
- 用户写作时会同步听到音乐反馈。
- 文本不仅是文字，也可以作为一种音乐记谱方式。

Jono 作品页描述：

> Each letter you type corresponds to a specific musical note.

这说明 Typatone 更接近“字符确定性映射”，而不是随机播放或简单轮播。

### 3.2 使用英文字母频率设计音符映射

Jono 作品页明确说明，Typatone 的核心使用了 Cornell University 的 cryptographic study 中关于英文字母出现频率的数据。

其设计原则是：

- 高频字母映射到 melodic sounds on a scale。
- 字母频率降低时，音符逐步更偏 bass in nature。
- 最低频字母组成 accent notes。

这意味着 Typatone 不是简单的：

```text
a -> C
b -> D
c -> E
```

而更可能是：

```text
高频字母 e/t/a/o/i/n... -> 更悦耳、更稳定的旋律音
中频字母 s/h/r/d/l...   -> 低音或中低音支撑
低频字母 q/z/x/j/k...   -> 装饰音、强调音、跳跃音
```

### 3.3 英文写作时形成 melody + bass + accent 的组合

Jono 作品页提到，这种频率映射会让英文输入形成：

- melodic notes
- bass notes
- accent notes

三者混合的 song bites。

这对当前项目非常有价值：如果按字母频率映射，用户输入真实语言时，旋律会天然有层次，而不是机械递增。


### 3.4 Typatone 统计页补充信息

通过本地下载的 `Typatone_ Statistical Analysis.html` 可确认：

- 统计分析文章发布于 `July 19, 2016`。
- 页面数据更新到 `November 17, 2025`。
- Typatone 在达到 `100,000 messages sent` 后开始对用户输入做统计分析。
- Cornell 参考表基于 `40,000 words`。
- Typatone 统计页脚本引用的 2019 数据显示：
  - `total_messages`: `865235`
  - `total_characters`: `55978932`
  - `total_words`: `9128504`
  - `last_modified`: `2019-07-30`
- Typatone 数据集更偏 contemporary colloquial writing，即当代口语化写作。
- 页面曾写明数据集 under the MIT License，同时当前页面提示如需 aggregate data 可邮件联系 `inquiries@typatone.com`。

统计页脚本暴露了两个 JSON 数据源：

```text
http://storage.googleapis.com/stats.typatone.com/character_occurrence-v1-2003-2004.json
https://storage.googleapis.com/stats.typatone.com/character_occurrence-v1-2019-07-30.json
```

Cornell 2003-2004 英文字母频率顺序为：

```text
etaoinsrhdlucmfywgpbvkxqjz
```

Typatone 2019 用户输入数据中的英文字母频率顺序为：

```text
eaoitsnhrlduymgfcwkbpjvqzx
```

这个顺序更适合当前项目做 Typatone-inspired 的字母到音符映射，因为它来自 Typatone 用户真实输入数据，而不是传统英文语料。

## 4. Typatone 的附加功能

### 4.1 六种 mood / filters

公开页面提到 Typatone 支持 6 种 mood 或 filters。

每种 mood 会改变：

- speed
- filter
- color

可理解为同一段文字的不同演奏风格。它不一定改变基础字符到音符的映射，也可能改变播放速度、滤波效果、视觉主题和节奏表现。

### 4.2 复制粘贴导入文本

Typatone 支持从其他写作应用复制文本并粘贴导入，然后生成音乐。

对当前项目的启发：

- 主 App 可以提供“粘贴文本并播放”的入口。
- 键盘扩展中可以记录用户输入序列，后续在主 App 中回放。

### 4.3 分享与下载音频

Typatone 支持在完成写作后分享内容，并在桌面端下载音频版本。

对当前项目的启发：

- MVP 阶段可以先保存文本和音符序列。
- 后续主 App 可支持导出音频文件。
- 微信等聊天场景中，可以先分享文本或链接，再由对方本地 App 重放。

### 4.4 Sequencer

Jono 作品页提到 Typatone 有 robust sequencer：

- 可以在 filters 之间改变速度。
- 会根据创作时间改变表现。
- 会把多个 Typatone 实例量化到 global clock。
- 支持多标签页同时播放，形成 multi-track compositions。

对当前项目的启发：

- 后续可加入统一节拍器。
- 用户输入不必完全实时播放，也可以量化到固定节拍。
- 长文本回放时可根据 mood 调整速度和节拍。

### 4.5 多实例叠加播放

SpecialSpecial 页面提到，可以打开多个标签页同时播放，叠加旋律。

对当前项目的启发：

- 主 App 后续可以支持多段文本叠加播放。
- 比如用户输入一段消息，朋友回复一段消息，两段文字可以同时作为双轨演奏。

## 5. 对 Hamster 二次开发的落地建议

### 5.1 M1：按键钢琴音反馈

当前建议使用 Typatone-inspired 的确定性映射：

- 英文字母使用频率驱动映射。
- 高频字母映射到旋律音区。
- 中频字母映射到 bass 音区。
- 低频字母映射到 accent 音区。
- 数字、符号、中文字符按 Unicode 标量取模映射到全音域音频。

### 5.2 音频加载策略

iOS 键盘扩展内存有限，不建议启动时预加载全部音频。

推荐：

- 音频资源全部随包打入本地 bundle。
- 播放器按需懒加载。
- 每个音符保留 1-2 个播放器实例。
- 连续快速输入时，优先保证不卡顿，不追求复杂混音。

### 5.3 中文输入场景

中文输入法的 Typatone 风格可拆成两层：

#### 输入阶段

用户按拼音键，例如：

```text
n i h a o
```

键盘按英文字母映射播放。

#### 回放阶段

用户最终上屏中文：

```text
你好
```

后续如果要重放，可以转成拼音：

```text
ni hao
```

再映射成音符序列。

这样能保证中文文本也可以生成稳定旋律。

### 5.4 Mood 设计建议

后续可设计 6 种 mood，对应 Typatone 的启发，但不直接复刻：

| Mood | 方向 | 可能参数 |
| --- | --- | --- |
| Classic | 默认钢琴 | 中等速度、原始音色 |
| Soft | 柔和 | 低音量、慢速、轻触感 |
| Bright | 明亮 | 高音区略增强、较快 |
| Bass | 低频 | 偏低音映射、厚重反馈 |
| Night | 夜间 | 低音量、低亮度 UI、慢速 |
| Playful | 活泼 | 更高 accent 比例、速度更快 |

键盘扩展中 MVP 可先只保留 mood 字段，不做复杂音频处理。主 App 中再做完整回放和导出。

## 6. 当前项目已采用的 Typatone-inspired 方案

当前 M1 已从最初 8 音循环升级为 52 音方案：

- `assets/audio` 中 52 个 mp3 全部复制到 Swift Package 资源目录。
- `PianoMapping` 使用 Typatone 2019 用户输入数据的英文字母频率顺序：

```text
eaoitsnhrlduymgfcwkbpjvqzx
```

- 高频字母映射到 melodic notes。
- 中频字母映射到 bass notes。
- 低频字母映射到 accent notes。
- `PianoAudioPlayer` 使用懒加载，避免键盘启动时一次性加载全部音频。

## 7. 后续待验证问题

- 是否能获取 Typatone 官方 `stats.html` 的完整内容。
- 是否存在公开的精确字母到音符映射表。
- Typatone 的 6 种 mood 是否会改变音符映射，还是只改变速度、滤波和颜色。
- Typatone 的 sequencer 量化规则是否公开。
- 当前 52 音映射在真实中文输入中是否悦耳，需要真机体验后微调。

## 8. 推荐下一步

1. 先构建 IPA，在真机或目标安装方式中验证 M1 按键音是否工作。
2. 记录实际输入时的音色问题，例如过吵、延迟、音域跳跃过大。
3. 在 M3 设置面板中加入钢琴音开关、音量和 mood 选择。
4. 在主 App 中实现文本回放与音符序列保存。
5. 后续如果成功读取 Typatone 官方统计页，再补充精确调研结果。
