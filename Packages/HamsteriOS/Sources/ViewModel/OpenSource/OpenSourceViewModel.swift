//
//  OpenSourceViewModel.swift
//
//
//  Created by morse on 2023/7/7.
//

import Foundation

class OpenSourceViewModel {
  let openSourceList: [OpenSourceInfo] = [
    .init(name: "librime", projectURL: "https://github.com/rime/librime"),
    .init(name: "KeyboardKit", projectURL: "https://github.com/KeyboardKit/KeyboardKit"),
    .init(name: "Runestone", projectURL: "https://github.com/simonbs/Runestone"),
    .init(name: "TreeSitterLanguages", projectURL: "https://github.com/simonbs/TreeSitterLanguages"),
    .init(name: "ProgressHUD", projectURL: "https://github.com/relatedcode/ProgressHUD"),
    .init(name: "ZIPFoundation", projectURL: "https://github.com/weichsel/ZIPFoundation"),
    .init(name: "Yams", projectURL: "https://github.com/jpsim/Yams"),
    // .init(name: "ZippyJSON", projectURL: "https://github.com/michaeleisel/ZippyJSON"),
    .init(name: "GCDWebServer", projectURL: "https://github.com/swisspol/GCDWebServer"),
  ]
}
