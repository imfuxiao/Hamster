import KeyboardKit

extension KeyboardContext {
  // 屏幕是否纵向
  var isPortrait: Bool {
    #if os(iOS)
      return self.interfaceOrientation.isPortrait
    #else
      return false
    #endif
  }
}
