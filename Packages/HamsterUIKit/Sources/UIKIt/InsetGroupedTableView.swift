//
//  File.swift
//
//
//  Created by morse on 2023/7/5.
//

import UIKit

open class InsetGroupedTableView: UITableView {
  public init() {
    super.init(frame: .zero, style: .insetGrouped)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
