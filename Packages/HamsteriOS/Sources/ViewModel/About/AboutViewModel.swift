//
//  File.swift
//
//
//  Created by morse on 2023/7/7.
//

import Combine
import HamsterKit
import ProgressHUD
import UIKit

public class AboutViewModel: ObservableObject {
  private unowned var mainViewModel: MainViewModel

  init(mainViewModel: MainViewModel) {
    self.mainViewModel = mainViewModel
  }

  lazy var cellInfos: [AboutCellInfo] = {
    [
      .init(text: "RIME版本", secondaryText: AppInfo.rimeVersion, type: .copy),
      .init(text: "许可证", secondaryText: "GPLv3", type: .link, typeValue: "https://www.gnu.org/licenses/gpl-3.0.html"),
      .init(text: "联系邮箱", secondaryText: "morse.hsiao@gmail.com", type: .mail, typeValue: "morse.hsiao@gmail.com"),
      .init(text: "开源地址", secondaryText: "https://github.com/imfuxiao/Hamster", type: .link, typeValue: "https://github.com/imfuxiao/Hamster"),
      .init(text: "使用开源库列表", type: .navigation, accessoryType: .disclosureIndicator, navigationAction: { [unowned self] in mainViewModel.subView = .openSource }),
    ]
  }()

  func tapAction(cellInfo: AboutCellInfo) {
    switch cellInfo.cellType {
    case .link:
      if let link = cellInfo.typeValue, let url = URL(string: link) {
        UIApplication.shared.open(url)
      }
    case .mail:
      if let link = cellInfo.typeValue, let url = URL(string: "mailto:\(link)") {
        UIApplication.shared.open(url)
      }
    case .copy:
      UIPasteboard.general.string = cellInfo.secondaryText
      ProgressHUD.showSuccess("复制成功", interaction: false, delay: 1.5)
    default:
      break
    }
  }
}
