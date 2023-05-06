//
//  MBProgressHUD+SwiftUI.swift
//  Hamster
//
//  Created by morse on 18/5/2023.
//

//import Combine
//import MBProgressHUD
//import SwiftUI
//
//struct MBProgressHUDRepresentable: UIViewRepresentable {
//  @Binding var message: String
//  let action: (_ hud: MBProgressHUD) -> Void
//
//  func makeUIView(context: Context) -> UIView {
//    UIView()
//  }
//
//  func updateUIView(_ uiView: UIView, context: Context) {
//    let hud = MBProgressHUD.showAdded(to: uiView, animated: true)
//    hud.mode = MBProgressHUDMode.indeterminate
//    hud.label.text = message
//    DispatchQueue.global().async {
//      action(hud)
//    }
//  }
//
//  typealias UIViewType = UIView
//}
//
//extension View {
//  func mbHud(
//    isShow: Binding<Bool>,
//    message: Binding<String>,
//    action: @escaping (_ hud: MBProgressHUD) -> Void) -> some View
//  {
//    ZStack {
//      self
//      if isShow.wrappedValue {
//        BlackView()
//        MBProgressHUDRepresentable(message: message) { hub in
//          action(hub)
//        }
//      }
//    }
//  }
//}
//
//struct MBProgressHUD_SwiftUI_Previews: PreviewProvider {
//  struct MBProgressHUDDemo: View {
//    @State var message: String = ""
//    @State var isShow = false
//
//    var body: some View {
//      VStack {
//        Text("HelloWorld")
//        Text("HelloWorld")
//        Text("HelloWorld")
//        Text("HelloWorld")
//        Text("HelloWorld")
//        Text("HelloWorld")
//        Button {
//          isShow = true
//          message = "部署中"
//        } label: {
//          Text("Hud")
//        }
//      }
//      .mbHud(isShow: $isShow, message: $message) { hud in
//        Thread.sleep(forTimeInterval: 1)
//        DispatchQueue.main.async {
//          hud.label.text = "测试1"
//          Thread.sleep(forTimeInterval: 1)
//          DispatchQueue.main.async {
//            Thread.sleep(forTimeInterval: 1)
//            hud.hide(animated: true)
//            isShow = false
//          }
//        }
//      }
//    }
//  }
//
//  static var previews: some View {
//    MBProgressHUDDemo()
//  }
//}
