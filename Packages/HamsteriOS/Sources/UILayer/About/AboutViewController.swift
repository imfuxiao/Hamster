//
//  AboutViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import Combine
import HamsterUIKit
import ProgressHUD
import UIKit

protocol AboutViewModelFactory {
  func makeAboutViewModel() -> AboutViewModel
}

protocol OpenSourceViewControllerFactory {
  func makeOpenSourceViewController() -> OpenSourceViewController
}

class AboutViewController: NibLessViewController, UIDocumentPickerDelegate {
  private let aboutViewModel: AboutViewModel
  private let openSourceViewController: OpenSourceViewController
  private var subscriptions = Set<AnyCancellable>()

  init(aboutViewModelFactory: AboutViewModelFactory, openSourceViewControllerFactory: OpenSourceViewControllerFactory) {
    self.aboutViewModel = aboutViewModelFactory.makeAboutViewModel()
    self.openSourceViewController = openSourceViewControllerFactory.makeOpenSourceViewController()
    super.init()

    combine()
  }

  override func loadView() {
    title = "关于"
    view = AboutRootView(aboutViewModel: aboutViewModel)
  }

  func combine() {
    aboutViewModel.$displayOpenSourceView
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard $0 else { return }
        presentOpenSourceView()
      }
      .store(in: &subscriptions)

    // 重置 UI 设置 confirm 对话框
    aboutViewModel.restUISettingsPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] callback in
        self.alertConfirm(alertTitle: "重置 UI 设置", message: "确认重置 UI 交互生成的设置吗？", confirmTitle: "确定", confirmCallback: {
          callback()
          ProgressHUD.success("重置成功", interaction: false, delay: 1.5)
        })
      }
      .store(in: &subscriptions)

    // 导出配置文件
    aboutViewModel.exportConfigurationPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] exportURL in
        let pickerVC = UIDocumentPickerViewController(forExporting: [exportURL])
        pickerVC.modalPresentationStyle = .formSheet
        pickerVC.shouldShowFileExtensions = true
        pickerVC.delegate = self
        present(pickerVC, animated: true)
      }
      .store(in: &subscriptions)
  }

  func presentOpenSourceView() {
    navigationController?.pushViewController(openSourceViewController, animated: true)
  }
}
