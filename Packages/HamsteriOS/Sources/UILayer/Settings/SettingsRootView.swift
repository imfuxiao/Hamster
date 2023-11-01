//
//  SettingsRootView.swift
//
//
//  Created by morse on 2023/7/5.
//

import Combine
import HamsterUIKit
import UIKit

public class SettingsRootView: NibLessView {
  // MARK: properties

  let settingsViewModel: SettingsViewModel
  let rimeViewModel: RimeViewModel
  let backupViewModel: BackupViewModel

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
    tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
    tableView.contentInsetAdjustmentBehavior = .automatic
    tableView.dataSource = self
    tableView.delegate = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()

  private var subscriptions = Set<AnyCancellable>()

  // MARK: method

  init(frame: CGRect = .zero, settingsViewModel: SettingsViewModel, rimeViewModel: RimeViewModel, backupViewModel: BackupViewModel) {
    self.settingsViewModel = settingsViewModel
    self.rimeViewModel = rimeViewModel
    self.backupViewModel = backupViewModel

    super.init(frame: frame)

    // 检测是否有收藏按钮，如果有则添加到初始化数据 settingsViewModel.sections 中
    // 注意：后续的动态变化将在 combine() 方法中，通过观测 UserDefaults.favoriteButtonSubject 值完成
    let favoriteButtons = UserDefaults.standard.getFavoriteButtons()
    if !favoriteButtons.isEmpty {
      let favoriteButtonSectionItems = favoriteButtons
        .compactMap {
          if let item = rimeViewModel.favoriteButtonSettings[$0] {
            return item
          } else if let item = backupViewModel.favoriteButtonSettings[$0] {
            return item
          }
          return nil
        }
        .map { [unowned self] item in
          var item = item
          let buttonAction = item.buttonAction
          item.buttonAction = {
            try? await buttonAction?()
            self.tableView.reloadData()
          }
          return item
        }

      let sectionsContainerFavoriteButtons = settingsViewModel.sections[0].items[0].type == .button
      if sectionsContainerFavoriteButtons {
        settingsViewModel.sections[0].items = favoriteButtonSectionItems
      } else {
        settingsViewModel.sections = [SettingSectionModel(items: favoriteButtonSectionItems)] + settingsViewModel.sections
      }
    }

    setupView()
    combine()
  }

  func setupView() {
//    backgroundColor = UIColor.secondarySystemBackground
    constructViewHierarchy()
    activateViewConstraints()
  }

  override public func constructViewHierarchy() {
    addSubview(tableView)
  }

  override public func activateViewConstraints() {
    tableView.fillSuperview()
  }

  func combine() {
    UserDefaults.favoriteButtonSubject
      .eraseToAnyPublisher()
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] favoriteButtons in
        // 注意: 这里使用了集合的第一个元素类型收来判断是否已经存在收藏按钮 section
        // 因为收藏按钮始终添加在第 0 个 section
        let sectionsContainerFavoriteButtons = settingsViewModel.sections[0].items[0].type == .button

        // 收藏按钮为空，但集合中却包含，则删除
        if favoriteButtons.isEmpty {
          if sectionsContainerFavoriteButtons {
            settingsViewModel.sections.remove(at: 0)
            tableView.reloadData()
          }
          return
        }

        let favoriteButtonSectionItems = favoriteButtons.compactMap {
          if let item = rimeViewModel.favoriteButtonSettings[$0] {
            return item
          } else if let item = backupViewModel.favoriteButtonSettings[$0] {
            return item
          }
          return nil
        }

        if sectionsContainerFavoriteButtons {
          settingsViewModel.sections[0].items = favoriteButtonSectionItems
        } else {
          settingsViewModel.sections = [SettingSectionModel(items: favoriteButtonSectionItems)] + settingsViewModel.sections
        }
        tableView.reloadData()
      }
      .store(in: &subscriptions)
  }
}

// MARK: override UIView

public extension SettingsRootView {
  override func didMoveToWindow() {
    super.didMoveToWindow()

    if let _ = window {
      tableView.reloadData()
    }
  }
}

extension SettingsRootView: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let setting = settingsViewModel.sections[indexPath.section].items[indexPath.row]
    setting.navigationAction?()
  }

//  public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//    let setting = settingsViewModel.sections[section].items[0]
//    if setting.type == .button {
//      return Self.favoriteRemark
//    }
//    return nil
//  }
}

extension SettingsRootView: UITableViewDataSource {
  public func numberOfSections(in tableView: UITableView) -> Int {
    return settingsViewModel.sections.count
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return settingsViewModel.sections[section].items.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let settings = settingsViewModel.sections[indexPath.section].items[indexPath.row]

    if settings.type == .button {
      let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? ButtonTableViewCell else { return cell }
      cell.updateWithSettingItem(settings)
      return cell
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath)
    guard let cell = cell as? SettingTableViewCell else { return cell }
    cell.updateWithSettingItem(settings)
    return cell
  }
}

extension SettingsRootView {
  static let favoriteRemark = """
  长按按钮可添加或移除快捷区域
  """
}
