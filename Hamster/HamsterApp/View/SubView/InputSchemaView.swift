//
//  InputSchemeView.swift
//  HamsterApp
//
//  Created by morse on 5/3/2023.
//

import ProgressHUD
import SwiftUI

struct InputSchemaError: Error {
  var message: String
}

struct InputSchemaView: View {
  @State var schemas: [Schema] = []
  @State var rimeError: Error?
  @State var showHamsteriCloud = false
  @State var showError = false
  @State var isLoading = false
  @State var loadingText = ""
  @State var selectSchemas: Set<Schema> = []

  @EnvironmentObject
  var appSettings: HamsterAppSettings

  @Environment(\.dismiss)
  var dismiss

  init() {
    Logger.shared.log.debug("InputSchemaView init()")
  }

  /// 导入zip文件
  func importCallback(file: HamsterDocument) {
    Logger.shared.log.debug("file.fileName: \(file.fileName)")
    ProgressHUD.show("方案导入中……", interaction: true)
    do {
      let fm = FileManager.default
      let (handled, zipErr) = try fm.unzip(
        file.data,
        dst: RimeContext.sandboxUserDataDirectory
      )
      if !handled {
        ProgressHUD.dismiss()
        showError = true
        rimeError = zipErr
        return
      }

      ProgressHUD.show("部署中……")

      let traits = Rime.createTraits(
        sharedSupportDir: RimeContext.sandboxSharedSupportDirectory.path,
        userDataDir: RimeContext.sandboxUserDataDirectory.path
      )
      let deployHandled = Rime.shared.deploy(traits)
      Logger.shared.log.debug("rimeEngine deploy handled \(deployHandled)")

      DispatchQueue.main.async {
        let resetHandled = appSettings.resetRimeParameter()
        Logger.shared.log.debug("rimeEngine resetRimeParameter \(resetHandled)")

        // 复制输入方案至AppGroup下
        try? RimeContext.syncSandboxUserDataDirectoryToApGroup(override: true)

        schemas = appSettings.rimeTotalSchemas
        selectSchemas = Set(appSettings.rimeUserSelectSchema)

        showHamsteriCloud = false
        ProgressHUD.showSuccess("导入成功", delay: 1.5)
      }

    } catch {
      ProgressHUD.dismiss()
      Logger.shared.log.debug("zip \(error)")
      DispatchQueue.main.async {
        // 处理错误
        showError = true
        rimeError = error
      }
    }
  }

  @ViewBuilder
  var iCloudView: some View {
    HamsteriCloudView(
      isShow: $showHamsteriCloud,
      contentType: .zip,
      importingCallback: { file in
        DispatchQueue.global().async {
          importCallback(file: file)
        }
      }
    )
  }

  var body: some View {
    GeometryReader { _ in
      ZStack(alignment: .center) {
        Color.HamsterBackgroundColor.ignoresSafeArea()
        VStack {
          HStack {
            Text("选择输入方案")
              .subViewTitleFont()
            Spacer()
          }
          .padding(.horizontal)

          HStack {
            Text("由于版权及其他因素, 无法内置更多的输入方案. 您可以通过'文件上传'功能, 上传自己喜欢的输入方案.")
              .font(.system(size: 12))
              .foregroundColor(.secondary)
            Spacer()
          }
          .padding(.top)
          .padding(.horizontal)

          ScrollView {
            ForEach(schemas) { schema in
              InputSchemaCell(
                schema: schema,
                isSelect: selectSchemas.contains(schema),
                showDivider: true
              ) {
                if selectSchemas.contains($0) {
                  selectSchemas.remove($0)
                } else {
                  selectSchemas.insert($0)
                }
              }
            }
          }
          .padding(.top, 5)
          .padding(.horizontal)

          HStack(alignment: .center) {
            LongButton(buttonText: "确定") {
              if selectSchemas.isEmpty {
                showError = true
                rimeError = InputSchemaError(message: "请选择输入方案")
                return
              }
              appSettings.rimeUserSelectSchema = Array(selectSchemas.sorted())
              appSettings.rimeInputSchema = appSettings.rimeUserSelectSchema.first?.schemaId ?? ""
              appSettings.lastUseRimeInputSchema = appSettings.rimeUserSelectSchema.count > 1 ? appSettings.rimeUserSelectSchema[1].schemaId : ""
              dismiss()
            }
            .frame(width: 200)
          }
          .padding(.horizontal)
          .padding(.bottom, 10)
        }

        if showHamsteriCloud {
          iCloudView
        }
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showHamsteriCloud = true
          } label: {
            Image(systemName: "plus")
              .font(.system(size: 20))
              .contentShape(Rectangle())
          }
        }
      }
      .alert(isPresented: $showError) {
        var message: String
        if let err = rimeError as? ZipParsingError {
          message = err.message
        } else if let err = rimeError as? InputSchemaError {
          message = err.message
        } else {
          message = rimeError?.localizedDescription ?? ""
        }
        return Alert(
          title: Text(message),
          dismissButton: .cancel {
            rimeError = nil
            isLoading = false
          }
        )
      }
      .onAppear {
        self.schemas = appSettings.rimeTotalSchemas
        self.selectSchemas = Set(appSettings.rimeUserSelectSchema)
        Logger.shared.log.info("InputSchemaView selectSchemas: \(selectSchemas)")
      }
    }
  }
}

struct InputSchemaView_Previews: PreviewProvider {
  static let sampleSchemas: [Schema] = [
    .init(schemaId: "1", schemaName: "小鹤音形"),
    .init(schemaId: "2", schemaName: "朙月拼音"),
    .init(schemaId: "3", schemaName: "朙月拼音-简化字"),
    .init(schemaId: "4", schemaName: "朙月拼音-语句流"),
    .init(schemaId: "5", schemaName: "注音"),
  ]

  static var previews: some View {
    InputSchemaView()
      .environmentObject(HamsterAppSettings())
      .environmentObject(RimeContext())
  }
}
