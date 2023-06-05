//
//  FileManagerViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/13.
//

import SwiftUI
import UIKit

class FileManagerViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  init(appSettings: HamsterAppSettings, rimeContext: RimeContext) {
    self.appSettings = appSettings
    self.rimeContext = rimeContext
    self.viewModel = FileManagerViewModel(appSettings: appSettings, rimeContext: rimeContext)
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let appSettings: HamsterAppSettings
  let rimeContext: RimeContext
  let viewModel: FileManagerViewModel

  lazy var segmentedControl: UISegmentedControl = {
    let tags: [String]
    if appSettings.enableAppleCloud {
      tags = ["通用", "应用文件", "键盘文件", "iCloud文件"]
    } else {
      tags = ["通用", "应用文件", "键盘文件"]
    }
    let segmentedControl = UISegmentedControl(items: tags)
    return segmentedControl
  }()

  lazy var subContentView = UIView(frame: .zero)

  lazy var settingTableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.delegate = self
    tableView.dataSource = self
    return tableView
  }()

  lazy var appDocumentFileBrowseView: FinderTableView = .init(controller: self, rootDirectoryURL: RimeContext.sandboxDirectory)

  lazy var appGroupDocumentFileBrowseView: FinderTableView = .init(controller: self, rootDirectoryURL: RimeContext.shareURL)

  lazy var iCloudDocumentFileBrowseView: FinderTableView? = {
    if let iCloudURL = FileManager.iCloudDocumentURL {
      return .init(controller: self, rootDirectoryURL: iCloudURL)
    }
    return nil
  }()
}

// MARK: override UIViewController

extension FileManagerViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    title = "方案文件管理"
    viewModel.controller = self

    let contentView = UIView(frame: .zero)
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.backgroundColor = UIColor.systemBackground
    view.addSubview(contentView)
    NSLayoutConstraint.activate([
      contentView.topAnchor.constraint(equalTo: view.topAnchor),
      contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])

    let segmentedControl = segmentedControl
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.addTarget(viewModel, action: #selector(viewModel.segmentChangeAction(sender:)), for: .valueChanged)
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(segmentedControl)
    NSLayoutConstraint.activate([
      segmentedControl.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
      segmentedControl.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      segmentedControl.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
    ])

    let subContentView = subContentView
    subContentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(subContentView)
    NSLayoutConstraint.activate([
      subContentView.topAnchor.constraint(equalToSystemSpacingBelow: segmentedControl.bottomAnchor, multiplier: 1.0),
      subContentView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      subContentView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      subContentView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
    ])

    switchSettingView()
  }

  func switchSettingView() {
    changeSubContentView(view: settingTableView)
  }

  func switchAppFileBrowse() {
    changeSubContentView(view: appDocumentFileBrowseView)
  }

  func switchAppGroupFileBrowse() {
    changeSubContentView(view: appGroupDocumentFileBrowseView)
  }

  func switchAppleCloudBrowse() {
    if let view = iCloudDocumentFileBrowseView {
      changeSubContentView(view: view)
    } else {
      let stackView = UIStackView(frame: .zero)
      stackView.axis = .vertical
      stackView.alignment = .center
      stackView.distribution = .fill

      let warringLabel = UILabel(frame: .zero)
      warringLabel.text = "iCloud异常"
      warringLabel.font = UIFont.preferredFont(forTextStyle: .body)
      stackView.addSubview(warringLabel)
      changeSubContentView(view: stackView)
    }
  }

  private func changeSubContentView(view: UIView) {
    subContentView.subviews.forEach { $0.removeFromSuperview() }
    view.translatesAutoresizingMaskIntoConstraints = false
    subContentView.addSubview(view)
    NSLayoutConstraint.activate([
      view.topAnchor.constraint(equalTo: subContentView.topAnchor),
      view.bottomAnchor.constraint(equalTo: subContentView.bottomAnchor),
      view.leadingAnchor.constraint(equalTo: subContentView.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: subContentView.trailingAnchor),
    ])
  }
}

// MARK: implementation UITableViewDelegate, UITableViewDataSource

extension FileManagerViewController {
  func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if section == 0 {
      return "指后缀为“.txt”及文件夹名包含“.userdb”下的文件"
    }
    return nil
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch (indexPath.section, indexPath.row) {
      case (0, 0):
        return ButtonTableViewCell(text: "拷贝键盘词库文件至应用") { [unowned self] in
          self.viewModel.copyAppGroupDictFileToAppDocument()
        }
      case (1, 0):
        return ButtonTableViewCell(text: "使用键盘文件覆盖应用文件") { [unowned self] in
          let alert = UIAlertController(title: "是否覆盖？", message: "覆盖后应用文件无法恢复，确认覆盖？", preferredStyle: .alert)
          alert.addAction(UIAlertAction(title: "确认", style: .destructive, handler: { [unowned self] _ in
            self.viewModel.overrideAppDocument()
          }))
          alert.addAction(UIAlertAction(title: "取消", style: .cancel))
          self.present(alert, animated: true, completion: nil)
        }
      default:
        return UITableViewCell(frame: .zero)
    }
  }
}
