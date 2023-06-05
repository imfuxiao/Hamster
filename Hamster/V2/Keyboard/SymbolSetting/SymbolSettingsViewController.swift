//
//  SymbolSettingsViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/17.
//

import UIKit

class SymbolSettingsViewController: UIViewController {
  init(appSettings: HamsterAppSettings) {
    self.appSettings = appSettings
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let appSettings: HamsterAppSettings

  lazy var segmentedView: UISegmentedControl = {
    let segmentedControl = UISegmentedControl(items: ["设置", "成对上屏", "光标居中", "返回主键盘"])
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.addTarget(self, action: #selector(segmentedControlChange(_:)), for: .valueChanged)
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    return segmentedControl
  }()

  lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .secondarySystemBackground
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  lazy var symbolSettingTableView: SymbolTableView = {
    let tableView = SymbolTableView(parentController: self, appSettings: appSettings)
    return tableView
  }()

  lazy var pairsOfSymbolsTableView: SymbolEditTableView = {
    let tableView = SymbolEditTableView(symbols: appSettings.pairsOfSymbols, saveSymbols: { [unowned self] in
      appSettings.pairsOfSymbols = $0
    })
    return tableView
  }()

  lazy var cursorBackOfSymbolsTableView: SymbolEditTableView = {
    let tableView = SymbolEditTableView(symbols: appSettings.cursorBackOfSymbols, saveSymbols: { [unowned self] in
      appSettings.cursorBackOfSymbols = $0
    })
    return tableView
  }()

  lazy var returnToPrimaryKeyboardOfSymbolsTableView: SymbolEditTableView = {
    let tableView = SymbolEditTableView(symbols: appSettings.returnToPrimaryKeyboardOfSymbols, saveSymbols: { [unowned self] in
      appSettings.returnToPrimaryKeyboardOfSymbols = $0
    })
    return tableView
  }()
}

// MARK: custom method

extension SymbolSettingsViewController {
  @objc func segmentedControlChange(_ sender: UISegmentedControl) {
    var tableView: UITableView?
    switch sender.selectedSegmentIndex {
    case 0:
      tableView = symbolSettingTableView
    case 1:
      tableView = pairsOfSymbolsTableView
    case 2:
      tableView = cursorBackOfSymbolsTableView
    case 3:
      tableView = returnToPrimaryKeyboardOfSymbolsTableView
    default:
      tableView = nil
    }

    if let tableView = tableView {
      changeTableView(tableView: tableView)
    }
  }

  func changeTableView(tableView: UITableView) {
    containerView.subviews.forEach { $0.removeFromSuperview() }

    containerView.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
    ])
  }
}

// MARK: override UIViewController

extension SymbolSettingsViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "符号设置"

    view.backgroundColor = .secondarySystemBackground
    view.addSubview(segmentedView)
    view.addSubview(containerView)

    NSLayoutConstraint.activate([
      segmentedView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0),
      segmentedView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      segmentedView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

      containerView.topAnchor.constraint(equalToSystemSpacingBelow: segmentedView.bottomAnchor, multiplier: 1.0),
      containerView.bottomAnchor.constraint(equalTo: view.CustomKeyboardLayoutGuideNoSafeArea.topAnchor),
      containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])

    changeTableView(tableView: symbolSettingTableView)
  }
}
