//
//  ColorSchemaView.swift
//  HamsterApp
//
//  Created by morse on 9/3/2023.
//

import SwiftUI

struct ColorSchemaView: View {
  @State
  var colorSchemas: [ColorSchema] = []

  @State
  var selectColorSchema: ColorSchema?

  @EnvironmentObject
  var rimeEngine: RimeEngine

  var body: some View {
    VStack {
      HStack {
        Text("配色方案")
          .font(.system(.title, design: .rounded))
          .fontWeight(.black)

        Spacer()
      }
      .padding(.horizontal)

      ScrollView {
        ForEach(colorSchemas) {
          WordView(colorSchema: $0)
        }
      }
    }
    .frame(minWidth: 0, maxWidth: .infinity)
    .frame(minHeight: 0, maxHeight: .infinity)
    .onAppear {
      if rimeEngine.rimeAlive() {
        self.colorSchemas = rimeEngine.colorSchema()
        let currentColorName = rimeEngine.currentColorSchemaName()
        self.selectColorSchema = self.colorSchemas.first(where: { $0.schemaName == currentColorName })
      }
    }
  }
}

struct WordView: View {
  var colorSchema: ColorSchema
  var body: some View {
    VStack {
      HStack {
        Text(colorSchema.schemaName)
          .font(.system(.title2))
          .fontWeight(.bold)
        Spacer()
      }
      .foregroundColor(.primary)

      HStack {
        Text(colorSchema.author)
          .font(.system(.footnote))
          .fontWeight(.heavy)
          .lineLimit(1)
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
  }
}

struct ColorSchemaView_Previews: PreviewProvider {
  static let sampleColorSchema: [ColorSchema] = [
    .init(
      schemaName: "aqua",
      name: "碧水／Aqua",
      author: "佛振 <chen.sst@gmail.com>",
      backColor: "0xeeeceeee",
      borderColor: "",

      textColor: "0x606060",
      hilitedTextColor: "0x000000",
      hilitedBackColor: "",

      hilitedCandidateTextColor: "0xffffff",
      hilitedCandidateBackColor: "0xeefa3a0a",
      hilitedCommentTextColor: "0xfcac9d",
      candidateTextColor: "0x000000",
      commentTextColor: "0x5a5a5a"
    ),
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
    .init(
      schemaName: "solarized_rock",
      name: "曬經石／Solarized Rock",
      author: "Aben <tntaben@gmail.com>, based on Ethan Schoonover's Solarized color scheme",
      backColor: "0x362b00",
      borderColor: "0x362b00",

      textColor: "0x8236d3",
      hilitedTextColor: "0x98a12a",
      hilitedBackColor: "",

      hilitedCandidateTextColor: "0xffffff",
      hilitedCandidateBackColor: "0x8236d3",
      hilitedCommentTextColor: "0x362b00",
      candidateTextColor: "0x969483",
      commentTextColor: "0xc098a12a"
    ),
  ]

  static var previews: some View {
    ColorSchemaView(colorSchemas: sampleColorSchema)
      .environmentObject(RimeEngine.shared)
  }
}
