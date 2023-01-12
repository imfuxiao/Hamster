import Foundation
import KeyboardKit
import LibrimeKit
import Plist
import UIKit

/**
 键盘ViewController
 */
open class HamsterKeyboardViewController: KeyboardInputViewController {
  public var rimeEngine = RimeEngine.shared
  
  @PlistWrapper(path: Bundle.module.url(forResource: "DefaultSkinExtend", withExtension: "plist")!)
  private var skinExtend: Plist
  
  override public func viewDidLoad() {
    #if DEBUG
      NSLog("viewDidLoad() begin")
    #endif
    
    self.keyboardLayoutProvider = HamsterStandardKeyboardLayoutProvider(inputSetProvider: self.inputSetProvider)
    self.keyboardActionHandler = HamsterKeyboardActionHandler(inputViewController: self, rimeEngine: self.rimeEngine)
    super.viewDidLoad()
  }
  
  deinit {
    self.rimeShutdown()
  }
  
  override public func viewWillSetupKeyboard() {
    #if DEBUG
      NSLog("viewWillSetupKeyboard() begin")
    #endif

    do {
      try rimeStart()
    } catch {
      print("rime start error: ")
      print(error.localizedDescription)
    }
    
    super.viewWillSetupKeyboard()
    let alphabetKeyboard = AlphabetKeyboard(list: skinExtend)
    setup(with: alphabetKeyboard)
  }
  
  // TODO: 文本改变后可以在这里做写什么
  override open func textDidChange(_ textInput: UITextInput?) {
//    super.textDidChange(textInput)
//    performAutocomplete()
//    tryChangeToPreferredKeyboardTypeAfterTextDidChange()
  }
}
