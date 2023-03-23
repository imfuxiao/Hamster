//
//  Plist.swift
//  HamsterApp
//
//  Created by morse on 2023/3/23.
//

import Foundation
import Plist

extension Plist {
  var strDict: [String: String] {
    var extend: [String: String] = [:]
    if let dict = dict {
      for (key, value) in dict {
        if let value = value as? String {
          extend[(key as! String).lowercased()] = value
        }
      }
    }
    return extend
  }

  static var defaultAction: [String: String] {
    if let defaultActionURL = Bundle.main.url(forResource: "DefaultAction", withExtension: "plist") {
      let plist = Plist(path: defaultActionURL)
      switch plist {
      case .dictionary:
        return plist.strDict
      default:
        break
      }
    }
    return [:]
  }
}
