//
//  SwiftUIView.swift
//
//
//  Created by morse on 2/2/2023.
//

import SwiftUI

struct AboutView: View {
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

struct AboutView_Previews: PreviewProvider {
  static var previews: some View {
    AboutView()
  }
}
