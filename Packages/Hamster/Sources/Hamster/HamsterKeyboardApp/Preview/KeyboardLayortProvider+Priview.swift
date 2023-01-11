import KeyboardKit

extension KeyboardLayoutProvider where Self == PreviewHamsterKeyboardLayoutProvider{
  
  static var hamsterPreview: KeyboardLayoutProvider {
    return PreviewHamsterKeyboardLayoutProvider(context: .preview)
  }
}

/**
 This layout provider can be used in SwiftUI previews
 */
class PreviewHamsterKeyboardLayoutProvider: KeyboardLayoutProvider {
  let provider: KeyboardLayoutProvider
  
  init(context: KeyboardContext) {
    let inputProvider = StandardInputSetProvider(keyboardContext: context)
    self.provider = HamsterStandardKeyboardLayoutProvider(inputSetProvider: inputProvider)
  }
  
  func keyboardLayout(for context: KeyboardKit.KeyboardContext) -> KeyboardKit.KeyboardLayout {
    provider.keyboardLayout(for: context)
  }
  
  func register(inputSetProvider: KeyboardKit.InputSetProvider) {
    provider.register(inputSetProvider: inputSetProvider)
  }
}
