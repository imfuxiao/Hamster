//
//  AboutViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import ProgressHUD
import UIKit

class AboutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  init(appSettings: HamsterAppSettings) {
    self.appSettings = appSettings
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let appSettings: HamsterAppSettings

  lazy var cellInfos: [AboutCellInfo] = {
    [
      .init(text: "RIME版本", secondaryText: appSettings.rimeVersion),
      .init(text: "许可证", secondaryText: "GPLv3", type: .link, typeValue: "https://www.gnu.org/licenses/gpl-3.0.html"),
      .init(text: "联系邮箱", secondaryText: "morse.hsiao@gmail.com", type: .mail, typeValue: "morse.hsiao@gmail.com"),
      .init(text: "开源地址", secondaryText: "https://github.com/imfuxiao/Hamster", type: .link, typeValue: "https://github.com/imfuxiao/Hamster"),
      .init(text: "使用开源库列表", type: .navigation, accessoryType: .disclosureIndicator, navigationLink: OpenSourceProjectViewController()),
    ]
  }()

  lazy var headerView: UIView = {
    let stackView = UIStackView(frame: .zero)
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .equalSpacing
    stackView.spacing = 8

    let hStack = UIStackView()
    hStack.axis = .horizontal
    hStack.alignment = .center
    hStack.distribution = .equalCentering
    hStack.translatesAutoresizingMaskIntoConstraints = true

    let image = UIImage(named: traitCollection.userInterfaceStyle == .dark ? "HamsterWhite" : "Hamster")
    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    hStack.addArrangedSubview(imageView)
    // 使用HStack强制压缩图片高度
    hStack.heightAnchor.constraint(equalToConstant: 60).isActive = true
    stackView.addArrangedSubview(hStack)

    let titleLabel = UILabel(frame: .zero)
    titleLabel.text = "仓输入法"
    titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)
    stackView.addArrangedSubview(titleLabel)

    let versionLabel = UILabel(frame: .zero)
    versionLabel.text = appSettings.appVersion
    versionLabel.font = UIFont.preferredFont(forTextStyle: .caption2)
    stackView.addArrangedSubview(versionLabel)

    let containerView = UIView()
    containerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 150)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
      containerView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
      stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
    ])

    let gesture = UITapGestureRecognizer(target: self, action: #selector(copyAppVersion))
    containerView.addGestureRecognizer(gesture)

    return containerView
  }()

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(AboutTableViewCell.self, forCellReuseIdentifier: AboutTableViewCell.identifier)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
}

// MARK: override UIViewController and custom method

extension AboutViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let headerView = headerView

    let tableView = tableView
    tableView.delegate = self
    tableView.dataSource = self
    tableView.tableHeaderView = headerView
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: false)
    }
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    guard let tableHeaderView = tableView.tableHeaderView else { return }

    let width = tableView.bounds.width
    let size = tableHeaderView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height))
    if tableHeaderView.frame.size.height != size.height {
      tableHeaderView.frame.size = size
      tableView.tableHeaderView = tableHeaderView
    }
  }

  @objc func copyAppVersion() {
    UIPasteboard.general.string = appSettings.appVersion
    ProgressHUD.showSuccess("复制成功", interaction: false, delay: 1.5)
  }
}

// MARK: implementation UITableViewDataSource UITableViewDelegate

extension AboutViewController {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cellInfos.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: AboutTableViewCell.identifier, for: indexPath)
    if let cell = cell as? AboutTableViewCell {
      cell.aboutInfo = cellInfos[indexPath.row]
    }
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cellInfo = cellInfos[indexPath.row]
    if cellInfo.cellType == .navigation, let controller = cellInfo.navigationLink {
      navigationController?.pushViewController(controller, animated: true)
      return
    }
    cellInfo.tapAction()
    tableView.deselectRow(at: indexPath, animated: false)
  }
}

class AboutTableViewCell: UITableViewCell {
  static let identifier = "AboutTableViewCell"

  init(aboutInfo: AboutCellInfo) {
    self.aboutInfo = aboutInfo

    super.init(style: .default, reuseIdentifier: Self.identifier)
    var config = UIListContentConfiguration.valueCell()
    config.text = aboutInfo.text
    config.secondaryText = aboutInfo.secondaryText
    contentConfiguration = config
    if let type = aboutInfo.accessoryType {
      accessoryType = type
    }
  }

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.aboutInfo = .init(text: "")
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentConfiguration = UIListContentConfiguration.valueCell()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var aboutInfo: AboutCellInfo

  override func updateConfiguration(using state: UICellConfigurationState) {
    if var config = contentConfiguration as? UIListContentConfiguration {
      config.text = aboutInfo.text
      config.secondaryText = aboutInfo.secondaryText
      contentConfiguration = config
    }
    if let type = aboutInfo.accessoryType {
      accessoryType = type
    }
  }
}

enum AboutCellType {
  case link
  case mail
  case copy
  case navigation
}

class AboutCellInfo {
  init(text: String, secondaryText: String? = nil, type: AboutCellType = .copy, typeValue: String? = nil, accessoryType: UITableViewCell.AccessoryType? = nil, navigationLink: UIViewController? = nil) {
    self.text = text
    self.secondaryText = secondaryText
    self.cellType = type
    self.typeValue = typeValue
    self.accessoryType = accessoryType
    self.navigationLink = navigationLink
  }

  let text: String
  let secondaryText: String?
  let cellType: AboutCellType
  let typeValue: String?
  let accessoryType: UITableViewCell.AccessoryType?
  let navigationLink: UIViewController?

  @objc func tapAction() {
    Logger.shared.log.debug("tapAction: \(cellType)")
    switch cellType {
    case .link:
      if let link = typeValue, let url = URL(string: link) {
        UIApplication.shared.open(url)
      }
    case .mail:
      if let link = typeValue, let url = URL(string: "mailto:\(link)") {
        UIApplication.shared.open(url)
      }
    case .copy:
      UIPasteboard.general.string = secondaryText
      ProgressHUD.showSuccess("复制成功", interaction: false, delay: 1.5)
    default:
      break
    }
  }
}
