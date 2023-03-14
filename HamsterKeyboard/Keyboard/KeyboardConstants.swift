import Foundation

class KeyboardConstant {
  enum keyboardType {
    static let NumberGrid = "numberGrid"  // 数字九宫格布局
  }

  enum CustomButton: String {
    case ChineseEnglishSwitch = "CnEnSwitch"  // 中英切换按钮
    case Wildcard = "wildcard"  // 通配符按钮

    var buttonText: String {
      switch self {
      case .Wildcard: return "`"
      case .ChineseEnglishSwitch: return "cn"
      }
    }
  }

  enum Character: String {
    case Equal = "="
    case Plus = "+"
    case Minus = "-"
    case Asterisk = "*"
    case Slash = "/"

    static let SlideUp = "↑"  // 表示上滑 Upwards Arrow: https://www.compart.com/en/unicode/U+2191
    static let SlideDown = "↓"  // 表示下滑 Downwards Arrow: https://www.compart.com/en/unicode/U+2193
  }

  enum Fuction: String {
    case SimplifiedTraditionalSwitch = "#繁简切换"
    case ChineseEnglishSwitch = "#中英切换"
    case BeginOfSentence = "#行首"
    case EndOfSentence = "#行尾"
    case SelectSecond = "#次选"
    case UndoCommitText = "#撤销上屏"
  }

  enum Action {
    static let endDragGesture = "endGragGesture"
  }

  enum KeySymbol: Int32 {
    case Backspace = 0xff08  // 退格键(删除键)
    case Return = 0xff0d  // 回车键
    case QuoteLeft = 0x0060  // 反引号(`), 标准键盘数字1左边的键
    case Plus = 0x002b  // +
    case Minus = 0x002d  // -
    case Comma = 0x002c  // ,
    case Period = 0x002e  // .
    case BracketLeft = 0x005b  // [
    case BracketRight = 0x005d  // ]

    func string() -> String {
      if let scalarValue = Unicode.Scalar(UInt32(rawValue)) {
        return String(scalarValue)
      }
      return ""
    }
  }
}
