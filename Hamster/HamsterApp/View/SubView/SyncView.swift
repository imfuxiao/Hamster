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

let _iCloudRemark = """
注意：
1. 启用后，每次运行“重新部署”会复制与iCloud中不同的文件；
2. 当iCloud中文件没有从云端下载，此时点击“重新部署”可能会导致输入法异常；
"""

let _copyRemark = """
注意：
1. 应用内的文件不会自动同步到iCloud，需要您手工执行此功能；
2. 拷贝行为默认为全量拷贝，如需过滤拷贝内容，需要配合下面的过滤表达式一起使用；
3. 过滤表达式在“重新部署”功能中也会生效；
"""

let _copyToCloudFilterRegexRemark = """
1. 多个正则表达式使用英文逗号分隔；
2. 常用示例（点击可复制全部表达式，请按需修改）:
   * 过滤userdb目录 ^.*[.]userdb.*$
   * 过滤build目录 ^.*build.*$
   * 过滤SharedSupport目录 ^.*SharedSupport.*$
   * 过滤编译后的词库文件 ^.*[.]bin$
"""

let _clipboardOnCopyToCloudFilterRegexRemark = "^.*[.]userdb.*$,^.*build.*$,^.*SharedSupport.*$,^.*[.]bin$"

struct SyncView: View {
  @EnvironmentObject var appSettings: HamsterAppSettings
  @State var cancellables = Set<AnyCancellable>()
  @State var showAlert = false
  @State var alertMessage = ""

  var title: some View {
    VStack {
      HStack {
        Text("输入方案同步")
          .subViewTitleFont()
        Spacer()
      }
      .padding(.horizontal)
    }
  }

  var enableAppleCloudView: some View {
    VStack {
      HStack {
        Toggle(isOn: $appSettings.enableAppleCloud) {
          Text("启用iCloud")
            .font(.system(size: 16, weight: .bold, design: .rounded))
        }
      }

      HStack {
        Text(_iCloudRemark)
          .font(.system(size: 14))
      }
    }
    .hideListRowSeparator()
    .functionCell()
    .listRowBackground(Color.HamsterBackgroundColor)
  }

  var copyInputSchemaToAppleCloud: some View {
    VStack {
      HStack {
        Text("拷贝本地文件至iCloud")

        Spacer()

        Image(systemName: "doc.on.doc")
          .font(.system(size: 22))
          .overlay(
            Color.white.opacity(0.0001)
              .overlay(
                Color.clear
                  .contentShape(Rectangle())
                  .onTapGesture {
                    ProgressHUD.show("拷贝本地文件至iCloud中……", interaction: false)
                    DispatchQueue.global().async {
                      do {
                        let regexList = appSettings.copyToCloudFilterRegex.split(separator: ",").map { String($0) }
                        try RimeContext.copySandboxSharedSupportDirectoryToAppleCloud(regexList)
                        try RimeContext.copySandboxUserDataDirectoryToAppleCloud(regexList)
                      } catch {
                        DispatchQueue.main.async {
                          ProgressHUD.dismiss()
                          showAlert = true
                          alertMessage = "拷贝异常：\(error.localizedDescription)"
                        }
                        return
                      }
                      ProgressHUD.showSuccess("拷贝成功", delay: 1.5)
                    }
                  }
              )
              .accessibilityAddTraits(.isButton)
          )
      }

      HStack {
        Text(_copyRemark)
          .font(.system(size: 14))
          .contentShape(Rectangle())

        Spacer()
      }
    }
    .hideListRowSeparator()
    .functionCell()
    .listRowBackground(Color.HamsterBackgroundColor)
  }

  var regexFilterView: some View {
    VStack {
      HStack {
        TextField("过滤表达式", text: $appSettings.copyToCloudFilterRegex)
          .textFieldStyle(BorderTextFieldBackground(systemImageString: "pencil"))
          .padding(.vertical, 5)
          .foregroundColor(.secondary)
        Spacer()
      }

      HStack {
        Text(_copyToCloudFilterRegexRemark)
          .font(.system(size: 14))
        Spacer()
      }
      .contentShape(Rectangle())
      .onTapGesture {
        UIPasteboard.general.string = _clipboardOnCopyToCloudFilterRegexRemark
        ProgressHUD.showSuccess("复制成功", delay: 1.5)
      }
    }
    .hideListRowSeparator()
    .functionCell()
    .listRowBackground(Color.HamsterBackgroundColor)
  }

  var body: some View {
    GeometryReader { _ in
      ZStack {
        Color.HamsterBackgroundColor.ignoresSafeArea()

        VStack(spacing: 0) {
          title

          ScrollView {
            enableAppleCloudView
              .padding(.horizontal)

            copyInputSchemaToAppleCloud
              .padding(.horizontal)

            regexFilterView
              .padding(.horizontal)
          }
          .padding(.top, 10)
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
        appSettings.$enableAppleCloud
          .receive(on: DispatchQueue.global())
          .sink {
            if !$0 {
              return
            }

            let fm = FileManager.default

            // 获取iCloud token
            if let _ = fm.ubiquityIdentityToken, let _ = FileManager.iCloudDocumentURL {
              // iCloud enabled, access granted
              DispatchQueue.main.async {
                showAlert = false
              }

            } else {
              // iCloud disabled, or not signed in
              DispatchQueue.main.async {
                showAlert = true
                alertMessage = "系统iCloud未启用或未登录"
              }
              return
            }

//            do {
//              Logger.shared.log.debug("iCloud path: \(FileManager.iCloudDocumentURL?.path ?? "")")
//              let regexList = appSettings.copyToCloudFilterRegex.split(separator: ",").map { String($0) }
//              if !fm.fileExists(atPath: FileManager.iCloudSharedSupportURL.path) {
//                try FileManager.createDirectory(dst: FileManager.iCloudSharedSupportURL)
//                try RimeContext.copySandboxSharedSupportDirectoryToAppleCloud(regexList)
//              }
//              if !fm.fileExists(atPath: FileManager.iCloudUserDataURL.path) {
//                try FileManager.createDirectory(dst: FileManager.iCloudUserDataURL)
//                try RimeContext.copySandboxUserDataDirectoryToAppleCloud(regexList)
//              }
//            } catch {
//              Logger.shared.log.error("copy to iCloud error: \(error.localizedDescription)")
//            }
          }
          .store(in: &cancellables)
      }
    }
  }
}

struct SyncView_Previews: PreviewProvider {
  static var previews: some View {
    SyncView()
  }
}
