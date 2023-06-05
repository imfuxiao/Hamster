//
//  OpenProjectViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import UIKit

class OpenSourceProjectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  let openSourceList: [OpenSourceInfo] = [
    .init(name: "librime", projectURL: "https://github.com/rime/librime"),
    .init(name: "KeyboardKit", projectURL: "https://github.com/KeyboardKit/KeyboardKit"),
    .init(name: "SwiftyBeaver", projectURL: "https://github.com/SwiftyBeaver/SwiftyBeaver"),
    .init(name: "Runestone", projectURL: "https://github.com/simonbs/Runestone"),
    .init(name: "Vapor", projectURL: "https://github.com/vapor/vapor"),
    .init(name: "Leaf", projectURL: "https://github.com/vapor/leaf"),
    .init(name: "ProgressHUD", projectURL: "https://github.com/relatedcode/ProgressHUD"),
    .init(name: "IsScrolling", projectURL: "https://github.com/fatbobman/IsScrolling"),
    .init(name: "ZIPFoundation", projectURL: "https://github.com/weichsel/ZIPFoundation"),
  ]

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.register(OpenSourceTableViewCell.self, forCellReuseIdentifier: OpenSourceTableViewCell.identifier)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.delegate = self
    tableView.dataSource = self
    return tableView
  }()
}

// override UIViewController

extension OpenSourceProjectViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    let tableView = tableView
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
}

// implementation: UITableViewDelegate, UITableViewDataSource

extension OpenSourceProjectViewController {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    openSourceList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: OpenSourceTableViewCell.identifier, for: indexPath)

    if let cell = cell as? OpenSourceTableViewCell {
      cell.openSourceInfo = openSourceList[indexPath.row]
    }

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let openSourceInfo = openSourceList[indexPath.row]
    if let url = URL(string: openSourceInfo.projectURL) {
      UIApplication.shared.open(url)
    }
  }
}

class OpenSourceTableViewCell: UITableViewCell {
  static let identifier = "OpenSourceTableViewCell"

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.openSourceInfo = .init(name: "", projectURL: "")
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentConfiguration = UIListContentConfiguration.subtitleCell()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var openSourceInfo: OpenSourceInfo

  override func updateConfiguration(using state: UICellConfigurationState) {
    guard var config = contentConfiguration as? UIListContentConfiguration else { return }
    config.text = openSourceInfo.name
    config.secondaryText = openSourceInfo.projectURL
    contentConfiguration = config
  }
}

struct OpenSourceInfo {
  let name: String
  let projectURL: String
}
