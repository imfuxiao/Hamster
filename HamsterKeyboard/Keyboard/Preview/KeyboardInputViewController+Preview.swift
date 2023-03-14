import Foundation
import KeyboardKit

extension HamsterKeyboardViewController {
  /**
     This preview controller can be used in SwiftUI previews.
     */
  public static var hamsterPreview: HamsterKeyboardViewController {
    let controller = HamsterKeyboardViewController()
    controller.keyboardAppearance = HamsterKeyboardAppearance(keyboardContext: .preview)
    controller.keyboardLayoutProvider = HamsterStandardKeyboardLayoutProvider(
      keyboardContext: .preview, inputSetProvider: PreviewInputSetProvider())
    controller.keyboardActionHandler = HamsterKeyboardActionHandler(inputViewController: controller)
    //    controller.autocompleteProvider = HamsterAutocompleteProvider(engine: RimeEngine())
    //    controller.keyboardBehavior = HamsterKeyboardBehavior(keyboardContext: .hamsterPreview)
    //    controller.calloutActionProvider = DisabledCalloutActionProvider() // 禁用长按按钮
    //    controller.actionCalloutContext = HamsterActionCalloutContext(
    //      actionHandler: self.keyboardActionHandler,
    //      actionProvider: self.calloutActionProvider
    //    )

    return controller
  }
}
