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

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
    tableView.contentInsetAdjustmentBehavior = .automatic
    return tableView
  }()

  private var subscriptions = Set<AnyCancellable>()

  // MARK: method

  init(frame: CGRect = .zero, settingsViewModel: SettingsViewModel) {
    self.settingsViewModel = settingsViewModel
    super.init(frame: frame)

    setupView()

//    settingsViewModel.$enableAppleCloud
//      .combineLatest(settingsViewModel.$enableColorSchema.eraseToAnyPublisher())
//      .receive(on: DispatchQueue.main)
//      .sink { [unowned self] _ in
//        tableView.reloadData()
//      }
//      .store(in: &subscriptions)
  }

  func setupView() {
    backgroundColor = UIColor.secondarySystemBackground
    constructViewHierarchy()
    activateViewConstraints()
  }

  override public func constructViewHierarchy() {
    addSubview(tableView)
    tableView.dataSource = self
    tableView.delegate = self
  }

  override public func activateViewConstraints() {
    tableView.fillSuperview()
  }
}

// MARK: override UIView

public extension SettingsRootView {
  override func didMoveToWindow() {
    super.didMoveToWindow()

    tableView.reloadData()
  }
}

extension SettingsRootView: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let setting = settingsViewModel.sections[indexPath.section].items[indexPath.row]
    setting.navigationAction?()
  }
}

extension SettingsRootView: UITableViewDataSource {
  public func numberOfSections(in tableView: UITableView) -> Int {
    settingsViewModel.sections.count
  }

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    settingsViewModel.sections[section].items.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath)
    guard let cell = cell as? SettingTableViewCell else { return cell }
    cell.updateWithSettingItem(settingsViewModel.sections[indexPath.section].items[indexPath.row])
    return cell
  }
}

extension SettingsRootView {
  static let favoriteRemark = """
  长按设置按钮可添加或移除至快捷区域；
  """
}
