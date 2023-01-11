//
//  ContentView.swift
//  Hamster
//
//  Created by morse on 10/1/2023.
//

import SwiftUI

public struct ContentView: View {
  public init() {}

  public var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundColor(.accentColor)
      Text("Hamster")
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
