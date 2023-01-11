import KeyboardKit
import SwiftUI

class HamsterKeyboardLayoutProvider: SystemKeyboardLayoutProvider {
  // MARK: 新增九宫格键盘类型
  
  /**
   Get a keyboard layout for a certain keyboard `context`.
   */
  override func keyboardLayout(for context: KeyboardContext) -> KeyboardLayout {
    let inputs = inputRows(for: context)
    let actions = self.actions(for: inputs, context: context)
    let items = self.items(for: actions, context: context)
    return KeyboardLayout(itemRows: items)
  }
  

  override func actionCharacters(for rows: InputSetRows, context: KeyboardContext) -> [[String]] {
    switch context.keyboardType {
    case .alphabetic(let casing): return rows.characters(for: casing)
    case .numeric: return rows.characters()
    case .symbolic: return rows.characters()
    case .custom(named: KeyboardConstant.keyboardType.GridView): return rows.characters()
    default: return []
    }
  }

  override func inputRows(for context: KeyboardContext) -> InputSetRows {
    switch context.keyboardType {
    case .alphabetic: return inputSetProvider.alphabeticInputSet.rows
    case .numeric: return inputSetProvider.numericInputSet.rows
    case .symbolic: return inputSetProvider.symbolicInputSet.rows
    case .custom(named: KeyboardConstant.keyboardType.GridView):
      return NumericInputSet(rows: [
        .init(chars: "+123"),
        .init(chars: "-456*"),
        .init(chars: "789/"),
        .init(chars: ",0."),
      ]).rows
    default: return []
    }
  }

  override func keyboardSwitchActionForBottomRow(for context: KeyboardContext) -> KeyboardAction? {
    switch context.keyboardType {
    case .alphabetic: return .keyboardType(.numeric)
    case .numeric: return .keyboardType(.alphabetic(.auto))
    case .symbolic: return .keyboardType(.alphabetic(.auto))
    case .custom(named: KeyboardConstant.keyboardType.GridView): return .keyboardType(.alphabetic(.auto))
    default: return nil
    }
  }
}

