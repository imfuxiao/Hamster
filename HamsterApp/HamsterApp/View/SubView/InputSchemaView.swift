//
//  InputSchemeView.swift
//  HamsterApp
//
//  Created by morse on 5/3/2023.
//

import SwiftUI

struct InputSchemaView: View {
  @State var schemas: [Schema] = []
  @State var rimeError: Error?
  @EnvironmentObject var appSettings: HamsterAppSettings
  @EnvironmentObject var rimeEngine: RimeEngine

  init(schemas: [Schema] = []) {
    Logger.shared.log.debug("InputSchemaView init()")
    self.schemas = schemas
  }

  var body: some View {
    ZStack {
      Color.HamsterBackgroundColor.ignoresSafeArea()

      VStack {
        HStack {
          Text("输入方案")
            .subViewTitleFont()
          Spacer()
        }
        .padding(.horizontal)

        ScrollView {
          ForEach(schemas) { schema in
            VStack {
              HStack {
                RadioButton(width: 24, fontSize: 12, isSelected: isSelect(schema)) {
                  appSettings.rimeInputSchema = schema.schemaId
                }
                Text(schema.schemaName)
                  .font(.system(.body, design: .rounded))
                Spacer()
              }
              .frame(minWidth: 0, maxWidth: .infinity)
              .frame(minHeight: 0, maxHeight: .infinity)
              .frame(height: 40)
              .contentShape(Rectangle(), eoFill: true)
              .onTapGesture {
                appSettings.rimeInputSchema = schema.schemaId
              }
              
              Divider()
            }
          }
        }
        .padding(.top, 5)
        .padding(.horizontal)
//        .listStyle(.plain)

        Spacer()
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .animation(.default, value: appSettings.rimeInputSchema)
    .frame(minWidth: 0, maxWidth: .infinity)
    .frame(minHeight: 0, maxHeight: .infinity)
    .onAppear {
      rimeEngine.startRime()
      schemas = rimeEngine.getSchemas()
      if appSettings.rimeInputSchema.isEmpty && !schemas.isEmpty {
        appSettings.rimeInputSchema = schemas[0].schemaId
      } else {
        let schema = schemas.first(where: { $0.schemaId == appSettings.rimeInputSchema })
        if schema == nil && !schemas.isEmpty {
          appSettings.rimeInputSchema = schemas[0].schemaId
        }
      }
    }
    .onDisappear {
      rimeEngine.shutdownRime()
    }
  }

  func isSelect(_ schema: Schema) -> Bool {
    return schema.schemaId == appSettings.rimeInputSchema
  }
}

let sampleSchemas: [Schema] = [
  .init(schemaId: "1", schemaName: "小鹤音形"),
  .init(schemaId: "2", schemaName: "朙月拼音"),
  .init(schemaId: "3", schemaName: "朙月拼音-简化字"),
  .init(schemaId: "4", schemaName: "朙月拼音-语句流"),
  .init(schemaId: "5", schemaName: "注音"),
]

struct InputSchemaView_Previews: PreviewProvider {
  static var previews: some View {
    InputSchemaView(
      schemas: sampleSchemas
    )
    .environmentObject(HamsterAppSettings())
    .environmentObject(RimeEngine())
  }
}
