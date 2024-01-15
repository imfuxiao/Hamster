//
//  File.swift
//
//
//  Created by morse on 2023/7/7.
//

import Combine
import HamsterKit
import HamsterUIKit
import ProgressHUD
import UIKit

class AboutRootView: NibLessView {
  private let aboutViewModel: AboutViewModel

  lazy var logoImageView: UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    imageView.image = UIImage(named: "Hamster", in: .main, with: .none)
    return imageView
  }()

  lazy var logoImageStackView: UIStackView = {
    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.alignment = .center
    hStack.distribution = .equalCentering
    hStack.addArrangedSubview(logoImageView)

    hStack.translatesAutoresizingMaskIntoConstraints = true
    hStack.heightAnchor.constraint(equalToConstant: 60).isActive = true
    return hStack
  }()

  lazy var titleLabel: UILabel = {
    let titleLabel = UILabel(frame: .zero)
    titleLabel.text = L10n.App.name
    titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
    return titleLabel
  }()

  lazy var versionLabel: UILabel = {
    let versionLabel = UILabel(frame: .zero)
    versionLabel.text = AppInfo.appVersion
    versionLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
    return versionLabel
  }()

  lazy var headerStackView: UIStackView = {
    let stackView = UIStackView(frame: .zero)
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .equalSpacing
    stackView.spacing = 8

    stackView.addArrangedSubview(logoImageStackView)
    stackView.addArrangedSubview(titleLabel)
    stackView.addArrangedSubview(versionLabel)
    return stackView
  }()

  lazy var headerView: UIView = {
    let containerView = UIView()
    containerView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 150)
    containerView.addSubview(headerStackView)

    let gesture = UITapGestureRecognizer(target: self, action: #selector(copyAppVersion))
    containerView.addGestureRecognizer(gesture)

    return containerView
  }()

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.identifier)
    tableView.register(ButtonTableViewCell.self, forCellReuseIdentifier: ButtonTableViewCell.identifier)
    return tableView
  }()

  init(frame: CGRect = .zero, aboutViewModel: AboutViewModel) {
    self.aboutViewModel = aboutViewModel
    super.init(frame: frame)

    constructViewHierarchy()
    activateViewConstraints()
  }

  override func constructViewHierarchy() {
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableHeaderView = headerView
    addSubview(tableView)
  }

  override func activateViewConstraints() {
    tableView.fillSuperview()

    headerStackView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      headerStackView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 20),
      headerView.bottomAnchor.constraint(equalTo: headerStackView.bottomAnchor, constant: 20),
      headerStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
      headerStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
    ])
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    if let _ = window {
      guard let tableHeaderView = tableView.tableHeaderView else { return }

      let width = tableView.bounds.width
      let size = tableHeaderView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))
      if tableHeaderView.frame.size.height != size.height {
        tableHeaderView.frame.size = size
        tableView.tableHeaderView = tableHeaderView
      }
    }
  }

  @objc func copyAppVersion() {
    UIPasteboard.general.string = AppInfo.appVersion
    ProgressHUD.success(L10n.copySuccessfully, interaction: false, delay: 1.5)
  }
}

extension AboutRootView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    guard let _ = tableView.cellForRow(at: indexPath) else { return }
    let settings = aboutViewModel.settingItems[indexPath.section].items[indexPath.row]
    if settings.type == .navigation {
      settings.navigationAction?()
    } else {
      Task {
        try? await settings.buttonAction?()
      }
    }
  }
}

extension AboutRootView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return aboutViewModel.settingItems.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return aboutViewModel.settingItems[section].items.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let setting = aboutViewModel.settingItems[indexPath.section].items[indexPath.row]

    if setting.type == .button {
      let cell = tableView.dequeueReusableCell(withIdentifier: ButtonTableViewCell.identifier, for: indexPath)
      if let cell = cell as? ButtonTableViewCell {
        cell.updateWithSettingItem(setting)
      }
      return cell
    }

    let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.identifier, for: indexPath)
    if let cell = cell as? SettingTableViewCell {
      cell.updateWithSettingItem(setting)
    }
    return cell
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    aboutViewModel.settingItems[section].footer
  }
}
