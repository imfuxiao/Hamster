//
//  UploadInputSchemaRootView.swift
//
//
//  Created by morse on 2023/7/11.
//

import HamsterKit
import HamsterUIKit
import ProgressHUD
import UIKit

class UploadInputSchemaRootView: NibLessView {
  // MARK: properties

  private let viewModel: UploadInputSchemaViewModel

  private let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    return tableView
  }()

  // MARK: methods

  init(frame: CGRect = .zero, uploadInputSchemaViewModel: UploadInputSchemaViewModel) {
    self.viewModel = uploadInputSchemaViewModel

    super.init(frame: frame)
  }

  override func constructViewHierarchy() {
    addSubview(tableView)
    tableView.dataSource = self
    tableView.delegate = self
  }

  override func activateViewConstraints() {
    tableView.fillSuperview()
  }

  func localIPCell() -> UITableViewCell {
    var valueCellConfig = UIListContentConfiguration.cell()
    if let ip = UIDevice.current.localIP() {
      valueCellConfig.text = "http://\(ip)"
    } else {
      valueCellConfig.text = "无法获取IP地址"
    }

    let cell = UITableViewCell()
    cell.contentConfiguration = valueCellConfig
    return cell
  }

  func buttonCell() -> UITableViewCell {
    let cell = UITableViewCell()

    let button = UIButton(type: .system)
    button.setTitle(viewModel.fileServerRunning ? "停止服务" : "启动服务", for: .normal)
//    button.addTarget(
//      self,
//      action: viewModel.fileServerRunning ? #selector(viewModel.stopFileServer) : #selector(viewModel.startFileServer),
//      for: .touchUpInside)

    button.translatesAutoresizingMaskIntoConstraints = false
    cell.addSubview(button)
    NSLayoutConstraint.activate([
      button.leadingAnchor.constraint(equalTo: cell.leadingAnchor),
      button.trailingAnchor.constraint(equalTo: cell.trailingAnchor),
      button.topAnchor.constraint(equalTo: cell.layoutMarginsGuide.topAnchor),
      button.bottomAnchor.constraint(equalTo: cell.layoutMarginsGuide.bottomAnchor),
    ])

    return cell
  }
}

extension UploadInputSchemaRootView {
  override func didMoveToWindow() {
    super.didMoveToWindow()

    constructViewHierarchy()
    activateViewConstraints()

    if let indexPath = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
}

extension UploadInputSchemaRootView: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      return localIPCell()
    }
    return buttonCell()
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if section == 0 {
      return "局域网访问地址(点击复制)"
    }
    return nil
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    if section == 0 {
      return TableFooterView(footer: Self.remark)
    }

    return nil
  }
}

extension UploadInputSchemaRootView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 0, indexPath.row == 0 {
      if let ip = UIDevice.current.localIP() {
        UIPasteboard.general.string = "http://\(ip)"
        ProgressHUD.showSuccess("复制成功", delay: 1.5)
      }
    } else if indexPath.section == 1, indexPath.row == 0 {
      if viewModel.fileServerRunning {
        viewModel.stopFileServer()
      } else {
        viewModel.startFileServer()
      }
      tableView.reloadData()
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension UploadInputSchemaRootView {
  private static let remark = """
  1. 请保持手机与浏览器处于同一局域网；
  2. 请将个人方案上传至“Rime”文件夹内，可先删除原“Rime”文件夹内文件在上传;
  3. 上传完毕后，需要点击"重新部署"，否则方案不会生效；
  4. 浏览器内支持全选/拖拽等动作。
  """
}
