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
  
  public unowned let settingsViewModel: SettingsViewModel
  
  public var useColorSchema: String {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.useColorSchema = useColorSchema
    }
  }
  
  public var keyboardColorList: [HamsterKeyboardColor]
  
  init(settingsViewModel: SettingsViewModel, configuration: HamsterConfiguration) {
    self.settingsViewModel = settingsViewModel
    self.useColorSchema = configuration.Keyboard?.useColorSchema ?? ""
    
    if let colorSchemas = configuration.Keyboard?.colorSchemas, !colorSchemas.isEmpty {
      self.keyboardColorList = colorSchemas
        .sorted()
        .compactMap {
          HamsterKeyboardColor(colorSchema: $0)
        }
    } else {
      self.keyboardColorList = []
    }
  }
  
  // MARK: methods
  
  @objc func colorSchemaEnableHandled(_ sender: UISwitch) {
    settingsViewModel.enableColorSchema = sender.isOn
  }
}
