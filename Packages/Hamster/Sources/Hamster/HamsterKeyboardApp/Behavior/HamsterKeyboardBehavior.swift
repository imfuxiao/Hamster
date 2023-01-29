import Foundation
import KeyboardKit

class HamsterKeyboardBehavior: KeyboardBehavior {
  var backspaceRange: KeyboardKit.DeleteBackwardRange {
    .char
  }
  
  func preferredKeyboardType(after gesture: KeyboardKit.KeyboardGesture, on action: KeyboardKit.KeyboardAction) -> KeyboardKit.KeyboardType {
    keyboardContext.keyboardType
  }
  
  func shouldEndSentence(after gesture: KeyboardKit.KeyboardGesture, on action: KeyboardKit.KeyboardAction) -> Bool {
    false
  }
  
  func shouldSwitchToCapsLock(after gesture: KeyboardKit.KeyboardGesture, on action: KeyboardKit.KeyboardAction) -> Bool {
    false
  }
  
  func shouldSwitchToPreferredKeyboardType(after gesture: KeyboardKit.KeyboardGesture, on action: KeyboardKit.KeyboardAction) -> Bool {
    false
  }
  
  func shouldSwitchToPreferredKeyboardTypeAfterTextDidChange() -> Bool {
    false
  }
  
  public let keyboardContext: KeyboardContext
  
  init(keyboardContext: KeyboardContext) {
    self.keyboardContext = keyboardContext
  }
}
