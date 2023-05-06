//
//  SyncSettingsView.swift
//  HamsterApp
//
//  Created by morse on 4/5/2023.
//

import Combine
import Foundation
import ProgressHUD
import SwiftUI

let _backupRemark = """
注意：
1. 点击 + 号新建备份文件；
2. 点击备份文件可恢复；
3. 恢复后需要点击“重新部署”按钮；
"""

struct BackupView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings
  @State var showAlert = false
  @State var alertMessage = ""
  @State var selectIdx: IndexSet?
  @State var showDeleteAlert = false
  @State var showRestore = false
  @State var selectRestoreFileURL: URL?
  @State var backupFilesURL: [URL] = []

  var title: some View {
    VStack {
      HStack {
        Text("软件备份")
          .subViewTitleFont()
        Spacer()
      }
      .padding(.horizontal)
    }
  }

  var backupView: some View {
    VStack {
      HStack {
        Text("备份与恢复")
          .font(.system(size: 16, weight: .bold, design: .rounded))

        Spacer()

        Image(systemName: "goforward.plus")
          .font(.system(size: 22))
          .overlay(
            Color.white.opacity(0.0001)
              .overlay(
                Color.clear
                  .contentShape(Rectangle())
                  .onTapGesture {
                    ProgressHUD.show("软件备份中，请等待……", interaction: false)
                    DispatchQueue.global().async {
                      do {
                        try FileManager.default.hamsterBackup(appSettings: appSettings)
                        // 重载方案列表
                        backupFilesURL = FileManager.default.backupFiles(appSettings: appSettings)
                      } catch {
                        Logger.shared.log.error("App backup error: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                          ProgressHUD.dismiss()
                          showAlert = true
                          alertMessage = "备份异常。\(error.localizedDescription)"
                        }
                        return
                      }
                      ProgressHUD.showSuccess("备份成功", delay: 1.5)
                    }
                  }
              )
              .accessibilityAddTraits(.isButton)
          )
      }

      HStack {
        Text(_backupRemark)
          .font(.system(size: 14))
        Spacer()
      }
    }
    .alert(isPresented: $showRestore) {
      Alert(
        title: Text("是否确认恢复？"),
        message: Text("恢复成功后，需要重新部署后方可生效。"),
        primaryButton: .destructive(Text("恢复")) {
          guard let selectRestoreFileURL = selectRestoreFileURL else { return }
          ProgressHUD.show("恢复中，请等待……", interaction: false)

          DispatchQueue.global().async {
            do {
              try FileManager.default.hamsterRestore(selectRestoreFileURL, appSettings: appSettings)
            } catch {
              DispatchQueue.main.async {
                ProgressHUD.dismiss()
                showAlert = true
                alertMessage = "恢复失败，\(error.localizedDescription)"
              }
              return
            }
            ProgressHUD.showSuccess("恢复成功", delay: 1.5)
          }
        },
        secondaryButton: .cancel(Text("取消")) {
          selectRestoreFileURL = nil
        }
      )
    }
    .hiddenListSectionSeparator()
    .functionCell()
    .listRowBackground(Color.HamsterBackgroundColor)
  }

  var backupFileListView: some View {
    ForEach(backupFilesURL, id: \.lastPathComponent) { backupURL in
      VStack {
        HStack {
          Text(backupURL.lastPathComponent)
            .font(.system(size: 16, weight: .bold, design: .rounded))
          Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
          showRestore = true
          selectRestoreFileURL = backupURL
        }
      }
      .hiddenListSectionSeparator()
      .functionCell()
      .listRowBackground(Color.HamsterBackgroundColor)
    }
    .onDelete { idx in
      selectIdx = idx
      showAlert = true
      showDeleteAlert = true
    }
    .alert(isPresented: $showDeleteAlert) {
      Alert(
        title: Text("是否确认删除？"),
        primaryButton: .destructive(Text("删除")) {
          guard let selectIdx = selectIdx else { return }
          selectIdx.forEach { idx in
            if backupFilesURL.count > idx {
              do {
                try FileManager.default.deleteBackupFile(backupFilesURL[idx])
                backupFilesURL = FileManager.default.backupFiles(appSettings: appSettings)
              } catch {}
            }
          }
        },
        secondaryButton: .cancel(Text("取消")) {
          selectIdx = nil
        }
      )
    }
  }

  var body: some View {
    GeometryReader { _ in
      ZStack {
        Color.HamsterBackgroundColor.ignoresSafeArea()

        VStack(spacing: 0) {
          title

          List {
//            VStack {
//              HStack {
//                Text("拷贝键盘方案至应用目录")
//                  .font(.system(size: 16, weight: .bold, design: .rounded))
//                Spacer()
//              }
//              .frame(minWidth: 0, maxWidth: .infinity)
//              .contentShape(Rectangle())
//              .onTapGesture {
//                isLoading = true
//                loadingText = "复制中……"
//
//                DispatchQueue.global().async {
//                  do {
//                    try RimeContext.syncAppGroupSharedSupportDirectoryToSandbox(override: true)
//                    try RimeContext.syncAppGroupUserDataDirectoryToSandbox(override: true)
//                  } catch {
//                    Logger.shared.log.error("rime copy error \(error.localizedDescription)")
//                    isLoading = false
//                    showAlert = true
//                    alertMessage = error.localizedDescription
//                    return
//                  }
//                  DispatchQueue.main.async {
//                    isLoading = false
//                  }
//                }
//              }
//            }
//            .hiddenListSectionSeparator()
//            .functionCell()
//            .listRowBackground(Color.HamsterBackgroundColor)

            backupView

            backupFileListView
          }
          .listStyle(.plain)
          .background(Color.HamsterBackgroundColor)
          .modifier(ListBackgroundModifier())
        }
        .frame(minWidth: 0, maxWidth: .infinity)
      }
      .alert(isPresented: $showAlert) {
        Alert(
          title: Text(alertMessage),
          dismissButton: .default(Text("取消")) {
            appSettings.enableAppleCloud = false
          }
        )
      }
      .onAppear {
        backupFilesURL = FileManager.default.backupFiles(appSettings: appSettings)
      }
    }
  }
}

struct BackupView_Previews: PreviewProvider {
  static var previews: some View {
    BackupView()
  }
}
