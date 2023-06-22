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
  @EnvironmentObject var appSettings: HamsterAppSettings
  @EnvironmentObject var rimeContext: RimeContext

  var syncAndBackupView: some View {
    SectionView("同步与备份") {
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

  var aboutView: some View {
    SectionView("关于") {
      NavigationLink {
        AboutView()
      } label: {
        AdvancedSettingCellView(image: "info.circle", title: "关于")
      }
    }
  }

  var toolbarView: some View {
    VStack {
      HStack {
        Image("Hamster")
          .resizable()
          .scaledToFill()
          .frame(width: 25, height: 25)
          .padding(.all, 5)
          .background(
            RoundedRectangle(cornerRadius: 5)
              .stroke(Color.gray.opacity(0.5), lineWidth: 1)
          )
        Text("仓输入法")

        Spacer()
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

          aboutView
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
    AdvancedSettingsView()
      .environmentObject(HamsterAppSettings.shared)
      .environmentObject(RimeContext.shared)
  }
}
