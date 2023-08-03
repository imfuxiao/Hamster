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
  
  public var keyboardColor: KeyboardColor

  private let keyboardColorView: KeyboardColorView
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    self.keyboardColor = .init(name: "", colorSchema: .init(name: ""))
    self.keyboardColorView = .init()

    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    tintColor = UIColor.systemGreen
    
    setupSubview()
  }
  
  func setupSubview() {
    contentView.addSubview(keyboardColorView)
    keyboardColorView.fillSuperview()
  }
  
  func updatePreviewColor() {
    keyboardColorView.keyboardColor = keyboardColor
    keyboardColorView.updatePreviewColor()
  }
  
  func updateCellState(_ selected: Bool) {
    if selected {
      accessoryType = .checkmark
      layer.borderColor = UIColor.systemGreen.cgColor
      layer.borderWidth = 1.5
    } else {
      accessoryType = .none
      layer.borderColor = UIColor.clear.cgColor
      layer.borderWidth = 0
    }
  }
  
  override func updateConfiguration(using state: UICellConfigurationState) {
    super.updateConfiguration(using: state)
    updateCellState(state.isSelected)
  }
}
