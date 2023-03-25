//
//  SectionView.swift
//  HamsterApp
//
//  Created by morse on 2023/3/20.
//

import SwiftUI

struct SectionView<Content: View>: View {
  typealias ContentBuilder = () -> Content

  var title: String
  @ViewBuilder var content: ContentBuilder

  init(_ title: String, @ViewBuilder content: @escaping ContentBuilder) {
    self.title = title
    self.content = content
  }

  var body: some View {
    Section {
      content()
    } header: {
      HStack {
        Text(title)
          .font(.system(size: 18, weight: .bold, design: .rounded))
        Spacer()
      }
      .padding(.horizontal)
      .padding(.top, 20)
    }
  }
}
