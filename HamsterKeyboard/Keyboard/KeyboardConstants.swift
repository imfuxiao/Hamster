import Foundation

class KeyboardConstant {
  enum keyboardType: String, CaseIterable, Equatable {
    // "中文全键盘"
    case chinese
    // "拼音九宫格"
    case chineseNineGrid
    // "数字九宫格"
    case numberNineGrid
    // 中文符号
    case chineseSymbol

    var buttonName: String {
      switch self {
      case .numberNineGrid: return "123"
      case .chineseSymbol: return "#+="
      default: return "中"
      }
    }
  }

  enum Character: String {
    case equal = "="
    case plus = "+"
    case minus = "-"
    case asterisk = "*"
    case slash = "/"
    case backspace = "backspace" // 

    static let SlideUp = "↑" // 表示上滑 Upwards Arrow: https://www.compart.com/en/unicode/U+2191
    static let SlideDown = "↓" // 表示下滑 Downwards Arrow: https://www.compart.com/en/unicode/U+2193
    static let SlideLeft = "←" // 表示左滑 Leftwards Arrow: https://www.compart.com/en/unicode/U+2190
    static let SlideRight = "→" // 表示右滑 Rightwards Arrow: https://www.compart.com/en/unicode/U+2192
  }

  enum Action {
    static let endDragGesture = "endDragGesture"
  }

  enum ImageName {
    static let ChineseLanguageImageName = "cn"
    static let EnglishLanguageImageName = "en"
  }
}
