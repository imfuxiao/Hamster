//
//  ColorSchemaViewModel.swift
//
//
//  Created by morse on 14/7/2023.
//

import HamsterKeyboardKit
import UIKit

class KeyboardColorViewModel {
  // MARK: properties

  public var enableColorSchema: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableColorSchema ?? false
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.enableColorSchema = newValue
    }
  }

  public var useColorSchema: String {
    get {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.useColorSchema ?? ""
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.useColorSchema = newValue
    }
  }

  public var keyboardColorList: [HamsterKeyboardColor] {
    if let colorSchemas = HamsterAppDependencyContainer.shared.configuration.Keyboard?.colorSchemas, !colorSchemas.isEmpty {
      return colorSchemas
        .sorted()
        .compactMap {
          HamsterKeyboardColor(colorSchema: $0)
        }
    }
    return []
  }
}
