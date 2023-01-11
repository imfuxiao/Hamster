import Foundation
import KeyboardKit
import LibrimeKit
import Plist
import UIKit

/**
 键盘ViewController
 */
open class HamsterKeyboardViewController: KeyboardInputViewController {
  private var rimeEngine = RimeKit.shared
  
  @PlistWrapper(path: Bundle.module.url(forResource: "DefaultSkinExtend", withExtension: "plist")!)
  private var skinExtend: Plist
  
  override public func viewDidLoad() {
    #if DEBUG
      NSLog("viewDidLoad() begin")
    #endif
    
    self.keyboardLayoutProvider = HamsterStandardKeyboardLayoutProvider(inputSetProvider: self.inputSetProvider)
    self.keyboardActionHandler = HamsterKeyboardActionHandler(inputViewController: self)
    super.viewDidLoad()
  }
  
  override public func viewWillSetupKeyboard() {
    #if DEBUG
      NSLog("viewWillSetupKeyboard() begin")
    NSLog("controller view width = %f", KeyboardInputViewController.shared.view.frame.width)
    NSLog("screen width = %f", UIScreen.main.bounds.size.width)
    #endif
    
    super.viewWillSetupKeyboard()
    let alphabetKeyboard = AlphabetKeyboard(list: skinExtend)
    setup(with: alphabetKeyboard)
  }
  
  // TODO: 文本改变后可以在这里做写什么
  open override func textDidChange(_ textInput: UITextInput?) {
//    super.textDidChange(textInput)
//    performAutocomplete()
//    tryChangeToPreferredKeyboardTypeAfterTextDidChange()
  }
}
