//
//  ContentView.swift
//  Hamster
//
//  Created by morse on 10/1/2023.
//

import Combine
import SwiftUI

struct SettingView: View {
  @State var isError: Bool = false
  @State var err: Error?

  var body: some View {
    List {
      VStack {
        Button {
          do {
            try ShareManager.initShareResources(appAbsolutePath: Bundle.main.resourceURL!)
          } catch {
            err = error
          }
        } label: {
          Text("部署")
        }
      }
    }
    .alert(isPresented: $isError, content: {
      Alert(title: Text(err != nil ? err!.localizedDescription : ""))
    })
  }
}

struct AboutView: View {
  var body: some View {
    Text("关于页面")
  }
}

public struct ContentView: View {
  public init() {}

  public var body: some View {
    TabView {
      SettingView()
        .tabItem {
          Label("设置", systemImage: "gear.circle")
        }
      AboutView()
        .tabItem {
          Label("关于", systemImage: "info.circle.fill")
        }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
