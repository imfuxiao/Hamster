//
//  ColorSchemaTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/19.
//

import HamsterKeyboardKit
import HamsterUIKit
import UIKit

class KeyboardColorTableViewCell: NibLessTableViewCell {
  static let identifier = "KeyboardColorTableViewCell"
  
  public var keyboardColor: HamsterKeyboardColor? = nil

  private let keyboardColorView: KeyboardColorView = {
    let view = KeyboardColorView(frame: .zero, colorSchema: .init(userInterfaceStyle: .light))
    return view
  }()
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    tintColor = UIColor.systemGreen
    
    setupSubview()
  }
  
  func setupSubview() {
    contentView.addSubview(keyboardColorView)
    keyboardColorView.fillSuperview()
  }
  
  func updatePreviewColor(_ color: HamsterKeyboardColor) {
    self.keyboardColor = color
    keyboardColorView.keyboardColor = color
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
