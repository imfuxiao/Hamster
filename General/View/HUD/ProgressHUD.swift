//
//  ProgressHUD.swift
//  Hamster
//
//  Created by morse on 19/5/2023.
//

import ProgressHUD
import SwiftUI

struct ProgressHUD_Previews: PreviewProvider {
  struct ProgressHUDView: View {
    var body: some View {
      Button {
        ProgressHUD.show("Some text...", interaction: false)
        DispatchQueue.main.async {
          Thread.sleep(forTimeInterval: 3)
          ProgressHUD.showSuccess("Some text...", delay: 1.5)
        }
      } label: {
        Text("HUD")
      }
    }
  }

  static var previews: some View {
    ProgressHUDView()
  }
}
