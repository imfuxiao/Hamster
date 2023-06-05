//
//  KeyboardLayoutViewController.swift
//
//
//  Created by morse on 2023/9/5.
//

import Combine
import HamsterUIKit
import UIKit

/// 键盘布局
class KeyboardLayoutViewController: NibLessViewController {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  private var subscriptions = Set<AnyCancellable>()

  private lazy var rootView: KeyboardLayoutRootView = {
    let view = KeyboardLayoutRootView(keyboardSettingsViewModel: keyboardSettingsViewModel)
    return view
  }()

  private lazy var layoutSettingsViewController: LayoutSettingsViewController = {
    let vc = LayoutSettingsViewController(keyboardSettingsViewModel: keyboardSettingsViewModel)
    return vc
  }()

  private lazy var keySwipeSettingsViewController: KeySwipeSettingsViewController = {
    let vc = KeySwipeSettingsViewController(keyboardSettingsViewModel: keyboardSettingsViewModel)
    return vc
  }()

  private lazy var documentPickerViewController: UIDocumentPickerViewController = {
    let vc = UIDocumentPickerViewController(forOpeningContentTypes: [.yaml])
    if let iCloudURL = FileManager.default.url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents") {
      vc.directoryURL = iCloudURL
    } else {
      vc.directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    vc.delegate = self
    return vc
  }()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init()
  }

  override func loadView() {
    title = "键盘布局"
    view = rootView

    // 右侧导入按钮
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: keyboardSettingsViewModel, action: #selector(keyboardSettingsViewModel.importCustomizeKeyboardLayout))

    keyboardSettingsViewModel.useKeyboardTypePublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        self.navigationController?.pushViewController(layoutSettingsViewController, animated: true)
      }
      .store(in: &subscriptions)

    keyboardSettingsViewModel.keySwipeSettingsActionPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        keySwipeSettingsViewController.updateWithKey($0.0, for: $0.1)
        self.navigationController?.pushViewController(keySwipeSettingsViewController, animated: true)
      }
      .store(in: &subscriptions)

    keyboardSettingsViewModel.openDocumentPickerPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] in
        guard $0 == true else { return }
        presentDocumentPicker()
      }
      .store(in: &subscriptions)
  }

  func presentDocumentPicker() {
    present(documentPickerViewController, animated: true)
  }
}

extension KeyboardLayoutViewController: UIDocumentPickerDelegate {
  /// 自定义键盘导入
  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard !urls.isEmpty else { return }
    Task {
      await self.keyboardSettingsViewModel.importCustomizeKeyboardLayout(fileURL: urls[0])
      self.view.setNeedsLayout()
    }
  }
}
