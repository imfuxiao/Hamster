//
//  ColorSchemaTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/19.
//

import HamsterModel
import HamsterUIKit
import UIKit

class KeyboardColorTableViewCell: NibLessTableViewCell {
  static let identifier = "KeyboardColorTableViewCell"
  
  public var keyboardColor: KeyboardColor?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    tintColor = UIColor.systemGreen
  }
  
  override func updateConfiguration(using state: UICellConfigurationState) {
    guard let keyboardColor = keyboardColor else { return }
    
    contentView.subviews.forEach { contentView.removeConstraints($0.constraints); $0.removeFromSuperview() }
    
    let view = KeyboardColorView(colorSchema: keyboardColor)
   
    contentView.addSubview(view)
    NSLayoutConstraint.activate([
      view.topAnchor.constraint(equalTo: contentView.topAnchor),
      view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      view.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
    ])
    
    accessoryType = state.isSelected ? .checkmark : .none
    
    if state.isSelected {
      accessoryType = .checkmark
      layer.borderColor = UIColor.systemGreen.cgColor
      layer.borderWidth = 1.5
    } else {
      accessoryType = .none
      layer.borderColor = UIColor.clear.cgColor
      layer.borderWidth = 0
    }
  }
}
