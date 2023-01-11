import KeyboardKit

extension KeyboardLayout {
  static var gridViewPreview: KeyboardLayout {
    let context = KeyboardContext.preview
    context.keyboardType = .custom(named: KeyboardConstant.keyboardType.GridView)
    return PreviewHamsterKeyboardLayoutProvider(context: context).keyboardLayout(for: context)
  }
  
  static var alphabetPreview: KeyboardLayout {
    return PreviewHamsterKeyboardLayoutProvider(context: .preview).keyboardLayout(for: .preview)
  }
}
