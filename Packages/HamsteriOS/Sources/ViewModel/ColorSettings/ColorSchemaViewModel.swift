//
//  ColorSchemaViewModel.swift
//
//
//  Created by morse on 14/7/2023.
//

import HamsterModel
import UIKit

class ColorSchemaViewModel {
  // MARK: properties
  
  private unowned let settingsViewModel: SettingsViewModel
  
  @Published
  public var enableColorSchema: Bool {
    didSet {
      settingsViewModel.enableColorSchema = enableColorSchema
    }
  }
  
  public var useColorSchema: String {
    didSet {
      HamsterAppDependencyContainer.shared.configuration.Keyboard?.useColorSchema = useColorSchema
    }
  }
  
  public var keyboardColorList: [KeyboardColor]
  
  init(settingsViewModel: SettingsViewModel, configuration: HamsterConfiguration) {
    self.settingsViewModel = settingsViewModel
    self.enableColorSchema = configuration.Keyboard?.enableColorSchema ?? false
    self.useColorSchema = configuration.Keyboard?.useColorSchema ?? ""
    
    if let colorSchemas = configuration.Keyboard?.colorSchemas, !colorSchemas.isEmpty {
      self.keyboardColorList = colorSchemas.keys
        .compactMap {
          guard let colorSchema = colorSchemas[$0] else { return nil }
          return KeyboardColor(name: $0, colorSchema: colorSchema)
        }
    } else {
      self.keyboardColorList = []
    }
  }
  
  // MARK: methods
  
  @objc func colorSchemaEnableHandled(_ sender: UISwitch) {
    enableColorSchema = sender.isOn
    // TODO: 修改表格状态
//    appSettings.enableRimeColorSchema = sender.isOn
//    tableView.isHidden = !sender.isOn
  }
}
