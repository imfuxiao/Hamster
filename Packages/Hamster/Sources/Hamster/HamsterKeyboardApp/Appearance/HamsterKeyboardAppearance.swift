import KeyboardKit

class HamsterKeyboardAppearance: StandardKeyboardAppearance {
  
  override func buttonText(for action: KeyboardAction) -> String? {
    action.hamsterButtonText(for: keyboardContext)
  }
  
}
