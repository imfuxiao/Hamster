//
//  NumberNineGridSymbolListTableView.swift
//  Hamster
//
//  Created by morse on 2023/6/16.
//

import Combine
import HamsterUIKit
import UIKit

/// 符号编辑View
public class SymbolEditorView: NibLessView {
  // MARK: properties

  private var subscriptions = Set<AnyCancellable>()

//  private let keyboardSettingsViewModel: KeyboardSettingsViewModel
  private let headerTitle: String
  private var symbols: [String] {
    didSet {
      symbolsDidSet(symbols)
    }
  }

  private let symbolsDidSet: ([String]) -> Void
  private var symbolTableIsEditingPublished: AnyPublisher<Bool, Never>

  lazy var headerView: UIView = {
    let stackView = UIStackView(frame: .zero)
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .equalSpacing
    stackView.spacing = 8

    let titleLabel = UILabel(frame: .zero)
    titleLabel.text = headerTitle
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

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
    tableView.allowsSelection = false
    tableView.tableHeaderView = headerView
    return tableView
  }()

  // MARK: methods

  init(
    frame: CGRect = .zero,
    headerTitle: String,
    symbols: [String],
    symbolsDidSet: @escaping ([String]) -> Void,
    symbolTableIsEditingPublished: AnyPublisher<Bool, Never>
  ) {
    self.headerTitle = headerTitle
    self.symbols = symbols
    self.symbolsDidSet = symbolsDidSet
    self.symbolTableIsEditingPublished = symbolTableIsEditingPublished

    super.init(frame: frame)
  }

  override public func constructViewHierarchy() {
    addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
  }

  override public func activateViewConstraints() {
    tableView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: topAnchor),
      tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }

  override public func didMoveToWindow() {
    super.didMoveToWindow()

    constructViewHierarchy()
    activateViewConstraints()

    symbolTableIsEditingPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        tableView.setEditing($0, animated: true)
      }
      .store(in: &subscriptions)
  }
}

// MARK: custom methods

extension SymbolEditorView {
  @objc func addTableRow() {
    if tableView.isEditing {
      return
    }
    // 更新database
    let lastSymbol = symbols.last ?? ""

    // 只保留一个空行
    if lastSymbol.isEmpty, !symbols.isEmpty {
      let indexPath = IndexPath(row: symbols.count - 1, section: 0)
      if let cell = tableView.cellForRow(at: indexPath), let _ = cell as? TextFieldTableViewCell {
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
      }
      return
    }

    // 先更新数据源, 在添加行
    symbols.append("")
    let indexPath = IndexPath(row: symbols.count - 1, section: 0)
    tableView.insertRows(at: [indexPath], with: .automatic)
    if let cell = tableView.cellForRow(at: indexPath), let cell = cell as? TextFieldTableViewCell {
      cell.settingItem = SettingItemModel(
        text: "",
        textHandled: { [unowned self] in
          symbols[indexPath.row] = $0
        },
        shouldBeginEditing: {
          $0.becomeFirstResponder()
        }
      )
      tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
    }
  }
}

extension SymbolEditorView: UITableViewDataSource {
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return symbols.count
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldTableViewCell.identifier, for: indexPath)
    let symbol = symbols[indexPath.row]
    if let cell = cell as? TextFieldTableViewCell {
      cell.settingItem = SettingItemModel(
        text: symbol,
        textHandled: { [unowned self] in
          symbols[indexPath.row] = $0
        },
        shouldBeginEditing: {
          $0.becomeFirstResponder()
        }
      )
    }
    return cell
  }

  public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "点击行可编辑"
  }

  public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footView = TableFooterView(footer: "点我添加新符号")
    footView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addTableRow)))
    return footView
  }
}

extension SymbolEditorView: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    true
  }

  public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    symbols.swapAt(sourceIndexPath.row, destinationIndexPath.row)
  }

  public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//    if let cell = tableView.cellForRow(at: indexPath), let cell = cell as? TextFieldTableViewCell {
//      cell.textField.resignFirstResponder()
//    }
    return true
  }

  public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      symbols.remove(at: indexPath.row)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
}
