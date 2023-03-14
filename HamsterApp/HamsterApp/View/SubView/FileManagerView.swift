//
//  FileManagerView.swift
//  HamsterApp
//
//  Created by morse on 14/3/2023.
//

import iFilemanager
import SwiftUI
import UIKit

struct FileManagerView: View {
  let fileServer = FileServer(
    port: 80,
    publicDirectory: RimeEngine.appGroupUserDataDirectoryURL
  )

  @State var isBoot: Bool = false

  var body: some View {
    GeometryReader { proxy in
      VStack(alignment: .center) {
        VStack(alignment: .leading) {
          Group {
            Text("1. 请在与您手机处与同一局域网内的PC浏览器上打开下面任意地址.")
            Text("")
            Group {
              Text(" - http://\(UIDevice.current.localIP() ?? "")")
              Text(" - http://\(UIDevice.current.name).local")
            }
            .padding(.leading, 20)
            Text("")
            Text("2. 将您的个人输入方案上传至文件夹内")
          }
          .font(.system(size: 18, weight: .bold, design: .rounded))
          .foregroundColor(.primary)
        }
        .padding(.top, 120)
        .padding(.leading, 10)

        Button {
          isBoot.toggle()
          if isBoot {
            fileServer.start()
          } else {
            fileServer.shutdown()
          }
        } label: {
          RoundedRectangle(cornerRadius: 15)
            .fill(Color.white)
            .frame(width: 240, height: 50)
            .padding(.horizontal)
            .shadow(radius: 2, x: 1, y: 1)
            .overlay(
              Text(!isBoot ? "启动" : "停止")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color.primary)
            )
        }
        .padding(.top, 50)

        Spacer()
      }
      .background(Color.green.opacity(0.1))
      .ignoresSafeArea()
      .frame(width: proxy.size.width, height: proxy.size.height)
      .onDisappear {
        fileServer.shutdown()
      }
    }
  }
}

extension UIDevice {
  /**
   Returns device ip address. Nil if connected via celluar.
   */
  func localIP() -> String? {
    var address: String?
    var ifaddr: UnsafeMutablePointer<ifaddrs>?

    if getifaddrs(&ifaddr) == 0 {
      var ptr = ifaddr
      while ptr != nil {
        defer { ptr = ptr?.pointee.ifa_next } // memory has been renamed to pointee in swift 3 so changed memory to pointee

        guard let interface = ptr?.pointee else {
          return nil
        }
        let addrFamily = interface.ifa_addr.pointee.sa_family
        if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
          guard let ifa_name = interface.ifa_name else {
            return nil
          }
          let name = String(cString: ifa_name)

          if name == "en0" { // String.fromCString() is deprecated in Swift 3. So use the following code inorder to get the exact IP Address.
            var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
            address = String(cString: hostname)
          }
        }
      }
      freeifaddrs(ifaddr)
    }

    return address
  }
}

struct FileManagerView_Previews: PreviewProvider {
  static var previews: some View {
    FileManagerView()
  }
}
