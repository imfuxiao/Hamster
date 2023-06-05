//
//  FinderViewCell.swift
//  Hamster
//
//  Created by morse on 2023/6/13.
//

import UIKit

class FinderViewCell: UITableViewCell {
  static let identifier = "FinderViewCell"
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
      cellConfig.secondaryText = Self.modifiedDateFormat.string(from: modifiedDate)
    }

    self.contentConfiguration = cellConfig
  }

  static var modifiedDateFormat: DateFormatter {
    let format = DateFormatter()
    format.locale = Locale(identifier: "zh_Hans_SG")
    format.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return format
  }
}
