//
//  File.swift
//
//
//  Created by morse on 2023/7/8.
//

import Foundation

public struct ErrorMessage: Identifiable {
  public let id: UUID
  public var title: String
  public var message: String

  public init(title: String, message: String) {
    self.id = UUID()
    self.title = title
    self.message = message
  }
}

extension ErrorMessage: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.id == rhs.id
  }
}
