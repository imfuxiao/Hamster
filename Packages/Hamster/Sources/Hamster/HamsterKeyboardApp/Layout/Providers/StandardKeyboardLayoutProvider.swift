import Foundation
import Plist
import KeyboardKit
import SwiftUI

class HamsterStandardKeyboardLayoutProvider: KeyboardLayoutProvider {
  /**
   Create a standard keyboard layout provider.
   
   - Parameters:
   - inputSetProvider: The input set provider to use.
   - dictationReplacement: An optional dictation replacement action.
   */
  public init(
    inputSetProvider: InputSetProvider,
    dictationReplacement: KeyboardAction? = nil)
  {
    self.inputSetProvider = inputSetProvider
    self.dictationReplacement = dictationReplacement
  }
  
  /**
   An optional dictation replacement action.
   */
  public let dictationReplacement: KeyboardAction?
  
  /**
   The input set provider to use.
   */
  public var inputSetProvider: InputSetProvider {
    didSet {
      iPadProvider.register(inputSetProvider: inputSetProvider)
      iPhoneProvider.register(inputSetProvider: inputSetProvider)
    }
  }
  
  /**
   The layout provider that is used for iPad devices.
   */
  lazy var iPadProvider = HamsteriPadKeyboardLayoutProvider(inputSetProvider: inputSetProvider)
  
  /**
   The layout provider that is used for iPhone devices.
   */
  lazy var iPhoneProvider = HamsteriPhoneKeyboardLayoutProvider(inputSetProvider: inputSetProvider)
  
  /**
   The layout provider that is used for iPhone devices.
   */
  open func keyboardLayoutProvider(for context: KeyboardContext) -> KeyboardLayoutProvider {
    context.deviceType == .pad ? iPadProvider : iPhoneProvider
  }
  
  /**
   Get a keyboard layout for a certain keyboard `context`.
   */
  open func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
    keyboardLayoutProvider(for: context)
      .keyboardLayout(for: context)
  }
  
  /**
   Register a new input set provider. This will be proxied
   down to the child providers.
   */
  open func register(inputSetProvider: InputSetProvider) {
    self.inputSetProvider = inputSetProvider
  }
}

struct HamsterStandardKeyboardLayoutProvider_Previews: PreviewProvider {
  
  @PlistWrapper(path: Bundle.main.url(forResource: "DefaultSkinExtend", withExtension: "plist")!)
  static var plist: Plist
  
  static let actionHandler = PreviewKeyboardActionHandler()
  
  @ViewBuilder
  static func previewButton(
    item: KeyboardLayoutItem,
    keyboardWidth: CGFloat,
    inputWidth: CGFloat) -> some View {
      switch item.action {
      case .space:
        Text("This is a space bar replacement")
          .frame(maxWidth: .infinity)
          .multilineTextAlignment(.center)
      default:
        SystemKeyboardButtonRowItem(
          content: previewButtonContent(item: item),
          item: item,
          keyboardContext: .preview,
          keyboardWidth: keyboardWidth,
          inputWidth: inputWidth,
          appearance: .preview,
          actionHandler: actionHandler)
      }
    }
  
  @ViewBuilder
  static func previewButtonContent(
    item: KeyboardLayoutItem) -> some View {
      switch item.action {
      case .character(let str):
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            if let action = plist[str].string {
              Text(action)
                .font(.system(size: 8))
            } else {
              Text(" ")
                .font(.system(size: 8))
            }
          }
          VStack(spacing: 0) {
            SystemKeyboardButtonText(
              text: str,
              action: item.action
            )
          }
          .font(.system(size: 22))
        }
      default:
        SystemKeyboardActionButtonContent(
          action: item.action,
          appearance: PreviewHamsterKeyboardAppearance(),
          keyboardContext: .preview
        )
      }
    }
  
  
  static var previews: some View {
    VStack {
      
      // 九宫格键盘
      SystemKeyboard(
        layout: .gridViewPreview,
        appearance: PreviewHamsterKeyboardAppearance(),
        actionHandler: PreviewKeyboardActionHandler(),
        keyboardContext: .preview,
        actionCalloutContext: nil,
        inputCalloutContext: nil,
        width: UIScreen.main.bounds.width)
      
      // 字母扩展键盘
      SystemKeyboard(
        layout: .alphabetPreview,
        appearance: PreviewHamsterKeyboardAppearance(),
        actionHandler: PreviewKeyboardActionHandler(),
        keyboardContext: .preview,
        actionCalloutContext: nil,
        inputCalloutContext: nil,
        width: UIScreen.main.bounds.width,
        buttonContent: previewButtonContent
      )
      
      // A keyboard that replaces the button content
//      SystemKeyboard(
//        layout: .preview,
//        appearance: PreviewHamsterKeyboardAppearance(),
//        actionHandler: PreviewKeyboardActionHandler(),
//        keyboardContext: .preview,
//        actionCalloutContext: nil,
//        inputCalloutContext: nil,
//        width: UIScreen.main.bounds.width,
//        buttonContent: previewButtonContent)
      
      // A keyboard that replaces entire button views
//      SystemKeyboard(
//        layout: .preview,
//        appearance: PreviewHamsterKeyboardAppearance(),
//        actionHandler: PreviewKeyboardActionHandler(),
//        keyboardContext: .preview,
//        actionCalloutContext: nil,
//        inputCalloutContext: nil,
//        width: UIScreen.main.bounds.width,
//        buttonView: previewButton)
      
    }.background(Color.yellow)
  }
}
