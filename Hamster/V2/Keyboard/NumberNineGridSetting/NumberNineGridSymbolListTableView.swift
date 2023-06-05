//
//  NumberNineGridSymbolListTableView.swift
//  Hamster
//
//  Created by morse on 2023/6/16.
//

import UIKit

class NumberNineGridSymbolListTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
  init(appSettings: HamsterAppSettings) {
    self.appSettings = appSettings
    super.init(frame: .zero, style: .insetGrouped)
    register(NumberNineGridOfSymbolTableViewCell.self, forCellReuseIdentifier: NumberNineGridOfSymbolTableViewCell.identifier)
    self.delegate = self
    self.dataSource = self
    self.allowsSelection = false
    self.tableHeaderView = headerView
    self.translatesAutoresizingMaskIntoConstraints = false
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  let appSettings: HamsterAppSettings

  lazy var headerView: UIView = {
    let stackView = UIStackView(frame: .zero)
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .equalSpacing
    stackView.spacing = 8

    let titleLabel = UILabel(frame: .zero)
    titleLabel.text = "自定义数字九宫格左侧滑动符号栏"
    titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
    stackView.addArrangedSubview(titleLabel)

    let containerView = UIView()
    containerView.frame = CGRect(x: 0, y: 0, width: 300, height: 30)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(stackView)
    NSLayoutConstraint.activate([
      stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
      stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
      stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
    ])

    return containerView
  }()
}

// MARK: custom methods

extension NumberNineGridSymbolListTableView {
  @objc func addTableRow() {
    if isEditing {
      return
    }
    // 更新database
    let lastSymbol = appSettings.numberNineGridSymbols.last ?? ""

    // 只保留一个空行
    if lastSymbol.isEmpty, !appSettings.numberNineGridSymbols.isEmpty {
      let indexPath = IndexPath(row: appSettings.numberNineGridSymbols.count - 1, section: 0)
      if let cell = cellForRow(at: indexPath), let cell = cell as? NumberNineGridOfSymbolTableViewCell {
        selectRow(at: indexPath, animated: true, scrollPosition: .top)
        cell.textField.becomeFirstResponder()
      }
      return
    }

    // 先更新数据源, 在添加行
    appSettings.numberNineGridSymbols.append("")
    let indexPath = IndexPath(row: appSettings.numberNineGridSymbols.count - 1, section: 0)
    insertRows(at: [indexPath], with: .automatic)
    if let cell = cellForRow(at: indexPath), let cell = cell as? NumberNineGridOfSymbolTableViewCell {
      selectRow(at: indexPath, animated: true, scrollPosition: .top)
      cell.textField.becomeFirstResponder()
    }
  }
}

// MARK: implementation UITableViewDelegate, UITableViewDataSource

extension NumberNineGridSymbolListTableView {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return appSettings.numberNineGridSymbols.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: NumberNineGridOfSymbolTableViewCell.identifier, for: indexPath)
    let symbol = appSettings.numberNineGridSymbols[indexPath.row]
    if let cell = cell as? NumberNineGridOfSymbolTableViewCell {
      cell.textField.text = symbol
      cell.tableView = self
      cell.indexPath = indexPath
    }
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "点击行可编辑"
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footView = TableFooterView(footer: "点我添加新符号")
    footView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTableRow)))
    return footView
  }

  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    true
  }

  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    appSettings.numberNineGridSymbols.swapAt(sourceIndexPath.row, destinationIndexPath.row)
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    if let cell = tableView.cellForRow(at: indexPath), let cell = cell as? NumberNineGridOfSymbolTableViewCell {
      cell.textField.resignFirstResponder()
    }
    return true
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      appSettings.numberNineGridSymbols.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
}

class NumberNineGridOfSymbolTableViewCell: UITableViewCell, UITextFieldDelegate {
  static let identifier = "NumberNineGridOfSymbolTableViewCell"

  lazy var textField: UITextField = {
    let textField = UITextField()
    textField.text = ""
    textField.clearButtonMode = .whileEditing
    textField.font = UIFont.preferredFont(forTextStyle: .body)
    textField.clipsToBounds = true
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.delegate = self
    return textField
  }()

  unowned var tableView: NumberNineGridSymbolListTableView?
  var indexPath: IndexPath?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.tableView = nil
    self.indexPath = nil
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(textField)
    NSLayoutConstraint.activate([
      textField.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
      textField.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
      textField.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
      textField.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func textFieldDidEndEditing(_ textField: UITextField) {
    guard let indexPath = indexPath else { return }
    guard let tableView = tableView else { return }
    guard let text = textField.text else { return }

    if text.isEmpty {
      tableView.appSettings.numberNineGridSymbols.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
      return
    }

    tableView.appSettings.numberNineGridSymbols[indexPath.row] = text
    self.textField.text = text
  }

  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    guard let tableView = tableView else { return false }
    return !tableView.isEditing
  }
}
