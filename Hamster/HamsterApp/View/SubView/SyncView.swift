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
1. 与其他修改方案相同，iCloud中变动必须点击“重新部署”方能生效；
2. 启用iCloud后，每次“重新部署”，会增量（文件名相同且内容相同的文件或文件夹会跳过）形式将iCloud中的文件拷贝至应用内部；
3. 启用iCloud后，输入方案会存储在iCloud下的`Hamster/RIME`文件夹下（中文系统为：仓输入法/RIME）;
4. 在启用iCloud后，仓应用在启动时会在后台监听iCloud文件变化，但因网络等因素，仓不能保证同步一定会成功, 需要您在点击“重新部署”按钮前自行确认;
  （您可使用系统内置应用Files应用确认文件是否已全部同步完毕）；
5. 如果方案还没有同步到手机端，此时点击“重新部署”会可能导致输入法输入异常；
"""

let _copyRemark = """
注意：
1. 应用内部的方案文件（如自造词文件）在变动后，不会自动同步到iCloud，需要您手工点击“拷贝方案至iCloud”；
2. “拷贝方案至iCloud”与“RIME同步”是不同的功能；
"""

let _copyToCloudFilterRegexRemark = """
1. 多个正则表达式使用英文逗号分隔；
2. 需要过滤功能的伙伴，请自行设置;
3. 常用正则示例（点击可复制全部表达式，记得按需修改或调整）:
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
    .hiddenListSectionSeparator()
    .functionCell()
    .listRowBackground(Color.HamsterBackgroundColor)
  }

  var copyInputSchemaToAppleCloud: some View {
    VStack {
      HStack {
        Text("拷贝方案至iCloud")

        Spacer()

        Image(systemName: "doc.on.doc")
          .font(.system(size: 22))
          .overlay(
            Color.white.opacity(0.0001)
              .overlay(
                Color.clear
                  .contentShape(Rectangle())
                  .onTapGesture {
                    ProgressHUD.show("拷贝方案至iCloud中……", interaction: false)
                    DispatchQueue.global().async {
                      do {
                        let regexList = appSettings.copyToCloudFilterRegex.split(separator: ",").map { String($0) }
                        try RimeContext.copySandboxSharedSupportDirectoryToAppleCloud(regexList)
                        try RimeContext.copySandboxUserDataDirectoryToAppleCloud(regexList)
                      } catch {
                        DispatchQueue.main.async {
                          ProgressHUD.dismiss()
                          showAlert = true
                          alertMessage = "拷贝方案至iCloud异常：\(error.localizedDescription)"
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
    .hiddenListSectionSeparator()
    .functionCell()
    .listRowBackground(Color.HamsterBackgroundColor)
  }

  var regexFilterView: some View {
    VStack {
      HStack {
        TextField("拷贝过滤表达式", text: $appSettings.copyToCloudFilterRegex)
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
    .hiddenListSectionSeparator()
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
          .background(Color.HamsterBackgroundColor)
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
