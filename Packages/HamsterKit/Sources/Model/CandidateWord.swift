//
//  File.swift
//
//
//  Created by morse on 2023/7/4.
//

import Foundation

/// 候选字
public struct CandidateWord {
  public var text: String
  public var comment: String

  public init(text: String, comment: String) {
    self.text = text
    self.comment = comment
  }
}
