//
//  EditorView.swift
//  HamsterApp
//
//  Created by morse on 4/4/2023.
//

import ProgressHUD
import SwiftUI

struct FileManagerView: View {
  init(appSettings: HamsterAppSettings) {
    _appSettings = ObservedObject(wrappedValue: appSettings)
    if appSettings.enableAppleCloud {
      tags = ["设置", "应用文件", "键盘文件", "iCloud文件"]
    } else {
      tags = ["设置", "应用文件", "键盘文件"]
    }
  }

  @ObservedObject var appSettings: HamsterAppSettings
  @EnvironmentObject var rimeContext: RimeContext
  @State var tags: [String]
  @State var selectTag = 0
  @State var overrideSandboxFile = false

  let remark = """
  注意:
  1. 编辑完成后记得点击重新部署, 否则方案不会生效;
  2. 编辑器目前只能对文件进行修改, 大量的修改还是建议在PC上操作;
  3. 后续看需求, 是否需要在增强编辑器的功能;
  """
  var body: some View {
    ZStack {
      Color.HamsterBackgroundColor.ignoresSafeArea()

      VStack {
        HStack {
          Text("文件编辑")
            .subViewTitleFont()
          Spacer()
        }
        .padding(.horizontal)

//        HStack {
//          Text("注意: 编辑完成后记得点击重新部署, 否则方案不会生效")
//            .font(.system(size: 12))
//            .foregroundColor(.secondary)
//          Spacer()
//        }
//        .padding(.top)
//        .padding(.horizontal)

        HStack(spacing: 0) {
          Picker(selection: $selectTag, label: Text("")) {
            ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
              Button {
                withAnimation {
                  selectTag = index
                }
              } label: {
                Text(tag)
                  .font(.system(size: 16, weight: .bold))
              }
              .buttonStyle(.plain)
              .tag(index)
            }
          }
          .pickerStyle(SegmentedPickerStyle())
        }
        .padding(.horizontal)

        if selectTag == 0 {
          otherView
        }

        // 应用内文件
        if selectTag == 1 {
//          HStack {
//            Text("路径：\(RimeContext.sandboxDirectory.path)")
//              .font(.system(size: 12))
//              .foregroundColor(.secondary)
//              .minimumScaleFactor(0.5)
//            Spacer()
//          }
//          .padding(.vertical)
//          .padding(.horizontal)

          FinderView(finderURL: RimeContext.sandboxDirectory)
        }

        // 键盘内文件
        if selectTag == 2 {
          HStack {
            Text("注意：未开启键盘完全访问权限，键盘无法使用当前 Rime 路径，会使用键盘自己的沙盒目录。")
              .font(.system(size: 12))
              .foregroundColor(.secondary)
              .minimumScaleFactor(0.5)
            Spacer()
          }
          .padding(.vertical)
          .padding(.horizontal)
          FinderView(finderURL: RimeContext.shareURL)
        }

        // iCloud文件
        if selectTag > 2 {
          if let iCloudURL = FileManager.iCloudDocumentURL {
//            HStack {
//              Text("路径：\(iCloudURL.path)")
//                .font(.system(size: 12))
//                .foregroundColor(.secondary)
//                .minimumScaleFactor(0.5)
//              Spacer()
//            }
//            .padding(.vertical)
//            .padding(.horizontal)
            FinderView(finderURL: iCloudURL)
          } else {
            HStack {
              Text("iCloud路径获取异常")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
              Spacer()
            }
            .padding(.top)
            .padding(.horizontal)
          }
        }

        Spacer()
      }
    }
  }
}

extension FileManagerView {
  var otherView: some View {
    VStack(spacing: 0) {
      LongButton(
        buttonText: "拷贝键盘词库文件至应用"
      ) {
        DispatchQueue.global().async {
          ProgressHUD.show("拷贝中……", interaction: true)
          do {
            try rimeContext.copyAppGroupUserDict(["^.*[.]userdb.*$", "^.*[.]txt$"])
          } catch {
            ProgressHUD.showError("拷贝失败：\(error.localizedDescription)")
            return
          }
          ProgressHUD.showSuccess("拷贝词库成功", delay: 1.5)
        }
      }
      .padding(.all)

      LongButton(
        buttonText: "使用键盘文件覆盖应用文件"
      ) {
        overrideSandboxFile = true
      }
      .padding(.all)
      .alert(isPresented: $overrideSandboxFile) {
        Alert(title: Text("是否覆盖"), message: Text("确定使用键盘文件覆盖应用文件？"), primaryButton: .destructive(Text("是")) {
          DispatchQueue.global().async {
            ProgressHUD.show("覆盖中……", interaction: true)
            do {
              // 使用AppGroup下文件覆盖应用Sandbox下文件
              try RimeContext.syncAppGroupSharedSupportDirectoryToSandbox(override: true)
              try RimeContext.syncAppGroupUserDataDirectoryToSandbox(override: true)
            } catch {
              ProgressHUD.showError("覆盖失败：\(error.localizedDescription)")
              return
            }
            ProgressHUD.showSuccess("完成", delay: 1.5)
          }
        }, secondaryButton: .cancel())
      }
    }
  }
}

struct EditorView_Previews: PreviewProvider {
  static var previews: some View {
    FileManagerView(appSettings: HamsterAppSettings.shared)
  }
}
