//
//  SymbolCell.swift
//
//
//  Created by morse on 2023/9/7.
//

import UIKit

/// 扩展 UIConfigurationStateCustomKey，用来表示 state 中自定义的数据
private extension UIConfigurationStateCustomKey {
  static let classifySymbolCellText = UIConfigurationStateCustomKey("com.ihsiao.apps.hamster.keyboard.ClassifyKeyboardCell.text")
}

/// 扩展 UICellConfigurationState，添加自定义数据属性
private extension UICellConfigurationState {
  var symbol: String? {
    get {
      self[.classifySymbolCellText] as? String
    }
    set {
      self[.classifySymbolCellText] = newValue
    }
  }
}

/// 符号单元格
class SymbolCell: UICollectionViewListCell {
  public var highlightedColor: UIColor? = nil
  public var normalColor: UIColor? = nil
  public var labelHighlightColor: UIColor? = nil
  public var labelNormalColor: UIColor? = nil
  public var symbol: String? = nil

  var symbolLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  override var configurationState: UICellConfigurationState {
    var state = super.configurationState
    state.symbol = symbol
    return state
  }

  override init(frame: CGRect = .zero) {
    super.init(frame: frame)

    contentView.addSubview(symbolLabel)
    symbolLabel.fillSuperview()

    NSLayoutConstraint.activate([
      symbolLabel.heightAnchor.constraint(equalToConstant: 40),
      separatorLayoutGuide.leadingAnchor.constraint(equalTo: leadingAnchor)
    ])
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func updateWithSymbol(_ symbol: String,
                        highlightedColor: UIColor? = nil,
                        normalColor: UIColor? = nil,
                        labelHighlightColor: UIColor? = nil,
                        labelNormalColor: UIColor? = nil)
  {
    self.symbol = symbol
    self.highlightedColor = highlightedColor
    self.normalColor = normalColor
    self.labelNormalColor = labelNormalColor
    self.labelHighlightColor = labelHighlightColor

    setNeedsUpdateConfiguration()
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)

//    var contentConfig = UIListContentConfiguration.valueCell()
//    contentConfig.text = state.symbol
//    contentConfig.textProperties.font = UIFont.systemFont(ofSize: 12)
//    contentConfig.textProperties.alignment = .center
//    contentConfig.textProperties.adjustsFontSizeToFitWidth = true
//    contentConfig.axesPreservingSuperviewLayoutMargins = .both
//    contentConfig.directionalLayoutMargins = .zero

    symbolLabel.text = state.symbol
    symbolLabel.font = UIFont.systemFont(ofSize: 16)
    symbolLabel.textAlignment = .center
    symbolLabel.adjustsFontSizeToFitWidth = true

    var backgroundConfig = UIBackgroundConfiguration.listGroupedCell()

    if state.isHighlighted || state.isSelected {
      backgroundConfig.backgroundColor = highlightedColor
      if let color = labelHighlightColor {
        // contentConfig.textProperties.color = color
        symbolLabel.textColor = color
      }
    } else {
      backgroundConfig.backgroundColor = normalColor
      if let color = labelNormalColor {
        // contentConfig.textProperties.color = color
        symbolLabel.textColor = color
      }
    }

    // self.contentConfiguration = contentConfig
    self.backgroundConfiguration = backgroundConfig
  }
}
