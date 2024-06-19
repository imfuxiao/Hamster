//
//  BackupViewController.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//

import Combine
import HamsterUIKit
import UIKit

class BackupViewController: NibLessViewController {
  // MARK: properties

  private let backupViewModel: BackupViewModel
  private var subscriptions = Set<AnyCancellable>()

  // MARK: methods

  init(backupViewModel: BackupViewModel) {
    self.backupViewModel = backupViewModel
    super.init()

    backupViewModel.$backupSwipeAction
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] action in
        guard let action = action else { return }
        swipeActionHandled(action: action)
      }.store(in: &subscriptions)
  }

  override func loadView() {
    title = L10n.Backup.title2
    view = BackupRootView(backupViewModel: backupViewModel)
  }

  func swipeActionHandled(action: BackupSwipeAction) {
    switch action {
    case .delete:
      deleteBackupAction()
    case .rename:
      renameAction()
    }
  }

  func deleteBackupAction() {
    let alertController = UIAlertController(title: L10n.Backup.Delete.alertTitle, message: L10n.Backup.Delete.alertMessage, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: L10n.confirm, style: .destructive, handler: { [unowned self] _ in
      Task {
        guard let selectFile = backupViewModel.selectFile else { return }
        do {
          try self.backupViewModel.deleteBackupFile(selectFile.url)
        } catch {
          presentError(error: ErrorMessage(title: L10n.Backup.Delete.errorTitle, message: L10n.Backup.Delete.errorMessage))
        }
        self.backupViewModel.loadBackupFiles()
      }
    }))
    alertController.addAction(UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil))
    present(alertController, animated: true, completion: nil)
  }

  func renameAction() {
    let alertController = UIAlertController(title: L10n.Backup.Rename.alertTitle, message: nil, preferredStyle: .alert)
    alertController.addTextField { $0.placeholder =  L10n.Backup.Rename.newName}
    alertController.addAction(UIAlertAction(title: L10n.confirm, style: .destructive, handler: { [unowned self, alertController] _ in
      Task {
        guard let textFields = alertController.textFields else { return }
        guard let selectFile = backupViewModel.selectFile else { return }
        let newFileName = textFields[0].text ?? ""
        guard !newFileName.isEmpty else { return }
        try await self.backupViewModel.renameBackupFile(at: selectFile.url, newFileName: newFileName)
        self.backupViewModel.loadBackupFiles()
      }
    }))
    alertController.addAction(UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil))
    present(alertController, animated: true)
  }
}
