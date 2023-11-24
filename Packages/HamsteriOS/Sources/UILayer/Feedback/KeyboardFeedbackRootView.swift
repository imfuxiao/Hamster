//
//  KeyboardFeedbackRootView.swift
//
//
//  Created by morse on 14/7/2023.
//

import Combine
import HamsterUIKit
import UIKit

class KeyboardFeedbackRootView: NibLessView {
  // MARK: properties

  private var subscriptions = Set<AnyCancellable>()
  private let keyboardFeedbackViewModel: KeyboardFeedbackViewModel

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.allowsSelection = false
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 40
    return tableView
  }()

  // MARK: methods

  init(frame: CGRect = .zero, keyboardFeedbackViewModel: KeyboardFeedbackViewModel) {
    self.keyboardFeedbackViewModel = keyboardFeedbackViewModel

    super.init(frame: frame)

    setupTableView()

    keyboardFeedbackViewModel.hapticFeedbackStatePublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        let animator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
          self.tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
        }
        animator.startAnimation()
      }
      .store(in: &subscriptions)
  }

  func setupTableView() {
    addSubview(tableView)
    tableView.fillSuperview()
  }
}

extension KeyboardFeedbackRootView: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = ToggleTableViewCell(style: .default, reuseIdentifier: ToggleTableViewCell.identifier)
      cell.settingItem = .init(
        text: L10n.Feedback.sound,
        toggleValue: { [unowned self] in keyboardFeedbackViewModel.enableKeySounds },
        toggleHandled: { [unowned self] in
          keyboardFeedbackViewModel.enableKeySounds = $0
        }
      )
      return cell
    }
    return HapticFeedbackTableViewCell(keyboardFeedbackViewModel: keyboardFeedbackViewModel)
  }

  func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
    if section == 1 {
      return L10n.Feedback.hapticPermission
    }
    return ""
  }
}
