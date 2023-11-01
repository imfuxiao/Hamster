//
//  ColorSchemaViewModel.swift
//
//
//  Created by morse on 14/7/2023.
//

import Combine
import HamsterKeyboardKit
import UIKit

class KeyboardColorViewModel {
  // MARK: properties

  public var enableColorSchema: Bool {
    get {
      HamsterAppDependencyContainer.shared.configuration.keyboard?.enableColorSchema ?? false
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.keyboard?.enableColorSchema = newValue
      HamsterAppDependencyContainer.shared.applicationConfiguration.keyboard?.enableColorSchema = newValue
    }
  }

  public var useColorSchemaForLight: String {
    get {
      HamsterAppDependencyContainer.shared.configuration.keyboard?.useColorSchemaForLight ?? ""
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.keyboard?.useColorSchemaForLight = newValue
      HamsterAppDependencyContainer.shared.applicationConfiguration.keyboard?.useColorSchemaForLight = newValue
    }
  }

  public var useColorSchemaForDark: String {
    get {
      HamsterAppDependencyContainer.shared.configuration.keyboard?.useColorSchemaForDark ?? ""
    }
    set {
      HamsterAppDependencyContainer.shared.configuration.keyboard?.useColorSchemaForDark = newValue
      HamsterAppDependencyContainer.shared.applicationConfiguration.keyboard?.useColorSchemaForDark = newValue
    }
  }

  public var keyboardColorList: [HamsterKeyboardColor] = []

  public func reloadKeyboardColorList(style: UIUserInterfaceStyle) {
    self.keyboardColorList = style == .light ? keyboardColorListForLight : keyboardColorListForDark
  }

  public var keyboardColorListForLight: [HamsterKeyboardColor] {
    if let colorSchemas = HamsterAppDependencyContainer.shared.configuration.keyboard?.colorSchemas, !colorSchemas.isEmpty {
      return colorSchemas
        .sorted()
        .compactMap {
          HamsterKeyboardColor(colorSchema: $0, userInterfaceStyle: .dark)
        }
    }
    return []
  }

  public var keyboardColorListForDark: [HamsterKeyboardColor] {
    if let colorSchemas = HamsterAppDependencyContainer.shared.configuration.keyboard?.colorSchemas, !colorSchemas.isEmpty {
      return colorSchemas
        .sorted()
        .compactMap {
          HamsterKeyboardColor(colorSchema: $0, userInterfaceStyle: .dark)
        }
    }
    return []
  }

  public var segmentActionSubject = CurrentValueSubject<UIUserInterfaceStyle, Never>(.light)
  public var segmentActionPublished: AnyPublisher<UIUserInterfaceStyle, Never> {
    segmentActionSubject.eraseToAnyPublisher()
  }

  @objc func segmentChangeAction(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      segmentActionSubject.send(.light)
    case 1:
      segmentActionSubject.send(.dark)
    default:
      return
    }
  }
}
