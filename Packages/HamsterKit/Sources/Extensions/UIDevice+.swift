//
//  File.swift
//
//
//  Created by morse on 2023/7/4.
//

import UIKit

/// 获取IP
/// - 解决方案：https://stackoverflow.com/questions/30748480/swift-get-devices-wifi-ip-address/30754194#30754194
public extension UIDevice {
  enum Network: String {
    case wifi = "en0"
    case cellular = "pdp_ip0"
    // ... case ipv4 = "ipv4"
    // ... case ipv6 = "ipv6"
  }

  func getAddress(for network: Network = .wifi) -> String? {
    var address: String?

    // Get list of all interfaces on the local machine:
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    guard let firstAddr = ifaddr else { return nil }

    // For each interface ...
    for ifptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
      let interface = ifptr.pointee

      // Check for IPv4 or IPv6 interface:
      let addrFamily = interface.ifa_addr.pointee.sa_family
      // if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
      // 只需要 ipv4
      if addrFamily == UInt8(AF_INET) {
        // wifi = ["en0"]
        // wired = ["en2", "en3", "en4"]
        // cellular = ["pdp_ip0","pdp_ip1","pdp_ip2","pdp_ip3"]

        // Check interface name:
        let name = String(cString: interface.ifa_name)
        if name == network.rawValue {
          // Convert interface address to a human readable string:
          var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
          getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                      &hostname, socklen_t(hostname.count),
                      nil, socklen_t(0), NI_NUMERICHOST)
          address = String(cString: hostname)
        }
      }
    }
    freeifaddrs(ifaddr)
    return address
  }
}
