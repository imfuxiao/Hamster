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
    label.text = L10n.ColorScheme.enableCustomKeyboardColor
    label.font = UIFont.preferredFont(forTextStyle: .headline)
    return label
  }()

  lazy var toggle: UISwitch = {
    let toggle = UISwitch(frame: .zero)
    toggle.addTarget(
      self,
      action: #selector(colorSchemaEnableHandled(_:)),
      for: .valueChanged)
    return toggle
  }()

  lazy var enableColorSchemaView = {
    let stack = UIStackView(arrangedSubviews: [label, toggle])
    stack.axis = .horizontal
    stack.alignment = .center
    stack.distribution = .equalCentering
    stack.spacing = 8
    stack.translatesAutoresizingMaskIntoConstraints = false
    return stack
  }()

  lazy var segmentedControl: UISegmentedControl = {
    let segmentedControl = UISegmentedControl(items: [L10n.ColorScheme.systemLightMode, L10n.ColorScheme.systemDarkMode])
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    segmentedControl.isHidden = !keyboardColorViewModel.enableColorSchema
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.addTarget(
      keyboardColorViewModel,
      action: #selector(keyboardColorViewModel.segmentChangeAction(sender:)),
      for: .valueChanged)
    return segmentedControl
  }()

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.translatesAutoresizingMaskIntoConstraints = false
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

  var currentStyle: UIUserInterfaceStyle {
    segmentedControl.selectedSegmentIndex == 0 ? .light : .dark
  }

  var hasLightColorScheme: Bool {
    segmentedControl.selectedSegmentIndex == 0
  }

  // MARK: methods

  init(frame: CGRect = .zero, keyboardColorViewModel: KeyboardColorViewModel) {
    self.keyboardColorViewModel = keyboardColorViewModel

    super.init(frame: frame)

    setupSubview()
    combine()
  }

  func setupSubview() {
    backgroundColor = .secondarySystemBackground

    addSubview(enableColorSchemaView)
    addSubview(segmentedControl)
    addSubview(tableView)

    NSLayoutConstraint.activate([
      enableColorSchemaView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      enableColorSchemaView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      enableColorSchemaView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

      segmentedControl.topAnchor.constraint(equalToSystemSpacingBelow: enableColorSchemaView.bottomAnchor, multiplier: 1),
      segmentedControl.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      segmentedControl.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),

      tableView.topAnchor.constraint(equalToSystemSpacingBelow: segmentedControl.bottomAnchor, multiplier: 1),
      tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  func combine() {
    keyboardColorViewModel.segmentActionPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        keyboardColorViewModel.reloadKeyboardColorList(style: $0)
        tableView.reloadData()
        scrollToUseColorSchemaCell()
      }
      .store(in: &subscriptions)
  }

  // 初始view时，滚动到目标cell
  func scrollToUseColorSchemaCell() {
    guard keyboardColorViewModel.enableColorSchema else { return }
    let useColorSchema = hasLightColorScheme ? keyboardColorViewModel.useColorSchemaForLight : keyboardColorViewModel.useColorSchemaForDark

    let section = keyboardColorViewModel.keyboardColorList
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

  @objc func colorSchemaEnableHandled(_ sender: UISwitch) {
    keyboardColorViewModel.enableColorSchema = sender.isOn
    tableView.isHidden = !sender.isOn
    segmentedControl.isHidden = !sender.isOn
    if sender.isOn {
      keyboardColorViewModel.reloadKeyboardColorList(style: currentStyle)
      tableView.reloadData()
      scrollToUseColorSchemaCell()
    }
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    toggle.setOn(keyboardColorViewModel.enableColorSchema, animated: false)
    segmentedControl.isHidden = !keyboardColorViewModel.enableColorSchema
    tableView.isHidden = !keyboardColorViewModel.enableColorSchema
    scrollToUseColorSchemaCell()
  }
}

extension KeyboardColorRootView: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func numberOfSections(in tableView: UITableView) -> Int {
    keyboardColorViewModel.keyboardColorList.count
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
    if hasLightColorScheme {
      keyboardColorViewModel.useColorSchemaForLight = keyboardColor.schemaName
    } else {
      keyboardColorViewModel.useColorSchemaForDark = keyboardColor.schemaName
    }
    scrollToUseColorSchemaCell()
  }
}
