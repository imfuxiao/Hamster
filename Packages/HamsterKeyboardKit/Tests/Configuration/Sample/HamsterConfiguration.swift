//
//  File.swift
//
//
//  Created by morse on 2023/7/3.
//

import Foundation

@testable import HamsterKeyboardKit

extension HamsterConfiguration {
  /// 用于测试的模拟数据
  static let preview = HamsterConfiguration(
    general: GeneralConfiguration(
      enableAppleCloud: true,
      regexOnCopyFile: ["^.text|.yaml$"]),
    toolbar: KeyboardToolbarConfiguration(
      enableToolbar: true,
      heightOfToolbar: 65,
      displayKeyboardDismissButton: true,
      heightOfCodingArea: 15,
      codingAreaFontSize: 20, candidateWordFontSize: 25, candidateCommentFontSize: 18,
      displayIndexOfCandidateWord: true),
    Keyboard: KeyboardConfiguration(
      displayButtonBubbles: true,
      enableKeySounds: true,
      enableHapticFeedback: true,
      hapticFeedbackIntensity: 3,
      displaySemicolonButton: true,
      displaySpaceLeftButton: true,
      keyValueOfSpaceLeftButton: ",",
      displaySpaceRightButton: true,
      keyValueOfSpaceRightButton: ".",
      displayChineseEnglishSwitchButton: true,
      chineseEnglishSwitchButtonIsOnLeftOfSpaceButton: true,
      enableNineGridOfNumericKeyboard: true,
      enterDirectlyOnScreenByNineGridOfNumericKeyboard: true,
      symbolsOfGridOfNumericKeyboard: ["+", "-", "*", "/"],
      lockShiftState: true,
      enableEmbeddedInputMode: true,
      widthOfOneHandedKeyboard: 80,
      symbolsOfCursorBack: ["\"\"", "“”", "[]"],
      symbolsOfReturnToMainKeyboard: [",", ".", "!"],
      pairsOfSymbols: ["[]", "()", "“”"],
      enableSymbolKeyboard: true,
      lockForSymbolKeyboard: true,
      enableColorSchema: true,
      useColorSchema: "solarized_light",
      colorSchemas: [
        .init(
          schemaName: "solarized_light",
          name: "曬經・日／Solarized Light",
          author: "雪齋 <lyc20041@gmail.com>",
          backColor: "0xF0E5F6FB",
          borderColor: "0xEDFFFF",
          hilitedTextColor: "0x2C8BAE",
          hilitedBackColor: "0x4C4022",
          hilitedCandidateTextColor: "0x3942CB",
          hilitedCandidateBackColor: "0xD7E8ED",
          hilitedCommentTextColor: "0x8144C2",
          candidateTextColor: "0x005947",
          commentTextColor: "0x595E00")
      ]),
    rime: .init(
      maximumNumberOfCandidateWords: 30,
      keyValueOfSwitchSimplifiedAndTraditional: "simplified",
      overrideDictFiles: true),
    swipe: .init(
      xAxleSwipeSensitivity: 20,
      yAxleSwipeSensitivity: 30,
      spaceSwipeSensitivity: 50))

