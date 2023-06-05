//
//  AppleCloudViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//
import ProgressHUD
import UIKit

class AppleCloudViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  init(parentController: SettingsViewController, appSettings: HamsterAppSettings) {
    self.parentController = parentController
    self.appSettings = appSettings
    super.init(nibName: nil, bundle: nil)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  unowned let parentController: SettingsViewController
  let appSettings: HamsterAppSettings

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.allowsSelection = false
    tableView.delegate = self
    tableView.dataSource = self
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
}

// MARK: override UIViewController

extension AppleCloudViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    title = "iCloud同步"

    let tableView = tableView
    view.addSubview(tableView)

    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.topAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    parentController.tableView.reloadData()
  }
}

// MARK: implementation UITableViewDelegate, UITableViewDataSource

extension AppleCloudViewController {
  func numberOfSections(in tableView: UITableView) -> Int {
    3
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch (indexPath.section, indexPath.row) {
    case (0, 0):
      return ToggleTableViewCell(
        text: "启用iCloud",
        toggleValue: appSettings.enableAppleCloud,
        toggleHandled: { [unowned self] in self.appSettings.enableAppleCloud = $0 })
    case (1, 0):
      return ButtonTableViewCell(text: "拷贝应用文件至iCloud", buttonAction: { [unowned self] in
        ProgressHUD.show("拷贝本地文件至iCloud中……", interaction: false)
        DispatchQueue.global().async {
          do {
            let regexList = self.appSettings.copyToCloudFilterRegex.split(separator: ",").map { String($0) }
            try RimeContext.copySandboxSharedSupportDirectoryToAppleCloud(regexList)
            try RimeContext.copySandboxUserDataDirectoryToAppleCloud(regexList)
          } catch {
            Logger.shared.log.error("copy app file to iCloud error: \(error.localizedDescription)")
            ProgressHUD.showError("拷贝失败")
          }
          ProgressHUD.showSuccess("拷贝成功", delay: 1.5)
        }
      })
    case (2, 0):
      return TextFieldTableViewCell(iconName: "square.and.pencil", placeholder: "正则过滤", text: appSettings.copyToCloudFilterRegex, textHandled: { [unowned self] in
        self.appSettings.copyToCloudFilterRegex = $0
      })
    default:
      return UITableViewCell(frame: .zero)
    }
  }

  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    switch section {
    case 0:
      return TableFooterView(footer: Self.enableAppleCloudRemark)
    case 1:
      return TableFooterView(footer: Self.copyRemark)
    case 2:
      let footerView = TableFooterView(footer: Self.regexRemark)
      let gesture = UITapGestureRecognizer(target: self, action: #selector(copyRegex))
      gesture.cancelsTouchesInView = false
      footerView.addGestureRecognizer(gesture)
      return footerView
    default:
      break
    }
    return nil
  }

  @objc func copyRegex() {
    UIPasteboard.general.string = Self.clipboardOnCopyToCloudFilterRegexRemark
    ProgressHUD.showSuccess("复制成功", delay: 1.5)
  }
}

extension AppleCloudViewController {
  static let enableAppleCloudRemark = """
  1. 启用后，“重新部署”会复制iCloud中仓输入法`RIME`文件夹下全部文件；
  2. 复制时，差异文件会被覆盖；
  """

  static let copyRemark = """
  默认为全量拷贝，如需过滤拷贝内容，需要结合过滤表达式一起使用；
  """

  static let regexRemark = """
  1. 过滤表达式在“重新部署”功能中也会生效；
  2. 多个正则表达式使用英文逗号分隔；
  3. 常用示例（点击可复制全部表达式，请按需修改）:
     * 过滤userdb目录 ^.*[.]userdb.*$
     * 过滤build目录 ^.*build.*$
     * 过滤SharedSupport目录 ^.*SharedSupport.*$
     * 过滤编译后的词库文件 ^.*[.]bin$
  """

  static let clipboardOnCopyToCloudFilterRegexRemark = "^.*[.]userdb.*$,^.*build.*$,^.*SharedSupport.*$,^.*[.]bin$"
}
