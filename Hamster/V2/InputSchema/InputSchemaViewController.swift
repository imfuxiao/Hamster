//
//  InputSchemaViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/12.
//

import Combine
import ProgressHUD
import UIKit

class InputSchemaViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIDocumentPickerDelegate {
  init(appSettings: HamsterAppSettings, rimeContext: RimeContext) {
    self.appSettings = appSettings
    self.rimeContext = rimeContext
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private static let cellIdentifier = "InputSchemaTableCell"

  private let appSettings: HamsterAppSettings
  private let rimeContext: RimeContext

  lazy var inputSchemaViewModel = InputSchemaViewModel(appSettings: appSettings, rimeContext: rimeContext)

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: InputSchemaViewController.cellIdentifier)
    return tableView
  }()
}

// MARK: override UIViewController

extension InputSchemaViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "输入方案设置"

    let tableView = tableView
    tableView.delegate = self
    tableView.dataSource = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])

    // 添加导入按钮
    let importItem = UIBarButtonItem(systemItem: .add)
    importItem.action = #selector(openImportDocumentPick)
    importItem.target = self
    navigationItem.rightBarButtonItem = importItem
  }
}

// MARK: implementation UIDocumentPickerDelegate

extension InputSchemaViewController {
  @objc func openImportDocumentPick(item: UIBarButtonItem) {
    // Create a document picker for directories.
    let documentPicker =
      UIDocumentPickerViewController(forOpeningContentTypes: [.zip])
    documentPicker.delegate = self

    // Present the document picker.
    present(documentPicker, animated: true, completion: nil)
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard !urls.isEmpty else {
      return
    }
    DispatchQueue.global().async { [unowned self] in
      self.inputSchemaViewModel.importZipFile(fileURL: urls[0], tableView: self.tableView)
    }
  }
}

// MARK: implementation UITableViewDelegate, UITableViewDataSource

extension InputSchemaViewController {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    appSettings.rimeTotalSchemas.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = self.tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath)
    let schema = appSettings.rimeTotalSchemas[indexPath.row]

    var config = UIListContentConfiguration.cell()
    config.text = schema.schemaName
    cell.contentConfiguration = config
    cell.accessoryType = appSettings.rimeUserSelectSchema.contains(schema) ? .checkmark : .none

    return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    guard let cell = self.tableView.cellForRow(at: indexPath) else { return }
    let schema = appSettings.rimeTotalSchemas[indexPath.row]

    let checkmark = cell.accessoryType == .checkmark
    cell.accessoryType = checkmark ? .none : .checkmark
    if cell.accessoryType == .none {
      if appSettings.rimeUserSelectSchema.count == 1 {
        cell.accessoryType = .checkmark
        ProgressHUD.show("至少保留一个输入方案", icon: .exclamation, delay: 1.5)
        return
      }
      appSettings.rimeUserSelectSchema.removeAll(where: { $0 == schema })
    } else {
      appSettings.rimeUserSelectSchema.append(schema)
    }
  }
}
