//
//  ColorSchemaRootView.swift
//
//
//  Created by morse on 14/7/2023.
//

import Combine
import HamsterUIKit
import UIKit

class KeyboardColorRootView: NibLessView {
  // MARK: properties

  private var subscriptions = Set<AnyCancellable>()
  private let keyboardColorViewModel: KeyboardColorViewModel

  lazy var label: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = "启用配色"
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    return label
  }()

  lazy var toggle: UISwitch = {
    let toggle = UISwitch(frame: .zero)
    toggle.setOn(keyboardColorViewModel.settingsViewModel.enableColorSchema, animated: false)
    toggle.addTarget(
      keyboardColorViewModel,
      action: #selector(keyboardColorViewModel.colorSchemaEnableHandled(_:)),
      for: .valueChanged)
    return toggle
  }()

  lazy var enableColorSchemaView = {
    let stack = UIStackView(arrangedSubviews: [label, toggle])
    stack.axis = .horizontal
    stack.alignment = .center
    stack.distribution = .equalCentering
    stack.spacing = 8
    return stack
  }()

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.isHidden = !keyboardColorViewModel.settingsViewModel.enableColorSchema
    tableView.register(KeyboardColorTableViewCell.self, forCellReuseIdentifier: KeyboardColorTableViewCell.identifier)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.sectionFooterHeight = 8
    tableView.sectionHeaderHeight = 8
    tableView.estimatedSectionFooterHeight = 8
    tableView.estimatedSectionHeaderHeight = 8
    tableView.rowHeight = UITableView.automaticDimension
    return tableView
  }()

  // MARK: methods

  init(frame: CGRect = .zero, keyboardColorViewModel: KeyboardColorViewModel) {
    self.keyboardColorViewModel = keyboardColorViewModel

    super.init(frame: frame)

    setupSubview()

    self.keyboardColorViewModel.settingsViewModel.$enableColorSchema
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        tableView.isHidden = !$0
      }
      .store(in: &subscriptions)
  }

  func setupSubview() {
    backgroundColor = .secondarySystemBackground

    addSubview(enableColorSchemaView)
    addSubview(tableView)

    tableView.translatesAutoresizingMaskIntoConstraints = false
    enableColorSchemaView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      enableColorSchemaView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      enableColorSchemaView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      enableColorSchemaView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

      tableView.topAnchor.constraint(equalToSystemSpacingBelow: enableColorSchemaView.bottomAnchor, multiplier: 1.0),
      tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }
}

extension KeyboardColorRootView: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    keyboardColorViewModel.keyboardColorList.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: KeyboardColorTableViewCell.identifier, for: indexPath)
    let keyboardColor = keyboardColorViewModel.keyboardColorList[indexPath.section]
    if let cell = cell as? KeyboardColorTableViewCell {
      cell.keyboardColor = keyboardColor
      cell.updatePreviewColor()
      cell.updateCellState(keyboardColor.schemaName == keyboardColorViewModel.useColorSchema)
    }
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let keyboardColor = keyboardColorViewModel.keyboardColorList[indexPath.section]
    keyboardColorViewModel.useColorSchema = keyboardColor.schemaName
    let cell = tableView.dequeueReusableCell(withIdentifier: KeyboardColorTableViewCell.identifier, for: indexPath)
    if let cell = cell as? KeyboardColorTableViewCell {
      cell.updateCellState(true)
    }
    tableView.reloadData()
  }
}
