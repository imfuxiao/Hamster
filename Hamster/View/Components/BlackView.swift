//
//  BlackView.swift
//  HamsterApp
//
//  Created by morse on 25/4/2023.
//

import SwiftUI

struct BlackView: View {
  var bgColor: Color = .black.opacity(0.3)
  var body: some View {
    VStack {
      Spacer()
    }
    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    .background(bgColor)
    .edgesIgnoringSafeArea(.all)
  }
}

struct BlackView_Previews: PreviewProvider {
  static var previews: some View {
    BlackView()
  }
}
