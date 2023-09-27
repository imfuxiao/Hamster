//
//  KeyboardImageReader.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-03-11.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import UIKit

/**
 This protocol can be implemented by any type that should be
 able to access keyboard-specific images.

 该协议可以由任何能够访问键盘特定图像的类型来实现。

 This protocol is implemented by `UIImage`. This means that it
 is possible to use e.g. `Image.keyboardSettings` to get the
 standard keyboard settings icon.

 该协议由 `UIImage` 实现。这意味着可以使用 `UIImage.keyboardSettings` 来获取标准键盘设置图标。
 */
public protocol KeyboardImageReader {}

extension UIImage: KeyboardImageReader {}

public extension KeyboardImageReader {
  static var keyboard: UIImage { .init(systemName: "keyboard")! }
  static var keyboardBackspace: UIImage { .init(systemName: "delete.left")! }
  static var keyboardBackspaceRtl: UIImage { .init(systemName: "delete.right")! }
  static var keyboardCommand: UIImage { .init(systemName: "command")! }
  static var keyboardControl: UIImage { .init(systemName: "control")! }
  static var keyboardDictation: UIImage { .init(systemName: "mic")! }
  static var keyboardDismiss: UIImage { .init(systemName: "keyboard.chevron.compact.down")! }
  static var keyboardEmail: UIImage { .init(systemName: "envelope")! }
  static var keyboardEmoji: UIImage { .asset("keyboardEmoji")! }
  static var keyboardStateChinese: UIImage { .asset("chineseState")! }
  static var keyboardStateEnglish: UIImage { .asset("englishState")! }
  static var keyboardEmojiSymbol: UIImage { .init(systemName: "face.smiling")! }
  static var keyboardGlobe: UIImage { .init(systemName: "globe")! }
  static var keyboardImages: UIImage { .init(systemName: "photo")! }
  static var keyboardLeft: UIImage { .init(systemName: "arrow.left")! }
  static var keyboardNewline: UIImage { .init(systemName: "arrow.turn.down.left")! }
  static var keyboardNewlineRtl: UIImage { .init(systemName: "arrow.turn.down.right")! }
  static var keyboardOption: UIImage { .init(systemName: "option")! }
  static var keyboardRedo: UIImage { .init(systemName: "arrow.uturn.right")! }
  static var keyboardRight: UIImage { .init(systemName: "arrow.right")! }
  static var keyboardSettings: UIImage { .init(systemName: "gearshape")! }
  static var keyboardShiftCapslocked: UIImage { .init(systemName: "capslock.fill")! }
  static var keyboardShiftLowercased: UIImage { .init(systemName: "shift")! }
  static var keyboardShiftUppercased: UIImage { .init(systemName: "shift.fill")! }
  static var keyboardTab: UIImage { .init(systemName: "arrow.right.to.line")! }
  static var keyboardUndo: UIImage { .init(systemName: "arrow.uturn.left")! }
  static var keyboardZeroWidthSpace: UIImage { .init(systemName: "circle.dotted")! }

  static func keyboardNewline(for locale: Locale) -> UIImage {
    locale.isLeftToRight ? .keyboardNewline : .keyboardNewlineRtl
  }
}

extension UIImage {
  static func asset(_ name: String) -> UIImage? {
    UIImage(named: name, in: .hamsterKeyboard, with: .none)
  }

  static func symbol(_ name: String) -> UIImage? {
    UIImage(systemName: name)
  }
}
