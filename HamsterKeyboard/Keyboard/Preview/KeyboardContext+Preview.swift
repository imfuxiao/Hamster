import KeyboardKit

extension KeyboardContext {
  public static var hamsterPreview: KeyboardContext {
    #if os(iOS) || os(tvOS)
      KeyboardContext(controller: HamsterKeyboardViewController.hamsterPreview)
    #else
      KeyboardContext()
    #endif
  }
}
