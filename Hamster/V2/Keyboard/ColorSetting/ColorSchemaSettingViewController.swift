//
//  ColorSchemaSettingViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import UIKit

class ColorSchemaSettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  init(parentController: SettingsViewController, appSettings: HamsterAppSettings) {
    self.parentController = parentController
    self.appSettings = appSettings
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private unowned let parentController: SettingsViewController
  private let appSettings: HamsterAppSettings

  lazy var colorSchemaViews: [HamsterColorSchema] = appSettings.rimeTotalColorSchemas.map { HamsterColorSchema(schema: $0) }

  lazy var label: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "启用配色"
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    return label
  }()

  lazy var toggle: UISwitch = {
    let toggle = UISwitch(frame: .zero)
    toggle.isOn = appSettings.enableRimeColorSchema
    toggle.addTarget(self, action: #selector(colorSchemaEnableHandled(_:)), for: .valueChanged)
    return toggle
  }()

  lazy var enableColorSchemaView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.alignment = .center
    stack.distribution = .equalCentering
    stack.spacing = 8

    stack.addArrangedSubview(self.label)
    stack.addArrangedSubview(self.toggle)

    stack.translatesAutoresizingMaskIntoConstraints = false

    return stack
  }()

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.isHidden = !appSettings.enableRimeColorSchema
    tableView.register(ColorSchemaTableViewCell.self, forCellReuseIdentifier: ColorSchemaTableViewCell.identifier)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.sectionFooterHeight = 8
    tableView.sectionHeaderHeight = 8
    tableView.estimatedSectionFooterHeight = 8
    tableView.estimatedSectionHeaderHeight = 8
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
}

// MARK: custom method

extension ColorSchemaSettingViewController {
  @objc func colorSchemaEnableHandled(_ sender: UISwitch) {
    appSettings.enableRimeColorSchema = sender.isOn
    tableView.isHidden = !sender.isOn
  }
}

// MARK: override UIViewController

extension ColorSchemaSettingViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .secondarySystemBackground
    view.addSubview(enableColorSchemaView)
    view.addSubview(tableView)
    NSLayoutConstraint.activate([
      enableColorSchemaView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1.0),
      enableColorSchemaView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
      enableColorSchemaView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

      tableView.topAnchor.constraint(equalToSystemSpacingBelow: enableColorSchemaView.bottomAnchor, multiplier: 1.0),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])

    if appSettings.enableRimeColorSchema {
      let (index, _) = appSettings.rimeTotalColorSchemas
        .enumerated()
        .first(where: { $1.schemaName == appSettings.rimeColorSchema }) ?? (-1, nil)

      if index != -1 {
        tableView.selectRow(at: IndexPath(row: 0, section: index), animated: false, scrollPosition: .none)
      }
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    parentController.tableView.reloadData()
  }
}

// MARK: implementation UITableViewDelegate, UITableViewDataSource

extension ColorSchemaSettingViewController {
  func numberOfSections(in tableView: UITableView) -> Int {
    colorSchemaViews.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ColorSchemaTableViewCell.identifier, for: indexPath)
    let colorSchema = colorSchemaViews[indexPath.section]
    if let cell = cell as? ColorSchemaTableViewCell {
      cell.colorSchema = colorSchema
    }
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let colorSchema = colorSchemaViews[indexPath.section]
    appSettings.rimeColorSchema = colorSchema.schemaName
  }
}
