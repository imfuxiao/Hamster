//
//  LoadingView.swift
//  HamsterApp
//
//  Created by morse on 16/3/2023.
//

import SwiftUI

struct LoaderView: View {
  var tintColor: Color = .green
  var scaleSize: CGFloat = 1.0
  
  var body: some View {
    ProgressView()
      .scaleEffect(scaleSize, anchor: .center)
      .progressViewStyle(CircularProgressViewStyle(tint: tintColor))
  }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
      LoaderView()
    }
}
