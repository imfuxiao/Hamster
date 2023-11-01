//
//  AppleCloudRootView.swift
//
//
//  Created by morse on 2023/7/6.
//

import HamsterKit
import HamsterUIKit
import ProgressHUD
import UIKit

class AppleCloudRootView: NibLessView {
  // MARK: properties

  let viewModel: AppleCloudViewModel

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(ToggleTableViewCell.self, forCellReuseIdentifier: ToggleTableViewCell.identifier)
    tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
    tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
    tableView.allowsSelection = false
    tableView.delegate = self
    tableView.dataSource = self
    return tableView
  }()

  // MARK: methods

  init(frame: CGRect = .zero, viewModel: AppleCloudViewModel) {
    self.viewModel = viewModel
    super.init(frame: frame)

    setupView()
  }

  func setupView() {
    constructViewHierarchy()
    activateViewConstraints()
  }

  override func constructViewHierarchy() {
    addSubview(tableView)
  }

  override func activateViewConstraints() {
    tableView.fillSuperview()
  }

  @objc func copyRegex() {
    UIPasteboard.general.string = Self.clipboardOnCopyToCloudFilterRegexRemark
    ProgressHUD.success("复制成功", delay: 1.5)
  }
}

extension AppleCloudRootView {
  override func didMoveToWindow() {
    super.didMoveToWindow()

    tableView.reloadData()
  }
}

extension AppleCloudRootView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    switch section {
    case 0:
      return TableFooterView(footer: Self.enableAppleCloudRemark)
    case 1:
      return TableFooterView(footer: Self.copyRemark)
    case 2:
      let footerView = TableFooterView(footer: Self.regexRemark)
      let gesture = UITapGestureRecognizer(target: self, action: #selector(copyRegex))
      gesture.cancelsTouchesInView = false
      footerView.addGestureRecognizer(gesture)
      return footerView
    default:
      break
    }
    return nil
  }
}

extension AppleCloudRootView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    viewModel.settings.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let settingItem = viewModel.settings[indexPath.section]

    if settingItem.type == .button {
      let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? ButtonTableViewCell else { return cell }
      cell.updateWithSettingItem(settingItem)
      return cell
    }

    if settingItem.type == .toggle {
      let cell = tableView.dequeueReusableCell(withIdentifier: ToggleTableViewCell.identifier, for: indexPath)
      guard let cell = cell as? ToggleTableViewCell else { return cell }
      cell.updateWithSettingItem(settingItem)
      return cell
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier, for: indexPath)
    guard let cell = cell as? TextFieldTableViewCell else { return cell }
    cell.updateWithSettingItem(settingItem)
    return cell
  }
}

extension AppleCloudRootView {
  static let enableAppleCloudRemark = """
  1. 启用后，“重新部署”会复制iCloud中仓输入法`RIME`文件夹下全部文件；
  2. 复制时，差异文件会被覆盖；
  """

  static let copyRemark = """
  默认为全量拷贝，如需过滤拷贝内容，需要结合过滤表达式一起使用；
  """

  static let regexRemark = """
  1. 过滤表达式在“重新部署”功能中也会生效；
  2. 多个正则表达式使用英文逗号分隔；
  3. 常用示例（点击可复制全部表达式，请按需修改）:
     * 过滤userdb目录 ^.*[.]userdb.*$
     * 过滤build目录 ^.*build.*$
     * 过滤SharedSupport目录 ^.*SharedSupport.*$
     * 过滤编译后的词库文件 ^.*[.]bin$
  """

  static let clipboardOnCopyToCloudFilterRegexRemark = "^.*[.]userdb.*$,^.*build.*$,^.*SharedSupport.*$,^.*[.]bin$"
}
