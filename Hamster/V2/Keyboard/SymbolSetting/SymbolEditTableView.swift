//
//  SymbolEditTableView.swift
//  Hamster
//
//  Created by morse on 2023/6/17.
//

import UIKit

class SymbolEditTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
  init(title: String? = nil, header: String? = nil, footer: String? = nil, symbols: [String], saveSymbols: @escaping ([String]) -> Void) {
    self.symbols = symbols
    self.saveSymbols = saveSymbols
    self.title = title
    self.header = header
    self.footer = footer

    super.init(frame: .zero, style: .insetGrouped)

    register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
    self.delegate = self
    self.dataSource = self
    self.allowsSelection = false
    if self.title != nil {
      self.tableHeaderView = headerView
    }
    self.translatesAutoresizingMaskIntoConstraints = false
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private let title: String?
  private let header: String?
  private let footer: String?
  private var symbols: [String]
  private let saveSymbols: ([String]) -> Void

  lazy var headerView: UIView = {
    let stackView = UIStackView(frame: .zero)
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .equalSpacing
    stackView.spacing = 8

    let titleLabel = UILabel(frame: .zero)
    titleLabel.text = title
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

extension SymbolEditTableView {
  @objc func addTableRow() {
    if isEditing {
      return
    }
    // 更新database
    let lastSymbol = symbols.last ?? ""

    // 只保留一个空行
    if lastSymbol.isEmpty, !symbols.isEmpty {
      let indexPath = IndexPath(row: symbols.count - 1, section: 0)
      if let cell = cellForRow(at: indexPath), let cell = cell as? TextFieldTableViewCell {
        selectRow(at: indexPath, animated: true, scrollPosition: .top)
        cell.textField.becomeFirstResponder()
      }
      return
    }

    // 先更新数据源, 在添加行
    symbols.append("")
    let indexPath = IndexPath(row: symbols.count - 1, section: 0)
    insertRows(at: [indexPath], with: .automatic)
    if let cell = cellForRow(at: indexPath), let cell = cell as? TextFieldTableViewCell {
      selectRow(at: indexPath, animated: true, scrollPosition: .top)
      cell.textField.becomeFirstResponder()
    }
  }
}

// MARK: implementation UITableViewDelegate, UITableViewDataSource

extension SymbolEditTableView {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return symbols.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let symbol = symbols[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier, for: indexPath)
    guard let cell = cell as? TextFieldTableViewCell else { return cell }
    cell.textField.text = symbol
    cell.textHandled = { [unowned self] in
      if $0.isEmpty {
        symbols.remove(at: indexPath.row)
        self.deleteRows(at: [indexPath], with: .automatic)
        return
      }
      symbols[indexPath.row] = $0
      saveSymbols(symbols)
    }
    cell.shouldBeginEditing = { [unowned self] _ in
      !self.isEditing
    }
    return cell
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return header ?? "点击行可编辑"
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footView = TableFooterView(footer: footer ?? "点我添加新符号")
    footView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTableRow)))
    return footView
  }

  func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    true
  }

  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    symbols.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    saveSymbols(symbols)
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    if let cell = tableView.cellForRow(at: indexPath), let cell = cell as? TextFieldTableViewCell {
      cell.textField.resignFirstResponder()
    }
    return true
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      symbols.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
      saveSymbols(symbols)
    }
  }
}
