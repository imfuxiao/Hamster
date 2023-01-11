import KeyboardKit
import UIKit

/**
 This appearance can be used in SwiftUI previews.
 */
public class PreviewHamsterKeyboardAppearance: StandardKeyboardAppearance {
  init() {
    super.init(context: .preview)
  }
  
  override public func inputCalloutStyle() -> InputCalloutStyle {
    InputCalloutStyle(
      callout: CalloutStyle.preview1,
      calloutSize: CGSize(width: 0, height: 40),
      font: .body)
  }
  
  override public func actionCalloutStyle() -> ActionCalloutStyle {
    ActionCalloutStyle(
      callout: .preview1,
      font: .headline,
      selectedBackgroundColor: .yellow,
      selectedForegroundColor: .black,
      verticalTextPadding: 10)
  }
}

extension CalloutStyle {
  
  /**
   This internal style is only used in previews.
   */
  static var preview1 = CalloutStyle(
    backgroundColor: .red,
    borderColor: .white,
    buttonCornerRadius: 10,
    shadowColor: .green,
    shadowRadius: 3,
    textColor: .black)
  
  /**
   This internal style is only used in previews.
   */
  static var preview2 = CalloutStyle(
    backgroundColor: .green,
    borderColor: .white,
    buttonCornerRadius: 20,
    shadowColor: .black,
    shadowRadius: 10,
    textColor: .red)
}
