import KeyboardKit

public extension KeyboardContext {
    static var hamsterPreview: KeyboardContext {
        #if os(iOS) || os(tvOS)
            KeyboardContext(controller: HamsterKeyboardViewController.hamsterPreview)
        #else
            KeyboardContext()
        #endif
    }
}
