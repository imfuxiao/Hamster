//
//  KeyboardFeedbackRootView.swift
//
//
//  Created by morse on 14/7/2023.
//

import HamsterUIKit
import UIKit

class KeyboardFeedbackRootView: NibLessView {
  // MARK: properties

  private let keyboardFeedbackViewModel: KeyboardFeedbackViewModel

  lazy var tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .insetGrouped)
    tableView.delegate = self
    tableView.dataSource = self
    tableView.allowsSelection = false
    tableView.translatesAutoresizingMaskIntoConstraints = false
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
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: topAnchor),
      tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
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
      return ToggleTableViewCell(settingItem: .init(
        text: "开启按键声",
        toggleValue: keyboardFeedbackViewModel.enableKeySounds,
        toggleHandled: { [unowned self] in
          keyboardFeedbackViewModel.enableKeySounds = $0
        }
      ))
    }

    return HapticFeedbackTableViewCell(keyboardFeedbackViewModel: keyboardFeedbackViewModel)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return UITableView.automaticDimension
  }
}
