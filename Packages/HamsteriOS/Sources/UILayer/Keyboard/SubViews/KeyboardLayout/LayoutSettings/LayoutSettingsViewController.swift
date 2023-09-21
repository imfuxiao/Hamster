//
//  LayoutSettingsViewController.swift
//
//
//  Created by morse on 2023/9/13.
//

import Combine
import HamsterUIKit
import UIKit

/// 布局设置
class LayoutSettingsViewController: NibLessViewController {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel
  private var subscriptions = Set<AnyCancellable>()

  private lazy var chineseStanderSystemKeyboardSettingsView: ChineseStanderSystemKeyboardSettingsView = {
    let view = ChineseStanderSystemKeyboardSettingsView(keyboardSettingsViewModel: keyboardSettingsViewModel)
    return view
  }()

  private lazy var chineseNineGridKeyboardSettingsView: ChineseNineGridKeyboardSettingsView = {
    let view = ChineseNineGridKeyboardSettingsView(keyboardSettingsViewModel: keyboardSettingsViewModel)
    return view
  }()

  private lazy var customKeyboardSettingsView: CustomKeyboardSettingsView = {
    let view = CustomKeyboardSettingsView(keyboardSettingsViewModel: keyboardSettingsViewModel)
    return view
  }()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let settingsKeyboardType = keyboardSettingsViewModel.settingsKeyboardType {
      self.title = settingsKeyboardType.label
      if settingsKeyboardType.isChinesePrimaryKeyboard {
        self.view = self.chineseStanderSystemKeyboardSettingsView
      } else if settingsKeyboardType.isChineseNineGrid {
        self.view = self.chineseNineGridKeyboardSettingsView
      } else {
        self.view = self.customKeyboardSettingsView
      }
    }

    // 中文九宫格符号编辑
    keyboardSettingsViewModel.$symbolsOfChineseNineGridIsEditing
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] isEditing in
        guard keyboardSettingsViewModel.settingsKeyboardType?.isChineseNineGrid ?? false else {
          navigationItem.rightBarButtonItem = nil
          return
        }
        let rightBarButtonItem = UIBarButtonItem(
          title: isEditing ? "完成" : "编辑",
          style: .plain,
          target: keyboardSettingsViewModel,
          action: #selector(keyboardSettingsViewModel.changeSymbolsOfChineseNineGridEditorState)
        )
        navigationItem.rightBarButtonItem = rightBarButtonItem
      }
      .store(in: &subscriptions)
  }
}
