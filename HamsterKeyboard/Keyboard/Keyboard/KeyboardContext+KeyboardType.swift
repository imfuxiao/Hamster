import KeyboardKit

extension KeyboardContext {
    // 键盘类型是否为九宫格
    var isGridViewKeyboardType: Bool {
        switch self.keyboardType {
        case .custom(named: KeyboardConstant.keyboardType.NumberGrid):
            return true
        default:
            return false
        }
    }

    // 屏幕是否纵向
    var isPortrait: Bool {
        #if os(iOS)
            return self.interfaceOrientation.isPortrait
        #else
            return false
        #endif
    }
}
