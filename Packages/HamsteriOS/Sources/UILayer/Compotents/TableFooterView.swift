//
//  FooterView.swift
//  Hamster
//
//  Created by morse on 2023/6/14.
//

import UIKit

class TableFooterView: UITableViewHeaderFooterView {
  static let identifier = "HamsterTableFooterView"

  init(footer: String) {
    self.text = footer
    super.init(reuseIdentifier: Self.identifier)
    var config = UIListContentConfiguration.groupedFooter()
    config.text = text
    contentConfiguration = config
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var text = ""
}
