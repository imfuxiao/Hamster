//
//  FinderViewCell.swift
//
//
//  Created by morse on 2023/7/7.
//

import HamsterKit
import HamsterUIKit
import UIKit

class FinderViewCell: NibLessTableViewCell {
  static let identifier = "FinderViewCell"

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  var fileInfo: FileInfo?
}

extension FinderViewCell {
  override func updateConfiguration(using state: UICellConfigurationState) {
    guard let fileInfo = fileInfo else { return }

    var cellConfig = UIListContentConfiguration.subtitleCell()

    cellConfig.text = fileInfo.url.lastPathComponent

    if let type = fileInfo.fileResourceType {
      switch type {
      case .directory:
        cellConfig.image = UIImage(systemName: "folder.fill")?
          .withConfiguration(UIImage.SymbolConfiguration(scale: .large))
      case .regular:
        cellConfig.image = UIImage(systemName: "doc.fill")?
          .withConfiguration(UIImage.SymbolConfiguration(scale: .large))
      default:
        break
      }
    }

    if let modifiedDate = fileInfo.fileModifiedDate {
      cellConfig.secondaryText = DateFormatter.longTimeFormatStyle.string(from: modifiedDate)
    }

    self.contentConfiguration = cellConfig
  }
}
