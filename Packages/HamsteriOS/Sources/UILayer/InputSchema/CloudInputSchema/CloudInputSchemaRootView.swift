//
//  CloudInputSchemaRootView.swift
//
//
//  Created by morse on 2023/11/11.
//

import Combine
import HamsterUIKit
import ProgressHUD
import UIKit

/// 云端输入方案列表
class CloudInputSchemaRootView: NibLessView {
  private let inputSchemaViewModel: InputSchemaViewModel
  private var subscriptions = Set<AnyCancellable>()

  // 查询
  private lazy var searchBar: UISearchBar = {
    let view = UISearchBar(frame: .zero)
    view.searchBarStyle = .minimal
    view.translatesAutoresizingMaskIntoConstraints = false
    view.delegate = self
    return view
  }()

  private lazy var refreshControl: UIRefreshControl = {
    let control = UIRefreshControl(frame: .zero)
    control.addTarget(self, action: #selector(refreshInputSchema(_:)), for: .valueChanged)
    return control
  }()

  private lazy var tableView: UITableView = {
    let view = UITableView(frame: .zero, style: .insetGrouped)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.register(CloudInputSchemaCell.self, forCellReuseIdentifier: CloudInputSchemaCell.identifier)
    view.delegate = self
    view.dataSource = self
    view.addSubview(refreshControl)
    return view
  }()

  public lazy var remarkLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = InputSchemaViewModel.copyright
    label.textAlignment = .justified
    label.numberOfLines = -1
    label.lineBreakMode = .byTruncatingTail
    label.textColor = UIColor.secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: .caption1)
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  init(inputSchemaViewModel: InputSchemaViewModel) {
    self.inputSchemaViewModel = inputSchemaViewModel
    super.init(frame: .zero)

    constructViewHierarchy()
    activateViewConstraints()
    setupAppearance()
    combine()
  }

  override func constructViewHierarchy() {
    addSubview(tableView)
    addSubview(searchBar)
    addSubview(remarkLabel)
  }

  override func activateViewConstraints() {
    NSLayoutConstraint.activate([
      searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      searchBar.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2),
      trailingAnchor.constraint(equalToSystemSpacingAfter: searchBar.trailingAnchor, multiplier: 2),

      tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      trailingAnchor.constraint(equalTo: tableView.trailingAnchor),

      remarkLabel.topAnchor.constraint(equalToSystemSpacingBelow: tableView.bottomAnchor, multiplier: 1),
      remarkLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1.5),
      trailingAnchor.constraint(equalToSystemSpacingAfter: remarkLabel.trailingAnchor, multiplier: 1.5),
      remarkLabel.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
    ])
  }

  override func setupAppearance() {
    backgroundColor = .secondarySystemBackground
  }

  func combine() {
    inputSchemaViewModel.inputSchemasReloadPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] result in
        if case .failure(let error) = result {
          ProgressHUD.error(error, interaction: false, delay: 5)
          return
        }
        tableView.reloadData()
        ProgressHUD.dismiss()
        refreshControl.endRefreshing()
      }
      .store(in: &subscriptions)

    inputSchemaViewModel.inputSchemaSearchTextSubject
      // 优化触发查询的逻辑，快速输入1，2，需要合并2次输入为1次对 Cloudkit 的检索
      .debounce(for: 1, scheduler: RunLoop.main)
      .sink { [unowned self] searchText in
        inputSchemaViewModel.initialLoadCloudInputSchema(searchText)
      }
      .store(in: &subscriptions)
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    if let _ = window {
      Task {
        if self.inputSchemaViewModel.inputSchemas.isEmpty {
          self.inputSchemaViewModel.initialLoadCloudInputSchema(inputSchemaViewModel.searchText)
        }
      }
    }
  }

  @objc func refreshInputSchema(_ sender: Any) {
    self.inputSchemaViewModel.initialLoadCloudInputSchema(inputSchemaViewModel.searchText)
  }
}

// MARK: - UISearchBarDelegate

extension CloudInputSchemaRootView: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    guard inputSchemaViewModel.searchText != searchText else { return }
    inputSchemaViewModel.searchText = searchText
    inputSchemaViewModel.inputSchemaSearchTextSubject.send(searchText)
  }
}

extension CloudInputSchemaRootView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    let inputSchemaInfo = inputSchemaViewModel.inputSchemas[indexPath.row]
    inputSchemaViewModel.inputSchemaDetailsSubject.send(inputSchemaInfo)
  }
}

extension CloudInputSchemaRootView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    inputSchemaViewModel.inputSchemas.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let info = inputSchemaViewModel.inputSchemas[indexPath.row]
    let cell = tableView.dequeueReusableCell(withIdentifier: CloudInputSchemaCell.identifier, for: indexPath)
    if let cell = cell as? CloudInputSchemaCell {
      cell.updateWithInputSchemaInfo(info)
    }

    // 倒数第二个 cell 时，通过游标加载数据
    if indexPath.row == self.inputSchemaViewModel.inputSchemas.count - 1 {
      self.inputSchemaViewModel.loadCloudInputSchemaByCursor()
    }

    return cell
  }
}