  static let sampleString = """
  # 通用配置
  general:
    enableAppleCloud: false
    regexOnCopyFile:
      - "^.text|.yaml$"

  # 工具栏
  toolbar:
    # 是否开启工具栏
    enableToolbar: true
    # 显示键盘 dissmiss 按钮
    displayKeyboardDismissButton: true
    # 工具栏总高度
    heightOfToolbar: 55
    # 拼写区高度(剩余高度由候选文字占用)
    heightOfCodingArea: 15
    # 拼写区字体大小
    codingAreaFontSize: 12
    # 候选文字字体大小
    candidateWordFontSize: 20
    # 候选文字备注信息字体大小。
    # 对应 rime 候选字的 comment 信息
    candidateCommentFontSize: 12
    # 是否显示候选文字索引
    displayIndexOfCandidateWord: false
    # 是否显示候选文字 Comment 信息
    displayCommentOfCandidateWord: false

  # 键盘相关配置
  Keyboard:
    # 使用键盘类型:
    # chinese: 中文26键
    # chineseNineGrid: 中文九宫格
    # custom(name): 自定义键盘，其中 name 对应自定义键盘配置(customizeKeyboards)中的 name。如: custom(中文26键)
    useKeyboardType: chinese
    # 上划显示到左侧
    upSwipeOnLeft: true
    displayButtonBubbles: true
    enableKeySounds: true
    enableHapticFeedback: false
    hapticFeedbackIntensity: 3
    displaySemicolonButton: false
    displayClassifySymbolButton: true
    displaySpaceLeftButton: true
    keyValueOfSpaceLeftButton: ","
    displaySpaceRightButton: false
    keyValueOfSpaceRightButton: "."
    displayChineseEnglishSwitchButton: true
    chineseEnglishSwitchButtonIsOnLeftOfSpaceButton: false
    enableNineGridOfNumericKeyboard: true
    enterDirectlyOnScreenByNineGridOfNumericKeyboard: true
    symbolsOfGridOfNumericKeyboard:
      - +
      - "-"
      - "*"
      - /
    lockShiftState: true
    enableEmbeddedInputMode: false
    widthOfOneHandedKeyboard: 80
    symbolsOfCursorBack:
      - '""'
      - "“”"
      - "[]"
    symbolsOfReturnToMainKeyboard:
      - ","
      - .
      - "!"
    symbolsOfChineseNineGridKeyboard:
      - "，"
      - "。"
      - "？"
      - "！"
      - "…"
      - "~"
      - "'"
      - "、"
    pairsOfSymbols:
      - "[]"
      - ()
      - "“”"
    enableSymbolKeyboard: true
    lockForSymbolKeyboard: false

    enableColorSchema: false
    useColorSchema: ""

    # 配色方案
    # 来源: https://github.com/rime/squirrel/blob/master/data/squirrel.yaml
    colorSchemas:
      - schemaName: aqua
        name: 碧水／Aqua
        author: 佛振 <chen.sst@gmail.com>
        text_color: 0x606060
        back_color: 0xeeeceeee
        candidate_text_color: 0x000000
        hilited_text_color: 0x000000
        hilited_candidate_text_color: 0xffffff
        hilited_candidate_back_color: 0xeefa3a0a
        comment_text_color: 0x5a5a5a
        hilited_comment_text_color: 0xfcac9d
      - schemaName: azure
        name: 青天／Azure
        author: 佛振 <chen.sst@gmail.com>
        text_color: 0xcfa677
        candidate_text_color: 0xffeacc
        back_color: 0xee8b4e01
        hilited_text_color: 0xffeacc
        hilited_candidate_text_color: 0x7ffeff
        hilited_candidate_back_color: 0x00000000
        comment_text_color: 0xc69664
      - schemaName: luna
        name: 明月／Luna
        author: 佛振 <chen.sst@gmail.com>
        text_color: 0xa5a5a5
        back_color: 0xdd000000
        candidate_text_color: 0xeceeee
        hilited_text_color: 0x7fffff
        hilited_candidate_text_color: 0x7fffff
        hilited_candidate_back_color: 0x40000000
        comment_text_color: 0xa5a5a5
        hilited_comment_text_color: 0x449c9d
      - schemaName: ink
        name: 墨池／Ink
        author: 佛振 <chen.sst@gmail.com>
        text_color: 0x5a5a5a
        back_color: 0xeeffffff
        candidate_text_color: 0x000000
        hilited_text_color: 0x000000
        #hilited_back_color: 0xdddddd
        hilited_candidate_text_color: 0xffffff
        hilited_candidate_back_color: 0xcc000000
        comment_text_color: 0x5a5a5a
        hilited_comment_text_color: 0x808080
      - schemaName: lost_temple
        name: 孤寺／Lost Temple
        author: 佛振 <chen.sst@gmail.com>, based on ir_black
        text_color: 0xe8f3f6
        back_color: 0xee303030
        hilited_text_color: 0x82e6ca
        hilited_candidate_text_color: 0x000000
        hilited_candidate_back_color: 0x82e6ca
        comment_text_color: 0xbb82e6ca
        hilited_comment_text_color: 0xbb203d34
      - schemaName: dark_temple
        name: 暗堂／Dark Temple
        author: 佛振 <chen.sst@gmail.com>, based on ir_black
        text_color: 0x92f6da
        back_color: 0x222222
        candidate_text_color: 0xd8e3e6
        hilited_text_color: 0xffcf9a
        hilited_back_color: 0x222222
        hilited_candidate_text_color: 0x92f6da
        hilited_candidate_back_color: 0x10000000 # 0x333333
        comment_text_color: 0x606cff
      - schemaName: psionics
        name: 幽能／Psionics
        author: 雨過之後、佛振
        text_color: 0xc2c2c2
        back_color: 0x444444
        candidate_text_color: 0xeeeeee
        hilited_text_color: 0xeeeeee
        hilited_back_color: 0x444444
        hilited_candidate_label_color: 0xfafafa
        hilited_candidate_text_color: 0xfafafa
        hilited_candidate_back_color: 0xd4bc00
        comment_text_color: 0x808080
        hilited_comment_text_color: 0x444444
      - schemaName: purity_of_form
        name: 純粹的形式／Purity of Form
        author: 雨過之後、佛振
        text_color: 0xc2c2c2
        back_color: 0x444444
        candidate_text_color: 0xeeeeee
        hilited_text_color: 0xeeeeee
        hilited_back_color: 0x444444
        hilited_candidate_text_color: 0x000000
        hilited_candidate_back_color: 0xfafafa
        comment_text_color: 0x808080
      - schemaName: purity_of_essence
        name: 純粹的本質／Purity of Essence
        author: 佛振
        text_color: 0x2c2ccc
        back_color: 0xfafafa
        candidate_text_color: 0x000000
        hilited_text_color: 0x000000
        hilited_back_color: 0xfafafa
        hilited_candidate_text_color: 0xeeeeee
        hilited_candidate_back_color: 0x444444
        comment_text_color: 0x808080
      - schemaName: starcraft
        name: 星際我爭霸／StarCraft
        author: Contralisk <contralisk@gmail.com>, original artwork by Blizzard Entertainment
        text_color: 0xccaa88
        candidate_text_color: 0x30bb55
        back_color: 0xee000000
        border_color: 0x1010a0
        hilited_text_color: 0xfecb96
        hilited_back_color: 0x000000
        hilited_candidate_text_color: 0x70ffaf
        hilited_candidate_back_color: 0x00000000
        comment_text_color: 0x1010d0
        hilited_comment_text_color: 0x1010f0
      - schemaName: google
        name: 谷歌／Google
        author: skoj <skoj@qq.com>
        text_color: 0x666666 #拼音串
        candidate_text_color: 0x000000 #非第一候选项
        back_color: 0xFFFFFF #背景
        border_color: 0xE2E2E2 #边框
        hilited_text_color: 0x000000 #拼音串高亮
        hilited_back_color: 0xFFFFFF #拼音串高亮背景
        hilited_candidate_text_color: 0xFFFFFF #第一候选项
        hilited_candidate_back_color: 0xCE7539 #第一候选项背景
        comment_text_color: 0x6D6D6D #注解文字
        hilited_comment_text_color: 0xEBC6B0 #注解文字高亮
      - schemaName: solarized_rock
        name: 曬經石／Solarized Rock
        author: "Aben <tntaben@gmail.com>, based on Ethan Schoonover's Solarized color scheme"
        back_color: 0x362b00
        border_color: 0x362b00
        text_color: 0x8236d3
        hilited_text_color: 0x98a12a
        candidate_text_color: 0x969483
        comment_text_color: 0xc098a12a
        hilited_candidate_text_color: 0xffffff
        hilited_candidate_back_color: 0x8236d3
        hilited_comment_text_color: 0x362b00
      - schemaName: clean_white
        name: 简约白／Clean White
        author: Chongyu Zhu <lembacon@gmail.com>, based on 搜狗「简约白」
        horizontal: true
        candidate_format: "%c %@"
        corner_radius: 6
        border_height: 6
        border_width: 6
        font_point: 16
        label_font_point: 12
        label_color: 0x888888
        text_color: 0x808080
        hilited_text_color: 0x000000
        candidate_text_color: 0x000000
        comment_text_color: 0x808080
        back_color: 0xeeeeee
        hilited_candidate_label_color: 0xa0c98915
        hilited_candidate_text_color: 0xc98915
        hilited_candidate_back_color: 0xeeeeee
      - schemaName: apathy
        name: 冷漠／Apathy
        author: LIANG Hai
        horizontal: true # 水平排列
        inline_preedit: true #单行显示，false双行显示
        candidate_format: "%c\\u2005%@\\u2005" # 编号 %c 和候选词 %@ 前后的空间
        corner_radius: 5 #候选条圆角
        border_height: 0
        border_width: 0
        back_color: 0xFFFFFF #候选条背景色
        font_face: "PingFangSC-Regular,HanaMinB" #候选词字体
        font_point: 16 #候选字词大小
        text_color: 0x424242 #高亮选中词颜色
        label_font_face: "STHeitiSC-Light" #候选词编号字体
        label_font_point: 12 #候选编号大小
        hilited_candidate_text_color: 0xEE6E00 #候选文字颜色
        hilited_candidate_back_color: 0xFFF0E4 #候选文字背景色
        comment_text_color: 0x999999 #拼音等提示文字颜色
      - schemaName: dust
        name: 浮尘／Dust
        author: Superoutman <asticosmo@gmail.com>
        horizontal: true # 水平排列
        inline_preedit: true #单行显示，false双行显示
        candidate_format: "%c\\u2005%@\\u2005" # 用 1/6 em 空格 U+2005 来控制编号 %c 和候选词 %@ 前后的空间。
        corner_radius: 2 #候选条圆角
        border_height: 3 # 窗口边界高度，大于圆角半径才生效
        border_width: 8 # 窗口边界宽度，大于圆角半径才生效
        back_color: 0xeeffffff #候选条背景色
        border_color: 0xE0B693 # 边框色
        font_face: "HYQiHei-55S Book,HanaMinA Regular" #候选词字体
        font_point: 14 #候选字词大小
        label_font_face: "SimHei" #候选词编号字体
        label_font_point: 10 #候选编号大小
        label_color: 0xcbcbcb # 预选栏编号颜色
        candidate_text_color: 0x555555 # 预选项文字颜色
        text_color: 0x424242 # 拼音行文字颜色，24位色值，16进制，BGR顺序
        comment_text_color: 0x999999 # 拼音等提示文字颜色
        hilited_text_color: 0x9e9e9e # 高亮拼音 (需要开启内嵌编码)
        hilited_candidate_text_color: 0x000000 # 第一候选项文字颜色
        hilited_candidate_back_color: 0xfff0e4 # 第一候选项背景背景色
        hilited_candidate_label_color: 0x555555 # 第一候选项编号颜色
        hilited_comment_text_color: 0x9e9e9e # 注解文字高亮
      - schemaName: mojave_dark
        name: 沙漠夜／Mojave Dark
        author: xiehuc <xiehuc@gmail.com>
        horizontal: true # 水平排列
        inline_preedit: true # 单行显示，false双行显示
        candidate_format: "%c\\u2005%@" # 用 1/6 em 空格 U+2005 来控制编号 %c 和候选词 %@ 前后的空间。
        corner_radius: 5 # 候选条圆角
        hilited_corner_radius: 3 # 高亮圆角
        border_height: 6 # 窗口边界高度，大于圆角半径才生效
        border_width: 6 # 窗口边界宽度，大于圆角半径才生效
        font_face: "PingFangSC" # 候选词字体
        font_point: 16 # 候选字词大小
        label_font_point: 14 # 候选编号大小
        text_color: 0xdedddd # 拼音行文字颜色，24位色值，16进制，BGR顺序
        back_color: 0x252320 # 候选条背景色
        label_color: 0x888785 # 预选栏编号颜色
        border_color: 0x020202 # 边框色
        candidate_text_color: 0xdedddd # 预选项文字颜色
        hilited_text_color: 0xdedddd # 高亮拼音 (需要开启内嵌编码)
        hilited_back_color: 0x252320 # 高亮拼音 (需要开启内嵌编码)
        hilited_candidate_text_color: 0xffffff # 第一候选项文字颜色
        hilited_candidate_back_color: 0xcb5d00 # 第一候选项背景背景色
        hilited_candidate_label_color: 0xffffff # 第一候选项编号颜色
        comment_text_color: 0xdedddd # 拼音等提示文字颜色
        #hilited_comment_text_color: 0xdedddd    # 注解文字高亮
      - schemaName: solarized_light
        name: 曬經・日／Solarized Light
        author: 雪齋 <lyc20041@gmail.com>
        color_space: display_p3 # Only available on macOS 10.12+
        back_color: 0xF0E5F6FB #Lab 97 , 0 , 10
        border_color: 0xEDFFFF #Lab 100, 0 , 10
        preedit_back_color: 0x403516 #Lab 20 ,-12,-12
        candidate_text_color: 0x595E00 #Lab 35 ,-35,-5
        label_color: 0xA36407 #Lab 40 ,-10,-45
        comment_text_color: 0x005947 #Lab 35 ,-20, 65
        text_color: 0xA1A095 #Lab 65 ,-5 ,-2
        hilited_back_color: 0x4C4022 #Lab 25 ,-12,-12
        hilited_candidate_back_color: 0xD7E8ED #Lab 92 , 0 , 10
        hilited_candidate_text_color: 0x3942CB #Lab 50 , 65, 45
        hilited_candidate_label_color: 0x2566C6 #Lab 55 , 45, 65
        hilited_comment_text_color: 0x8144C2 #Lab 50 , 65,-5
        hilited_text_color: 0x2C8BAE #Lab 60 , 10, 65
      - schemaName: solarized_dark
        name: 曬經・月／Solarized Dark
        author: 雪齋 <lyc20041@gmail.com>
        back_color: 0xF0352A0A #Lab 15 ,-12,-12
        border_color: 0x2A1F00 #Lab 10 ,-12,-12
        preedit_back_color: 0xD7E8ED #Lab 92 , 0 , 10
        candidate_text_color: 0x7389FF #Lab 75 , 65, 45
        label_color: 0x478DF4 #Lab 70 , 45, 65
        comment_text_color: 0xC38AFF #Lab 75 , 65,-5
        text_color: 0x756E5D #Lab 45 ,-7 ,-7
        hilited_back_color: 0xC9DADF #Lab 87 , 0 , 10
        hilited_candidate_back_color: 0x403516 #Lab 20 ,-12,-12
        hilited_candidate_text_color: 0x989F52 #Lab 60 ,-35,-5
        hilited_candidate_label_color: 0xCC8947 #Lab 55 ,-10,-45
        hilited_comment_text_color: 0x289989 #Lab 60 ,-20, 65
        hilited_text_color: 0xBE706D #Lab 50 , 15,-45

  # RIME 引擎相关配置
  rime:
    maximumNumberOfCandidateWords: 100
    keyValueOfSwitchSimplifiedAndTraditional: simplified
    overrideDictFiles: true
    regexOnOverrideDictFiles:
      - "^.*[.]userdb.*$"
      - "^.*[.]txt$"
    regexOnCopyAppGroupDictFile:
      - "^.*[.]userdb.*$"
      - "^.*[.]txt$"

  # 划动相关配置
  swipe:
    xAxleSwipeSensitivity: 20
    yAxleSwipeSensitivity: 30
    spaceSwipeSensitivity: 50
    keyboardSwipe:
      # 中文 26 键滑动设置
      - keyboardType: chinese
        keys:
          - action: character(a)
            swipe:
              - direction: up
                action: character(`)
                processByRIME: true
              - direction: down
                action: character(~)
                display: false
          - action: character(b)
            swipe:
              - direction: up
                action: symbol(《》)
              - direction: down
                action: character(。)
                display: false
          - action: character(c)
            swipe:
              - direction: up
                action: character(.)
              - direction: down
                action: character(>)
                display: false
          - action: character(d)
            swipe:
              - direction: up
                action: character(=)
              - direction: down
                action: character(+)
                display: false
          - action: character(e)
            swipe:
              - direction: up
                action: character(3)
              - direction: down
                action: character(#)
                display: false
          - action: character(f)
            swipe:
              - direction: up
                action: character([)
              - direction: down
                action: character({)
                display: false
          - action: character(g)
            swipe:
              - direction: up
                action: character(])
              - direction: down
                action: character(})
                display: false
          - action: character(h)
            swipe:
              - direction: up
                action: character(\\)
              - direction: down
                action: character(|)
                display: false
          - action: character(i)
            swipe:
              - direction: up
                action: character(8)
              - direction: down
                action: character(*)
                display: false
          - action: character(j)
            swipe:
              - direction: up
                action: character(/)
              - direction: down
                action: character(?)
                display: false
          - action: character(k)
            swipe:
              - direction: up
                action: character(;)
              - direction: down
                action: character(:)
                display: false
          - action: character(l)
            swipe:
              - direction: up
                action: character(')
              - direction: down
                action: character(")
                display: false
          - action: character(m)
            swipe:
              - direction: up
                action: shortCommand(#行尾)
              - direction: down
                action: character(、)
                display: false
          - action: character(n)
            swipe:
              - direction: up
                action: symbol(『』)
              - direction: down
                action: character(、)
                display: false
          - action: character(o)
            swipe:
              - direction: up
                action: character(9)
              - direction: down
                action: character(()
                display: false
          - action: character(p)
            swipe:
              - direction: up
                action: character(0)
              - direction: down
                action: character())
                display: false
          - action: character(q)
            swipe:
              - direction: up
                action: character(1)
              - direction: down
                action: character(!)
                display: false
          - action: character(r)
            swipe:
              - direction: up
                action: character(4)
              - direction: down
                action: character($)
                display: false
          - action: character(s)
            swipe:
              - direction: up
                action: character(-)
              - direction: down
                action: character(_)
                display: false
          - action: character(t)
            swipe:
              - direction: up
                action: character(5)
              - direction: down
                action: character(%)
                display: false
          - action: character(u)
            swipe:
              - direction: up
                action: character(7)
              - direction: down
                action: character(&)
                display: false
          - action: character(v)
            swipe:
              - direction: up
                action: symbol(“”)
              - direction: down
                action: character(，)
                display: false
          - action: character(w)
            swipe:
              - direction: up
                action: character(2)
              - direction: down
                action: character(@)
                display: false
          - action: character(x)
            swipe:
              - direction: up
                action: character(,)
              - direction: down
                action: character(<)
                display: false
          - action: character(y)
            swipe:
              - direction: up
                action: character(6)
              - direction: down
                action: character(^)
                display: false
          - action: character(z)
            swipe:
              - direction: up
                action: shortCommand(#行首)
              - direction: down
                action: symbol(‘’)
                display: false
          - action: space
            swipe:
              - direction: up
                action: shortCommand(#次选上屏)
                display: false
          - action: enter
            swipe:
              - direction: up
                action: shortCommand(#换行)
                display: false
          - action: backspace
            swipe:
              - direction: up
                action: shortCommand(#重输)
                display: false
          - action: keyboardType(numericNineGrid)
            swipe:
              - direction: up
                action: shortCommand(#上个输入方案)
                display: false
      # 中文九宫格滑动设置
      - keyboardType: chineseNineGrid
        keys:
          - action: chineseNineGrid(@/.)
            swipe:
              - direction: up
                action: character(1)
                display: true
          - action: chineseNineGrid(ABC)
            swipe:
              - direction: up
                action: character(2)
                display: true
          - action: chineseNineGrid(DEF)
            swipe:
              - direction: up
                action: character(3)
                display: true
          - action: chineseNineGrid(JKL)
            swipe:
              - direction: up
                action: character(5)
                display: true
          - action: chineseNineGrid(MNO)
            swipe:
              - direction: up
                action: character(6)
                display: true
          - action: chineseNineGrid(PQRS)
            swipe:
              - direction: up
                action: character(7)
                display: true
          - action: chineseNineGrid(TUV)
            swipe:
              - direction: up
                action: character(8)
                display: true
          - action: chineseNineGrid(WXYZ)
            swipe:
              - direction: up
                action: character(9)
                display: true
  # 自定义键盘
  customizeKeyboards:
    - name: "仓颉"
      rows:
        - keys:
            - action: character(手)
              swipe:
                - direction: up
                  action: character(1)
                  display: true
            - action: character(田)
              swipe:
                - direction: up
                  action: character(2)
                  display: true
            - action: character(水)
              swipe:
                - direction: up
                  action: character(3)
                  display: true
            - action: character(口)
              swipe:
                - direction: up
                  action: character(4)
                  display: true
            - action: character(廿)
              swipe:
                - direction: up
                  action: character(5)
                  display: true
            - action: character(卜)
              swipe:
                - direction: up
                  action: character(6)
                  display: true
            - action: character(山)
              swipe:
                - direction: up
                  action: character(7)
                  display: true
            - action: character(戈)
              swipe:
                - direction: up
                  action: character(8)
                  display: true
            - action: character(人)
              swipe:
                - direction: up
                  action: character(9)
                  display: true
            - action: character(心)
              swipe:
                - direction: up
                  action: character(0)
                  display: true
        - keys:
            - action: characterMargin(日)
              width: available
            - action: character(日)
              swipe:
                - direction: up
                  action: character(!)
                  display: true
            - action: character(尸)
              swipe:
                - direction: up
                  action: character(@)
                  display: true
            - action: character(木)
              swipe:
                - direction: up
                  action: character(#)
                  display: true
            - action: character(火)
              swipe:
                - direction: up
                  action: character($)
                  display: true
            - action: character(土)
              swipe:
                - direction: up
                  action: character(%)
                  display: true
            - action: character(竹)
              swipe:
                - direction: up
                  action: character(&)
                  display: true
            - action: character(十)
              swipe:
                - direction: up
                  action: character(*)
                  display: true
            - action: character(大)
              swipe:
                - direction: up
                  action: character(()
                  display: true
            - action: character(中)
              swipe:
                - direction: up
                  action: character())
                  display: true
            - action: characterMargin(中)
              width: available
        - keys:
            - action: keyboardType(classifySymbolic)
              width: percentage(0.13)
            - action: characterMargin(重)
              width: available
            - action: character(重)
              swipe:
                - direction: up
                  action: character(~)
                  display: true
            - action: character(難)
              swipe:
                - direction: up
                  action: character(:)
                  display: true
            - action: character(金)
              swipe:
                - direction: up
                  action: character(')
                  display: true
            - action: character(女)
              swipe:
                - direction: up
                  action: character(_)
                  display: true
            - action: character(月)
              swipe:
                - direction: up
                  action: character(,)
                  label: "，"
                  display: true
            - action: character(弓)
              swipe:
                - direction: up
                  action: character(.)
                  label: "。"
                  display: true
            - action: character(一)
              swipe:
                - direction: up
                  action: character(?)
                  label: "？"
                  display: true
            - action: characterMargin(一)
              width: available
            - action: backspace
              width: percentage(0.13)
        - keys:
            - action: keyboardType(alphabetic)
              width: percentage(0.13)
            - action: keyboardType(numeric)
              width: percentage(0.13)
            - action: space
              width: available
              label:
                loadingText: "仓输入法"
                text: "空格"
            - action: character(,)
              label: "，"
            - action: enter
              width:
                portrait: percentage(0.25)
                landscape: percentage(0.195)
    - name: "大千注音"
      rowHeight: 53.2
      buttonInsets: left(3),right(3),top(5),bottom(5)
      rows:
        - rowHeight: 43.2
          keys:
            - action: character(ㄅ)
              swipe:
                - direction: up
                  action: character(1)
                  display: true
            - action: character(ㄉ)
              swipe:
                - direction: up
                  action: character(2)
                  display: true
            - action: character(ˇ)
              swipe:
                - direction: up
                  action: character(3)
                  display: true
            - action: character(ˋ)
              swipe:
                - direction: up
                  action: character(4)
                  display: true
            - action: character(ㄓ)
              swipe:
                - direction: up
                  action: character(5)
                  display: true
            - action: character(ˊ)
              swipe:
                - direction: up
                  action: character(6)
                  display: true
            - action: character(˙)
              swipe:
                - direction: up
                  action: character(7)
                  display: true
            - action: character(ㄚ)
              swipe:
                - direction: up
                  action: character(8)
                  display: true
            - action: character(ㄞ)
              swipe:
                - direction: up
                  action: character(9)
                  display: true
            - action: character(ㄢ)
              swipe:
                - direction: up
                  action: character(0)
                  display: true
            - action: character(ㄦ)
              swipe:
                - direction: up
                  action: character(-)
                  display: true
        - keys:
            - action: characterMargin(ㄆ)
              width: available
            - action: character(ㄆ)
            - action: character(ㄊ)
            - action: character(ㄍ)
            - action: character(ㄐ)
            - action: character(ㄔ)
            - action: character(ㄗ)
            - action: character(ㄧ)
            - action: character(ㄛ)
            - action: character(ㄟ)
            - action: character(ㄣ)
            - action: characterMargin(ㄣ)
              width: available
        - keys:
            - action: characterMargin(ㄇ)
              width: available
            - action: character(ㄇ)
            - action: character(ㄋ)
            - action: character(ㄎ)
            - action: character(ㄑ)
            - action: character(ㄕ)
            - action: character(ㄘ)
            - action: character(ㄨ)
            - action: character(ㄜ)
            - action: character(ㄠ)
            - action: character(ㄤ)
            - action: characterMargin(ㄤ)
              width: available
        - keys:
            - action: character(ㄈ)
            - action: character(ㄌ)
            - action: character(ㄏ)
            - action: character(ㄒ)
            - action: character(ㄖ)
            - action: character(ㄙ)
            - action: character(ㄩ)
            - action: character(ㄝ)
            - action: character(ㄡ)
            - action: character(ㄥ)
            - action: backspace
        - keys:
            - action: keyboardType(alphabetic)
              width: percentage(0.13)
            - action: keyboardType(numeric)
              width: percentage(0.13)
            - action: keyboardType(classifySymbolic)
              width: percentage(0.13)
            - action: space
              width: available
              label:
                loadingText: "仓输入法"
                text: "空格"
            - action: character(,)
              label: "，"
            - action: enter
              width:
                portrait: percentage(0.25)
                landscape: percentage(0.195)

  """
}
