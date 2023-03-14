//
//  InputSchemeView.swift
//  HamsterApp
//
//  Created by morse on 5/3/2023.
//

import SwiftUI

struct InputSchemaView: View {
  @State
  var schemas: [Schema] = []

  @State
  var selectSchema: Schema?

  @State
  var rimeError: Error?

  @EnvironmentObject
  var appSetting: HamsterAppSettings

  @EnvironmentObject
  var rimeEngine: RimeEngine

  init(schemas: [Schema] = [], selectSchema: Schema? = nil) {
    self.schemas = schemas
    self.selectSchema = selectSchema
  }

  var body: some View {
    ZStack {
      Color.gray.opacity(0.1).ignoresSafeArea(.all)

      VStack {
        VStack {
          HStack {
            Text("输入方案")
              .font(.system(.title3, design: .rounded))
              .fontWeight(.bold)

            Spacer()
          }
        }
        .padding(.horizontal)

        List {
          ForEach(schemas) { schema in
            HStack {
              Image(systemName: "checkmark")
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(.green)
                .opacity(isSelect(schema) ? 1 : 0)

              Text(schema.schemaName)
                .font(.system(.body, design: .rounded))

              Spacer()
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(minHeight: 0, maxHeight: .infinity)
            .onTapGesture {
              selectSchema = schema
            }
          }
        }
        .padding(.top, 20)
        .padding(.horizontal)
        .listStyle(.plain)
      }
    }
    .animation(.default, value: selectSchema)
    .frame(minWidth: 0, maxWidth: .infinity)
    .frame(minHeight: 0, maxHeight: .infinity)
    .onChange(
      of: selectSchema,
      perform: { newSelectSchame in
        if let selectSchema = newSelectSchame {
          appSetting.rimeInputSchema = selectSchema.schemaId
        }
      }
    )
    .onAppear {
      if !rimeEngine.rimeAlive() {
        do {
          try rimeEngine.launch()
        } catch {
          print(error)
        }
      }
      schemas = rimeEngine.getSchemas()
      selectSchema = rimeEngine.status().currentSchema()
    }
  }

  func isSelect(_ schema: Schema) -> Bool {
    if let selectSchema = selectSchema {
      if selectSchema.schemaId == schema.schemaId {
        return true
      }
    }
    return false
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
      schemas: sampleSchemas,
      selectSchema: sampleSchemas[0]
    )
    .environmentObject(HamsterAppSettings())
    .environmentObject(RimeEngine.shared)
  }
}
