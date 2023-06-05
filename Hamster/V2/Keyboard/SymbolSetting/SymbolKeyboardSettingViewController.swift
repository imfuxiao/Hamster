//
//  SymbolKeyboardSettingViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/17.
//
import ProgressHUD
import UIKit

class SymbolKeyboardSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
}

// MARK: override UIViewController

extension SymbolKeyboardSettingViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "符号键盘"

    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    parentController.tableView.reloadData()
  }
}

// MARK: implementation UITableViewDelegate, UITableViewDataSource

extension SymbolKeyboardSettingViewController {
  func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      return ToggleTableViewCell(text: "启用符号键盘", toggleValue: appSettings.enableSymbolKeyboard, toggleHandled: { [unowned self] in
        appSettings.enableSymbolKeyboard = $0
      })
    }

    return ButtonTableViewCell(text: "常用符号 - 恢复默认值", textTintColor: .systemRed) {
      SymbolCategory.frequentSymbolProvider.rest()
      ProgressHUD.showSuccess("重置成功", interaction: false, delay: 1.5)
    }
  }
}
