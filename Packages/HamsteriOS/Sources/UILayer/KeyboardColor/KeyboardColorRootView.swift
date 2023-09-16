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

  @Published
  private var selectCell: UITableViewCell?

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
        scrollToUseColorSchemaCell()
      }
      .store(in: &subscriptions)

    $selectCell
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] selectCell in
        if let cell = selectCell, let indexPath = tableView.indexPath(for: cell) {
          tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
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

  func scrollToUseColorSchemaCell() {
    // 初始view时，滚动到目标cell
    if keyboardColorViewModel.settingsViewModel.enableColorSchema {
      let useColorSchema = keyboardColorViewModel.useColorSchema
      let section = keyboardColorViewModel
        .keyboardColorList
        .firstIndex(where: { $0.schemaName == useColorSchema })
      if let section = section {
        let indexPath = IndexPath(row: 0, section: section)
        // 注意：这里必须在主线程做滚动，否则不能滚动到目标cell
        DispatchQueue.main.async { [unowned self] in
          tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
          tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
      }
    }
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    scrollToUseColorSchemaCell()
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
      cell.updatePreviewColor(keyboardColor)
    }
    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let keyboardColor = keyboardColorViewModel.keyboardColorList[indexPath.section]
    keyboardColorViewModel.useColorSchema = keyboardColor.schemaName
    if let selectCell = selectCell {
      if let selectIndexPath = tableView.indexPath(for: selectCell),
         selectIndexPath != indexPath
      {
        selectCell.setSelected(false, animated: false)
      }
    }
    selectCell = tableView.cellForRow(at: indexPath)
  }
}
