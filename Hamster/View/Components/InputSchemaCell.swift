//
//  InputSchemaCell.swift
//  HamsterApp
//
//  Created by morse on 21/4/2023.
//

import SwiftUI

struct InputSchemaCell: View {
  var schema: Schema
  var isSelect: Bool
  var showDivider: Bool
  var action: (Schema) -> Void

  var body: some View {
    VStack(spacing: 0) {
      HStack(spacing: 0) {
        RadioButton(width: 24, fontSize: 12, isSelected: isSelect) {
          action(schema)
        }
        Text(schema.schemaName)
          .font(.system(.body, design: .rounded))
          .padding(.leading, 5)
        Spacer()
      }
      .frame(minWidth: 0, maxWidth: .infinity)
      .frame(height: 40)
      .contentShape(Rectangle())
      .onTapGesture {
        action(schema)
      }

      if showDivider {
        Divider()
      }
    }
  }
}

struct InputSchemaCell_Previews: PreviewProvider {
  static var previews: some View {
    InputSchemaCell(schema: Schema(schemaId: "1", schemaName: "测试"), isSelect: false, showDivider: true) {
      print($0)
    }
  }
}
