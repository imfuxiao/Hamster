import Foundation

class KeyboardConstant {
  enum Character: String {
    case equal = "="
    case plus = "+"
    case minus = "-"
    case asterisk = "*"
    case slash = "/"
    case backspace //

    static let SlideUp = "↑" // 表示上滑 Upwards Arrow: https://www.compart.com/en/unicode/U+2191
    static let SlideDown = "↓" // 表示下滑 Downwards Arrow: https://www.compart.com/en/unicode/U+2193
    static let SlideLeft = "←" // 表示左滑 Leftwards Arrow: https://www.compart.com/en/unicode/U+2190
    static let SlideRight = "→" // 表示右滑 Rightwards Arrow: https://www.compart.com/en/unicode/U+2192
  }

  enum Action {
    static let endDragGesture = "endDragGesture"
  }

  enum ImageName {
    static let switchLanguage = "switchLanguage"
    static let chineseLanguageImageName = "cn"
    static let englishLanguageImageName = "en"
  }
}
