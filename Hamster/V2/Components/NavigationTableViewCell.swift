//
//  NavigationTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/15.
//

import UIKit

class NavigationTableViewCell: UITableViewCell {
  static let identifier = "NavigationTableViewCell"
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.text = ""
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentConfiguration = UIListContentConfiguration.valueCell()
  }

  init(text: String, secondaryText: String?, navigationLink: @escaping () -> UIViewController, controller: UIViewController) {
    self.text = text
    self.secondaryText = secondaryText
    self.navigationLink = navigationLink
    self.controller = controller

    super.init(style: .default, reuseIdentifier: Self.identifier)

    var config = UIListContentConfiguration.valueCell()
    config.text = text
    config.secondaryText = secondaryText
    contentConfiguration = config
    accessoryType = .disclosureIndicator
    contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(navigationLinkHandled)))
  }

  var text: String
  var secondaryText: String?
  var navigationLink: (() -> UIViewController)?
  unowned var controller: UIViewController?

  @objc func navigationLinkHandled() {
    Logger.shared.log.debug("navigationLinkHandled")
    if let navigation = navigationLink?() {
      controller?.navigationController?.pushViewController(navigation, animated: true)
    }
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
