//
//  FinderViewCell.swift
//
//
//  Created by morse on 2023/7/7.
//

import HamsterKit
import HamsterUIKit
import UIKit

private extension UIConfigurationStateCustomKey {
  static let fileInfo = UIConfigurationStateCustomKey("com.ihsiao.apps.hamster.keyboard.settings.FileInfo")
}

private extension UICellConfigurationState {
  var fileInfo: FileInfo? {
    set { self[.fileInfo] = newValue }
    get { return self[.fileInfo] as? FileInfo }
  }
}

class FinderViewCell: NibLessTableViewCell {
  static let identifier = "FinderViewCell"

  private var fileInfo: FileInfo?

  override var configurationState: UICellConfigurationState {
    var state = super.configurationState
    state.fileInfo = self.fileInfo
    return state
  }

  override init(style: UITableViewCell.CellStyle = .default, reuseIdentifier: String? = FinderViewCell.identifier) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
  }

  func updateWithFileInfo(_ fileInfo: FileInfo) {
    guard self.fileInfo != fileInfo else { return }
    self.fileInfo = fileInfo
    setNeedsUpdateConfiguration()
  }

  override func updateConfiguration(using state: UICellConfigurationState) {
    var cellConfig = UIListContentConfiguration.subtitleCell()
    cellConfig.text = state.fileInfo?.url.lastPathComponent

    if let type = state.fileInfo?.fileResourceType {
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

    if let modifiedDate = state.fileInfo?.fileModifiedDate {
      cellConfig.secondaryText = DateFormatter.longTimeFormatStyle.string(from: modifiedDate)
    }

    self.contentConfiguration = cellConfig
  }
}
