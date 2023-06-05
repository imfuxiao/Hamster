//
//  ColorSchemaTableViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/19.
//

import UIKit

class ColorSchemaTableViewCell: UITableViewCell {
  static let identifier = "ColorSchemaTableViewCell"
  
  var colorSchema: HamsterColorSchema?

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    tintColor = UIColor.systemGreen
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func updateConfiguration(using state: UICellConfigurationState) {
    guard let colorSchema = colorSchema else { return }
    
    contentView.subviews.forEach { contentView.removeConstraints($0.constraints); $0.removeFromSuperview() }
   
    let colorSchemaView = HamsterColorSchemaView(colorSchema: colorSchema)
    
    contentView.addSubview(colorSchemaView)
    NSLayoutConstraint.activate([
      colorSchemaView.topAnchor.constraint(equalTo: contentView.topAnchor),
      colorSchemaView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      colorSchemaView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      colorSchemaView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
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
