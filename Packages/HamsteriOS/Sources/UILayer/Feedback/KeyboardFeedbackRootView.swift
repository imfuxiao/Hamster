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
    return tableView
  }()

  // MARK: methods

  init(frame: CGRect = .zero, keyboardFeedbackViewModel: KeyboardFeedbackViewModel) {
    self.keyboardFeedbackViewModel = keyboardFeedbackViewModel

    super.init(frame: frame)
  }

  override func constructViewHierarchy() {
    addSubview(tableView)
  }

  override func activateViewConstraints() {
    tableView.fillSuperview()
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()

    constructViewHierarchy()
    activateViewConstraints()

    keyboardFeedbackViewModel.$enableHapticFeedback
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .automatic)
      }
      .store(in: &subscriptions)
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
        text: "开启按键声",
        toggleValue: keyboardFeedbackViewModel.enableKeySounds,
        toggleHandled: { [unowned self] in
          keyboardFeedbackViewModel.enableKeySounds = $0
        }
      )
      return cell
    }
    return HapticFeedbackTableViewCell(keyboardFeedbackViewModel: keyboardFeedbackViewModel)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}
