//
//  CloudInputSchemaCellTableViewCell.swift
//
//
//  Created by morse on 2023/11/11.
//

import HamsterUIKit
import UIKit

extension UIConfigurationStateCustomKey {
  static let inputSchemaInfo = UIConfigurationStateCustomKey("com.ihsiao.apps.hamster.inputSchema.CloudInputSchemaCell.inputSchemaInfo")
}

extension UICellConfigurationState {
  var inputSchemaInfo: InputSchemaViewModel.InputSchemaInfo? {
    set { self[.inputSchemaInfo] = newValue }
    get { return self[.inputSchemaInfo] as? InputSchemaViewModel.InputSchemaInfo }
  }
}

class CloudInputSchemaCell: NibLessTableViewCell {
  public static let identifier = "CloudInputSchemaCell"

  override var configurationState: UICellConfigurationState {
    var state = super.configurationState
    state.inputSchemaInfo = self.inputSchemaInfo
    return state
  }

  private var inputSchemaInfo: InputSchemaViewModel.InputSchemaInfo?

  private lazy var titleLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .left
    label.numberOfLines = 1
    label.lineBreakMode = .byTruncatingMiddle
    label.textColor = UIColor.label
    label.font = UIFont.preferredFont(forTextStyle: .body)
    return label
  }()

  private lazy var authorLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .left
    label.numberOfLines = 1
    label.lineBreakMode = .byTruncatingTail
    label.textColor = UIColor.secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: .caption1)
    return label
  }()

  private lazy var descLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.textAlignment = .left
    label.numberOfLines = 2
    label.lineBreakMode = .byTruncatingTail
    label.textColor = UIColor.secondaryLabel
    label.font = UIFont.preferredFont(forTextStyle: .caption2)
    return label
  }()

  private lazy var container: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [titleLabel, authorLabel, descLabel])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.alignment = .leading
    stack.distribution = .fill
    stack.spacing = 0
    return stack
  }()

  override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    self.accessoryType = .disclosureIndicator
    contentView.addSubview(container)
    NSLayoutConstraint.activate([
      container.topAnchor.constraint(equalToSystemSpacingBelow: contentView.topAnchor, multiplier: 1),
      container.leadingAnchor.constraint(equalToSystemSpacingAfter: contentView.leadingAnchor, multiplier: 1),
      contentView.trailingAnchor.constraint(equalToSystemSpacingAfter: container.trailingAnchor, multiplier: 1),
      contentView.bottomAnchor.constraint(equalToSystemSpacingBelow: container.bottomAnchor, multiplier: 1)
    ])
  }

  override func prepareForReuse() {
    super.prepareForReuse()

    titleLabel.text = ""
    authorLabel.text = ""
    descLabel.text = ""
  }

  func updateWithInputSchemaInfo(_ info: InputSchemaViewModel.InputSchemaInfo) {
    guard inputSchemaInfo != info else { return }
    self.inputSchemaInfo = info
    setNeedsUpdateConfiguration()
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

    self.titleLabel.text = state.inputSchemaInfo?.title
    self.authorLabel.text = state.inputSchemaInfo?.author
    self.descLabel.text = state.inputSchemaInfo?.description
  }
}
