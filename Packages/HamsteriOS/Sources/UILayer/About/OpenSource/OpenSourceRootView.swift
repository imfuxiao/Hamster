//
//  File.swift
//
//
//  Created by morse on 2023/7/7.
//

import HamsterUIKit
import UIKit

class OpenSourceRootView: NibLessView {
  private let openSourceViewModel: OpenSourceViewModel

  init(frame: CGRect = .zero, openSourceViewModel: OpenSourceViewModel) {
    self.openSourceViewModel = openSourceViewModel
    super.init(frame: frame)

    constructViewHierarchy()
    activateViewConstraints()
  }

  let tableView: UITableView = {
    let tableView = UITableView(frame: .zero, style: .plain)
    tableView.register(OpenSourceTableViewCell.self, forCellReuseIdentifier: OpenSourceTableViewCell.identifier)
    return tableView
  }()

  override func constructViewHierarchy() {
    addSubview(tableView)
    tableView.delegate = self
    tableView.dataSource = self
  }

  override func activateViewConstraints() {
    tableView.fillSuperview()
  }
}

extension OpenSourceRootView: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    openSourceViewModel.openSourceList.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: OpenSourceTableViewCell.identifier, for: indexPath)

    if let cell = cell as? OpenSourceTableViewCell {
      cell.openSourceInfo = openSourceViewModel.openSourceList[indexPath.row]
    }

    return cell
  }
}

extension OpenSourceRootView: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let openSourceInfo = openSourceViewModel.openSourceList[indexPath.row]
    if let url = URL(string: openSourceInfo.projectURL) {
      UIApplication.shared.open(url)
    }
  }
}
