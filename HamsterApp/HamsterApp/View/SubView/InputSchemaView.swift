//
//  InputSchemeView.swift
//  HamsterApp
//
//  Created by morse on 5/3/2023.
//

import SwiftUI

struct InputSchemaError: Error {
  var message: String
}

struct InputSchemaView: View {
  @State var schemas: [Schema] = []
  @State var rimeError: Error?
  @State var showHamsteriCloud = false
  @State var showError: Bool = false
  @State var selectSchemas: Set<Schema> = []

  @EnvironmentObject
  var appSettings: HamsterAppSettings

  @EnvironmentObject
  var rimeEngine: RimeEngine

  @Environment(\.dismiss)
  var dismiss

  init(schemas: [Schema] = []) {
    Logger.shared.log.debug("InputSchemaView init()")
    self.schemas = schemas
  }

  @ViewBuilder
  var iCloudView: some View {
    HamsteriCloudView(
      isShow: $showHamsteriCloud,
      contentType: .zip,
      importingCallback: { file in
        Logger.shared.log.debug("file.fileName: \(file.fileName)")
        do {
          let fm = FileManager.default

          let tempZipURL = fm.temporaryDirectory.appendingPathComponent("temp.zip")
          if fm.fileExists(atPath: tempZipURL.path) {
            try fm.removeItem(at: tempZipURL)
          }
          fm.createFile(atPath: tempZipURL.path, contents: file.data)

          let (handled, zipErr) = try RimeEngine.unzipUserData(tempZipURL)
          if !handled {
            showError = true
            rimeError = zipErr
            return
          }

          // Rime重新部署
          rimeEngine.startRime(nil, fullCheck: true)

          appSettings.rimeUserSelectSchema = []
          appSettings.rimeInputSchema = ""
          rimeEngine.initAppSettingRimeInputSchema(appSettings)
          schemas = appSettings.rimeUserSelectSchema
          selectSchemas = Set(schemas)
          appSettings.rimeNeedOverrideUserDataDirectory = true
          showHamsteriCloud = false

          rimeEngine.shutdownRime()
        } catch {
          // 处理错误
          Logger.shared.log.debug("zip \(error)")
          showError = true
          rimeError = error
        }
      }
    )
    .transition(.move(edge: .bottom).animation(.easeInOut(duration: 1)))
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
            LongButton(buttonText: "确定", buttonWidth: 160) {
              if selectSchemas.isEmpty {
                showError = true
                rimeError = InputSchemaError(message: "请选择输入方案")
                return
              }
              let selectSchemas = Array(selectSchemas.sorted())
              let handled = rimeEngine.setSelectRimeSchemas(schemas: selectSchemas)
              Logger.shared.log.info("rimeEngine set select input schema handled \(handled)")
              appSettings.rimeUserSelectSchema = selectSchemas
              appSettings.rimeInputSchema = appSettings.rimeUserSelectSchema.first!.schemaId
              dismiss()
            }
          }
          .padding(.horizontal)
          .padding(.bottom, 10)
        }

        if showHamsteriCloud {
          iCloudView
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            showHamsteriCloud = true
          } label: {
            Image(systemName: "plus")
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
          }
        )
      }
      .onAppear {
        rimeEngine.startRime()
        self.schemas = rimeEngine.getAvailableRimeSchemas().sorted()
        self.selectSchemas = Set(appSettings.rimeUserSelectSchema)

        Logger.shared.log.info("InputSchemaView selectSchemas: \(selectSchemas)")
      }
      .onDisappear {
        rimeEngine.shutdownRime()
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
    InputSchemaView(
      schemas: sampleSchemas
    )
    .environmentObject(HamsterAppSettings())
    .environmentObject(RimeEngine())
  }
}
