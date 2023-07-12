import KeyboardKit
import UIKit

extension KeyboardContext {
  // 屏幕是否纵向
  var isPortrait: Bool {
    #if os(iOS)
      return self.interfaceOrientation.isPortrait
    #else
      return false
    #endif
  }

  // 判断是否为全面屏
  var isFullScreen: Bool {
    // 如果是刘海屏
    if UIDevice.current.userInterfaceIdiom == .pad {
      return false
    }

    let size = UIScreen.main.bounds.size
    let notchValue = Int(size.width / size.height * 100)
    if notchValue == 216 || notchValue == 46 {
      return true
    }
    return false
  }
}
