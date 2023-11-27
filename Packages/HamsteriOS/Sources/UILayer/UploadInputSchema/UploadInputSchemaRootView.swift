//
//  UploadInputSchemaRootView.swift
//
//
//  Created by morse on 2023/7/11.
//

import Combine
import HamsterKit
import HamsterUIKit
import ProgressHUD
import UIKit

class UploadInputSchemaRootView: NibLessView {
  // MARK: properties

  private let viewModel: UploadInputSchemaViewModel
  private var subscriptions = Set<AnyCancellable>()

  private lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.dataSource = self
    tableView.delegate = self
    return tableView
  }()

  private lazy var buttonView: UIButton = {
    let button = UIButton(type: .system)
    button.addTarget(
      viewModel,
      action: #selector(viewModel.managerfileServer),
      for: .touchUpInside
    )
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  // MARK: methods

  init(frame: CGRect = .zero, uploadInputSchemaViewModel: UploadInputSchemaViewModel) {
    self.viewModel = uploadInputSchemaViewModel

    super.init(frame: frame)

    constructViewHierarchy()
    activateViewConstraints()

    self.viewModel.$fileServerRunning
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        buttonView.setTitle($0 ? "停止服务" : "启动服务", for: .normal)
      }
      .store(in: &subscriptions)
  }

  override func constructViewHierarchy() {
    addSubview(tableView)
  }

  override func activateViewConstraints() {
    tableView.fillSuperview()
  }

  func localIPCell() -> UITableViewCell {
    var valueCellConfig = UIListContentConfiguration.cell()
    if let ip = UIDevice.current.getAddress() {
      valueCellConfig.text = "http://\(ip)"
    } else {
      valueCellConfig.text = "无法获取 IP 地址，请在系统设置 - WiFi 中查看地址。"
    }

    let cell = UITableViewCell()
    cell.contentConfiguration = valueCellConfig
    return cell
  }

  func buttonCell() -> UITableViewCell {
    let cell = UITableViewCell()
    cell.contentView.addSubview(buttonView)
    buttonView.fillSuperviewOnMarginsGuide()
    return cell
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
      if let ip = UIDevice.current.getAddress() {
        UIPasteboard.general.string = "http://\(ip)"
        ProgressHUD.success("复制成功", delay: 1.5)
      }
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension UploadInputSchemaRootView {
  private static let remark = """
  1. 连接到相同的 Wi-Fi，注意：开启服务请不要离开此页面或锁定手机；
  2. 请将个人方案上传至“Rime”文件夹内，可先删除原“Rime”文件夹内文件在上传;
  3. 上传完毕后，需要“重新部署”，否则方案不会生效；
  4. 浏览器内支持全选/拖拽上传等动作。
  """
}
