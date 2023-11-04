//
//  NumberNineGridSymbolListTableView.swift
//  Hamster
//
//  Created by morse on 2023/6/16.
//

import Combine
import HamsterUIKit
import ProgressHUD
import UIKit

/// 符号编辑View
public class SymbolEditorView: NibLessView {
  // MARK: properties

  private var subscriptions = Set<AnyCancellable>()

  private let headerTitle: String
  private let getSymbols: () -> [String]
  private var symbols: [String]

  private let symbolsDidSet: ([String]) -> Void
  private var symbolTableIsEditingPublished: AnyPublisher<Bool, Never>
  private var reloadDataPublished: AnyPublisher<Bool, Never>

  lazy var headerView: UIView = {
    let titleLabel = UILabel(frame: .zero)
    titleLabel.text = headerTitle
    titleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)

    let stackView = UIStackView(arrangedSubviews: [titleLabel])
    stackView.axis = .vertical
    stackView.alignment = .center
    stackView.distribution = .equalSpacing
    stackView.spacing = 8

    let containerView = UIView()
    containerView.frame = CGRect(x: 0, y: 0, width: 300, height: 30)
    containerView.addSubview(stackView)
    stackView.fillSuperview()

    return containerView
  }()

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(TextFieldTableViewCell.self, forCellReuseIdentifier: TextFieldTableViewCell.identifier)
    if !headerTitle.isEmpty {
      tableView.tableHeaderView = headerView
    }
    tableView.allowsSelection = false
    tableView.delegate = self
    tableView.dataSource = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()

  // 重置符号按钮
  private var needRestButton: Bool
  private var restButtonAction: (() throws -> Void)?

  lazy var restButton: UIButton = {
    let button = UIButton(type: .roundedRect)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("恢复默认值", for: .normal)
    button.setTitleColor(.systemRed, for: .normal)
    button.addTarget(self, action: #selector(restSymbols), for: .touchUpInside)
    return button
  }()

  // MARK: methods

  /**
   * 符号列表编辑组件
   */
  init(
    frame: CGRect = .zero,
    headerTitle: String = "",
    getSymbols: @escaping () -> [String],
    symbolsDidSet: @escaping ([String]) -> Void,
    symbolTableIsEditingPublished: AnyPublisher<Bool, Never>,
    reloadDataPublished: AnyPublisher<Bool, Never>,
    needRestButton: Bool = false,
    restButtonAction: (() throws -> Void)? = nil
  ) {
    self.headerTitle = headerTitle
    self.getSymbols = getSymbols
    self.symbols = getSymbols()
    self.symbolsDidSet = symbolsDidSet
    self.symbolTableIsEditingPublished = symbolTableIsEditingPublished
    self.reloadDataPublished = reloadDataPublished
    self.needRestButton = needRestButton
    self.restButtonAction = restButtonAction

    super.init(frame: frame)

    setupView()

    self.symbolTableIsEditingPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        tableView.setEditing($0, animated: true)
        if tableView.isEditing {
          tableView.visibleCells.forEach { cell in
            guard let cell = cell as? TextFieldTableViewCell else { return }
            cell.textField.resignFirstResponder()
          }
        }
      }
      .store(in: &subscriptions)

    self.reloadDataPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        self.symbols = getSymbols()
        self.tableView.reloadData()
      }
      .store(in: &subscriptions)
  }

  func setupView() {
    backgroundColor = .secondarySystemBackground

    addSubview(tableView)
    if !needRestButton {
      tableView.fillSuperview()
      return
    }

    addSubview(restButton)
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: topAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),

      restButton.topAnchor.constraint(equalToSystemSpacingBelow: tableView.bottomAnchor, multiplier: 1.0),
      safeAreaLayoutGuide.bottomAnchor.constraint(equalToSystemSpacingBelow: restButton.bottomAnchor, multiplier: 1.0),
      restButton.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1.0),
      trailingAnchor.constraint(equalToSystemSpacingAfter: restButton.trailingAnchor, multiplier: 1.0)
    ])
  }

  override public func didMoveToWindow() {
    super.didMoveToWindow()

    if let _ = window {
      symbols = getSymbols()
      tableView.reloadData()
    }
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
      if let cell = tableView.cellForRow(at: indexPath), let textCell = cell as? TextFieldTableViewCell {
        ProgressHUD.added("我在这", interaction: false, delay: 1)
        textCell.textField.becomeFirstResponder()
      }
      return
    }

    // 注意：先更新数据源, 在添加行
    symbols.append("")

    let indexPath = IndexPath(row: symbols.count - 1, section: 0)
    tableView.insertRows(at: [indexPath], with: .automatic)
    if let cell = tableView.cellForRow(at: indexPath), let cell = cell as? TextFieldTableViewCell {
      cell.updateWithSettingItem(SettingItemModel(
        textHandled: { [weak self] in
          guard let self = self else { return }
          if $0.isEmpty {
            self.symbols.remove(at: indexPath.row)
          } else {
            self.symbols[indexPath.row] = $0
          }
          self.symbolsDidSet(self.symbols)
          self.tableView.reloadData()
        }
      ))
      cell.textField.becomeFirstResponder()
    }
  }

  @objc func restSymbols() {
    do {
      try restButtonAction?()
      ProgressHUD.success("重置成功", interaction: false, delay: 1.5)
    } catch {
      ProgressHUD.failed("重置失败", interaction: false, delay: 1.5)
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
    guard let cell = cell as? TextFieldTableViewCell else { return cell }
    cell.updateWithSettingItem(SettingItemModel(
      textValue: { symbol },
      textHandled: { [weak self] in
        guard let self = self else { return }
        if $0.isEmpty {
          self.symbols.remove(at: indexPath.row)
        } else {
          self.symbols[indexPath.row] = $0
        }
        self.symbolsDidSet(self.symbols)
        self.tableView.reloadData()
      }
    ))
    return cell
  }

  public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "点击行可编辑/划动可删除"
  }

  public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footView = TableFooterView(footer: "点我添加新符号(回车键保存)。")
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
    self.symbolsDidSet(self.symbols)
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
      self.symbolsDidSet(self.symbols)
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
}
