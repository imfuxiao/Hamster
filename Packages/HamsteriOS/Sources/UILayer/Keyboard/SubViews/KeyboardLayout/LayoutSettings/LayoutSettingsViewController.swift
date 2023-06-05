//
//  LayoutSettingsViewController.swift
//
//
//  Created by morse on 2023/9/13.
//

import Combine
import HamsterKeyboardKit
import HamsterUIKit
import ProgressHUD
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

    /// 中文 26 键右上导航添加按钮
    keyboardSettingsViewModel.segmentActionPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] action in
        if action == .chineseLayoutSwipeSettings {
          let addSwipeAction = UIAction { [unowned self] _ in
            alertOptionSheet(alertTitle: "新增滑动Action", addAlertOptions: { optionMenu in
              [KeyboardSettingsViewModel.KeyboardActionOption.character, KeyboardSettingsViewModel.KeyboardActionOption.symbol]
                .forEach { actionOption in
                  let action = UIAlertAction(title: actionOption.option, style: .default) { _ in
                    // 弹出字符设置文本框
                    self.alertText(alertTitle: "字符", submitTitle: "保存", submitCallback: { textField in
                      guard let char = textField.text, !char.isEmpty else { return }
                      let action: KeyboardAction = actionOption == .character ? .character(char) : .symbol(Symbol(char: char))
                      let key = Key(action: action)
                      let keyboardType: KeyboardType = .chinese(.lowercased)
                      guard !self.keyboardSettingsViewModel.swipeKeyExists(key, keyboardType: keyboardType) else {
                        ProgressHUD.failed("\(action.yamlString)已经存在")
                        return
                      }
                      self.keyboardSettingsViewModel.saveKeySwipe(key, keyboardType: keyboardType)
                      self.keyboardSettingsViewModel.chineseStanderSystemKeyboardSwipeListReloadSubject.send(true)
                    })
                  }
                  optionMenu.addAction(action)
                }
            })
          }
          let addSwipeItem = UIBarButtonItem(systemItem: .add, primaryAction: addSwipeAction)
          navigationItem.rightBarButtonItem = addSwipeItem
          return
        }
        navigationItem.rightBarButtonItem = nil
      }
      .store(in: &subscriptions)

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
