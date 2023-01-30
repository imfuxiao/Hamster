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
  public var skinExtend: Plist
  
  @PlistWrapper(path: Bundle.module.url(forResource: "DefaultAction", withExtension: "plist")!)
  public var actionExtend: Plist
  
  override public func viewDidLoad() {
    #if DEBUG
      NSLog("viewDidLoad() begin")
    #endif
    
    do {
      try self.rimeStart()
    } catch {
      // TODO: RIME 异常启动处理
      print("rime start error: ")
      print(error.localizedDescription)
    }
    
    self.keyboardLayoutProvider = HamsterStandardKeyboardLayoutProvider(inputSetProvider: self.inputSetProvider)
    self.keyboardActionHandler = HamsterKeyboardActionHandler(inputViewController: self)
    self.autocompleteProvider = HamsterAutocompleteProvider(engine: self.rimeEngine)
    self.keyboardBehavior = HamsterKeyboardBehavior(keyboardContext: self.keyboardContext)
    self.calloutActionProvider = DisabledCalloutActionProvider() // 禁用长按按钮
    self.actionCalloutContext = HamsterActionCalloutContext(
      actionHandler: self.keyboardActionHandler,
      actionProvider: self.calloutActionProvider
    )
    
    super.viewDidLoad()
  }
  
  override public func viewWillSetupKeyboard() {
    #if DEBUG
      NSLog("viewWillSetupKeyboard() begin")
    #endif

    super.viewWillSetupKeyboard()
    let alphabetKeyboard = AlphabetKeyboard(list: skinExtend)
      .environmentObject(self.rimeEngine)
    setup(with: alphabetKeyboard)
  }
  
  // MARK: - Text And Selection Change
  
//  override open func selectionWillChange(_ textInput: UITextInput?) {
  ////    super.selectionWillChange(textInput)
//    resetAutocomplete()
//  }
//
//  override open func selectionDidChange(_ textInput: UITextInput?) {
  ////    super.selectionDidChange(textInput)
//    resetAutocomplete()
//  }
//
//  override open func textWillChange(_ textInput: UITextInput?) {
  ////    super.textWillChange(textInput)
  ////    if keyboardContext.textDocumentProxy === textDocumentProxy { return }
  ////    keyboardContext.textDocumentProxy = textDocumentProxy
//  }
//
//  // TODO: 文本改变后可以在这里做写什么
//  override open func textDidChange(_ textInput: UITextInput?) {
  ////    super.textDidChange(textInput)
  ////    performAutocomplete()
  ////    tryChangeToPreferredKeyboardTypeAfterTextDidChange()
//  }
}
