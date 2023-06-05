//
//  NumberNineGridSettingViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import ProgressHUD
import UIKit

class NumberNineGridSettingViewController: UIViewController {
  init(appSettings: HamsterAppSettings, parentController: KeyboardSettingViewController) {
    self.appSettings = appSettings
    self.parentController = parentController
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private let appSettings: HamsterAppSettings
  unowned let parentController: KeyboardSettingViewController

  lazy var settingsTableView: UITableView = NumberNineGridSettingTableView(parentController: self, appSettings: appSettings)
  lazy var symbolsTableView: UITableView = NumberNineGridSymbolListTableView(appSettings: appSettings)
}

// MARK: override UIViewController

extension NumberNineGridSettingViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .secondarySystemBackground

    let segmentedControl = UISegmentedControl(items: ["设置", "符号列表"])
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.addTarget(self, action: #selector(segmentedControlChange(_:)), for: .valueChanged)
    navigationItem.titleView = segmentedControl

    changeTableView(tableView: settingsTableView)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    parentController.tableView.reloadData()
  }
}

// MARK: custom method

extension NumberNineGridSettingViewController {
  func changeTableView(tableView: UITableView) {
    view.subviews.forEach { $0.removeFromSuperview() }

    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.CustomKeyboardLayoutGuide.topAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }

  @objc func changeTableEditModel() {
    navigationItem.rightBarButtonItem?.title = !symbolsTableView.isEditing ? "完成" : "编辑"
    symbolsTableView.setEditing(!symbolsTableView.isEditing, animated: true)
  }

  @objc func segmentedControlChange(_ sender: UISegmentedControl) {
    if sender.selectedSegmentIndex == 1 {
      let rightBarButtonItem = UIBarButtonItem(title: !symbolsTableView.isEditing ? "编辑" : "完成", style: .plain, target: self, action: #selector(changeTableEditModel))
      navigationItem.rightBarButtonItem = rightBarButtonItem
      changeTableView(tableView: symbolsTableView)
      return
    }
    navigationItem.rightBarButtonItem = nil
    changeTableView(tableView: settingsTableView)
  }
}
