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
    toggle.isOn = keyboardColorViewModel.enableColorSchema
    toggle.addTarget(
      keyboardColorViewModel,
      action: #selector(keyboardColorViewModel.colorSchemaEnableHandled(_:)),
      for: .valueChanged)
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

    return stack
  }()

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.isHidden = !keyboardColorViewModel.enableColorSchema
    tableView.register(KeyboardColorTableViewCell.self, forCellReuseIdentifier: KeyboardColorTableViewCell.identifier)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.sectionFooterHeight = 8
    tableView.sectionHeaderHeight = 8
    tableView.estimatedSectionFooterHeight = 8
    tableView.estimatedSectionHeaderHeight = 8
    return tableView
  }()

  // MARK: methods

  init(frame: CGRect = .zero, keyboardColorViewModel: KeyboardColorViewModel) {
    self.keyboardColorViewModel = keyboardColorViewModel

    super.init(frame: frame)
  }

  override func constructViewHierarchy() {
    backgroundColor = .secondarySystemBackground

    addSubview(enableColorSchemaView)
    addSubview(tableView)
  }

  override func activateViewConstraints() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    enableColorSchemaView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      enableColorSchemaView.topAnchor.constraint(equalToSystemSpacingBelow: safeAreaLayoutGuide.topAnchor, multiplier: 1.0),
      enableColorSchemaView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      enableColorSchemaView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

      tableView.topAnchor.constraint(equalToSystemSpacingBelow: enableColorSchemaView.bottomAnchor, multiplier: 1.0),
      tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    constructViewHierarchy()
    activateViewConstraints()

    keyboardColorViewModel.$enableColorSchema
      .receive(on: DispatchQueue.main)
      .sink {
        guard !$0 else { return }

        // TODO:
//        let (index, _) = appSettings.rimeTotalColorSchemas
//          .enumerated()
//          .first(where: { $1.schemaName == appSettings.rimeColorSchema }) ?? (-1, nil)
//
//        if index != -1 {
//          tableView.selectRow(at: IndexPath(row: 0, section: index), animated: false, scrollPosition: .none)
//        }
      }
      .store(in: &subscriptions)
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
    }
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let keyboardColor = keyboardColorViewModel.keyboardColorList[indexPath.section]
    keyboardColorViewModel.useColorSchema = keyboardColor.schemaName
  }
}
