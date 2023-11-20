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

public class HamsterUIImage: KeyboardImageReader {
  public static let shared = HamsterUIImage()
  private init() {}
  public lazy var keyboard: UIImage = .init(systemName: "keyboard")!
  public lazy var keyboardBackspace: UIImage = .init(systemName: "delete.left")!
  public lazy var keyboardBackspaceRtl: UIImage = .init(systemName: "delete.right")!
  public lazy var keyboardCommand: UIImage = .init(systemName: "command")!
  public lazy var keyboardControl: UIImage = .init(systemName: "control")!
  public lazy var keyboardDictation: UIImage = .init(systemName: "mic")!
  public lazy var keyboardDismiss: UIImage = .init(systemName: "keyboard.chevron.compact.down")!
  public lazy var keyboardEmail: UIImage = .init(systemName: "envelope")!
  public lazy var keyboardEmoji: UIImage = .asset("keyboardEmoji")!
  public lazy var keyboardStateChinese: UIImage = .asset("chineseState")!
  public lazy var keyboardStateEnglish: UIImage = .asset("englishState")!
  public lazy var keyboardEmojiSymbol: UIImage = .init(systemName: "face.smiling")!
  public lazy var keyboardGlobe: UIImage = .init(systemName: "globe")!
  public lazy var keyboardImages: UIImage = .init(systemName: "photo")!
  public lazy var keyboardLeft: UIImage = .init(systemName: "arrow.left")!
  public lazy var keyboardNewline: UIImage = .init(systemName: "arrow.turn.down.left")!
  public lazy var keyboardNewlineRtl: UIImage = .init(systemName: "arrow.turn.down.right")!
  public lazy var keyboardOption: UIImage = .init(systemName: "option")!
  public lazy var keyboardRedo: UIImage = .init(systemName: "arrow.uturn.right")!
  public lazy var keyboardRight: UIImage = .init(systemName: "arrow.right")!
  public lazy var keyboardSettings: UIImage = .init(systemName: "gearshape")!
  public lazy var keyboardShiftCapslocked: UIImage = .init(systemName: "capslock.fill")!
  public lazy var keyboardShiftLowercased: UIImage = .init(systemName: "shift")!
  public lazy var keyboardShiftUppercased: UIImage = .init(systemName: "shift.fill")!
  public lazy var keyboardTab: UIImage = .init(systemName: "arrow.right.to.line")!
  public lazy var keyboardUndo: UIImage = .init(systemName: "arrow.uturn.left")!
  public lazy var keyboardZeroWidthSpace: UIImage = .init(systemName: "circle.dotted")!

  public func keyboardNewline(for locale: Locale) -> UIImage {
    locale.isLeftToRight ? self.keyboardNewline : self.keyboardNewlineRtl
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
