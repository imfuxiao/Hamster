//
//  EditorView.swift
//  HamsterApp
//
//  Created by morse on 4/4/2023.
//

import SwiftUI

struct EditorView: View {
  @EnvironmentObject
  var appSettings: HamsterAppSettings

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

        HStack {
          Text("注意: 编辑完成后记得点击重新部署, 否则方案不会生效")
            .font(.system(size: 12))
            .foregroundColor(.secondary)
          Spacer()
        }
        .padding(.top)
        .padding(.horizontal)

        FinderView(finderURL: RimeContext.sandboxDirectory)
      }
    }
  }
}

struct EditorView_Previews: PreviewProvider {
  static var previews: some View {
    EditorView()
  }
}
