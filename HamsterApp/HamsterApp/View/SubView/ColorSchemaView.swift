//
//  ColorSchemaView.swift
//  HamsterApp
//
//  Created by morse on 9/3/2023.
//

import SwiftUI

struct ColorSchemaView: View {
  @State var colorSchemas: [ColorSchema] = []
  @EnvironmentObject var appSettings: HamsterAppSettings
  @EnvironmentObject var rimeEngine: RimeEngine

  func isSelected(_ colorSchema: ColorSchema) -> Bool {
    return colorSchema.schemaName == appSettings.rimeColorSchema
  }

  var body: some View {
    ZStack {
      Color.HamsterBackgroundColor.ignoresSafeArea()

      VStack {
        HStack {
          Text("配色方案")
            .subViewTitleFont()

          Spacer()
        }
        .padding(.horizontal)

        HStack {
          Toggle(isOn: $appSettings.enableRimeColorSchema) {
            Text("启用配色")
              .font(.system(size: 16, weight: .bold, design: .rounded))
          }
        }
        .padding(.horizontal)

        if appSettings.enableRimeColorSchema {
          ScrollView {
            ForEach(colorSchemas) { colorSchema in
              HStack {
                RadioButton(isSelected: isSelected(colorSchema)) {
                  appSettings.rimeColorSchema = colorSchema.schemaName
                }
                WordView(colorSchema: colorSchema)
                  .background(
                    RoundedRectangle(cornerRadius: 15)
                      .strokeBorder(lineWidth: 1)
                      .foregroundColor(
                        isSelected(colorSchema) ? .green.opacity(0.8) : Color.gray
                      )
                  )
                  .onTapGesture {
                    appSettings.rimeColorSchema = colorSchema.schemaName
                  }
              }
              .padding(.horizontal)
            }
          }
        }

        Spacer()
      }
      .frame(minWidth: 0, maxWidth: .infinity)
      .frame(minHeight: 0, maxHeight: .infinity)
    }
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      self.colorSchemas = appSettings.rimeTotalColorSchemas
    }
  }
}

struct WordView: View {
  var colorSchema: ColorSchema
  var body: some View {
    VStack {
      HStack {
        Text("方案名称: " + colorSchema.name)
          .font(.system(size: 16, weight: .bold))
        Spacer()
      }
      .foregroundColor(.primary)

      HStack {
        Text("作者: " + colorSchema.author)
          .font(.system(size: 16, weight: .bold))
          .lineLimit(1)
          .minimumScaleFactor(0.5)
        Spacer()
      }
      .foregroundColor(.primary)
      .padding(.bottom, 2)

      VStack {
        // 组字区域
        HStack {
          Text("方案")
            .foregroundColor(colorSchema.textColor.bgrColor ?? .clear)
          Text("pei se˰")
            .foregroundColor(colorSchema.hilitedTextColor.bgrColor ?? .clear)
          Spacer()
        }
        .background(colorSchema.hilitedBackColor.bgrColor ?? .clear)
        .font(.system(.body))
        .padding(.leading, 5)

        HStack {
          // 首选区域
          HStack {
            Text("1. 配色")
              .foregroundColor(colorSchema.hilitedCandidateTextColor.bgrColor ?? .clear)
            Text("(pei se)")
              .foregroundColor(colorSchema.hilitedCommentTextColor.bgrColor ?? .clear)
          }
          .background(
            Rectangle()
              .fill(colorSchema.hilitedCandidateBackColor.bgrColor ?? .clear)
          )

          Text("2. 陪")
            .foregroundColor(colorSchema.candidateTextColor.bgrColor ?? .clear)

          Text("(pei)")
            .foregroundColor(colorSchema.commentTextColor.bgrColor ?? .clear)

          Spacer()
        }
        .font(.system(.body))
        .padding(.leading, 5)
      }
      .background(
        RoundedRectangle(cornerRadius: 5)
          .fill(colorSchema.backColor.bgrColor ?? .clear)
          .frame(height: 50)
      )
    }
    .frame(minWidth: 0, maxWidth: .infinity)
    .padding(.horizontal)
    .padding(.vertical, 5)
    .padding(.bottom, 10)
  }
}

struct ColorSchemaView_Previews: PreviewProvider {
  static let sampleColorSchema: [ColorSchema] = [
    .init(
      schemaName: "azure",
      name: "青天／Azure",
      author: "佛振 <chen.sst@gmail.com>",
      backColor: "0xee8b4e01",
      borderColor: "",
      textColor: "0xcfa677",
      hilitedTextColor: "0xffeacc",
      hilitedBackColor: "",
      hilitedCandidateTextColor: "0x7ffeff",
      hilitedCandidateBackColor: "0x00000000",
      hilitedCommentTextColor: "0xfcac9d",
      candidateTextColor: "0xffeacc",
      commentTextColor: "0xc69664"
    ),
  ]

  static var previews: some View {
    ColorSchemaView(colorSchemas: sampleColorSchema)
      .environmentObject(RimeEngine())
      .environmentObject(HamsterAppSettings())
  }
}
