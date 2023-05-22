//
//  AdvancedSettingsView.swift
//  HamsterApp
//
//  Created by morse on 4/5/2023.
//

import ProgressHUD
import SwiftUI

/// 高阶设置页
struct AdvancedSettingsView: View {
  init(appSettings: HamsterAppSettings, rimeContext: RimeContext) {
    self.appSettings = appSettings
    self.rimeContext = rimeContext
  }

  let appSettings: HamsterAppSettings
  let rimeContext: RimeContext

  var syncAndBackupView: some View {
    SectionView("同步与备份") {
      LongButton(
        buttonText: "拷贝键盘词库文件至应用"
      ) {
        DispatchQueue.global().async {
          ProgressHUD.show("拷贝中……", interaction: true)
          do {
            try rimeContext.copyAppGroupUserDict()
          } catch {
            ProgressHUD.showError("拷贝失败：\(error.localizedDescription)")
            return
          }
          ProgressHUD.showSuccess("拷贝词库成功", delay: 1.5)
        }
      }
      .padding(.horizontal)

      NavigationLink {
        SyncView()
      } label: {
        AdvancedSettingCellView(image: "externaldrive.badge.icloud", title: "iCloud同步")
      }
      NavigationLink {
        BackupView()
      } label: {
        AdvancedSettingCellView(image: "externaldrive.fill.badge.plus", title: "软件备份")
      }
    }
  }

  var rimeView: some View {
    SectionView("RIME") {
      NavigationLink {
        RIMEView(appSettings: appSettings, rimeContext: rimeContext)
      } label: {
        AdvancedSettingCellView(abbreviations: "㞢", title: "RIME")
      }
    }
  }

  var body: some View {
    VStack(alignment: .center, spacing: 0) {
      ScrollView {
        // 同步与备份区域
        syncAndBackupView

        // RIME
        rimeView
      }
    }
    .background(Color.HamsterBackgroundColor.ignoresSafeArea())
  }
}

struct AdvancedSettingCellView: View {
  var image: String?
  var abbreviations: String?
  var title: String

  var body: some View {
    HStack {
      if let image = image {
        Image(systemName: image)
      }
      if let abbreviations = abbreviations {
        Text(abbreviations)
          .font(.system(size: 16))
      }
      Text(title)
      Spacer()
      Image(systemName: "chevron.right")
        .font(.system(size: 12))
        .padding(.leading, 5)
        .foregroundColor(Color.HamsterFontColor)
    }
    .functionCell()
    .padding(.horizontal)
  }
}

struct AdvancedSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    AdvancedSettingsView(appSettings: HamsterAppSettings(), rimeContext: RimeContext())
  }
}
