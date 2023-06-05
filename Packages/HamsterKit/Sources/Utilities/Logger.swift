//
//  Logger.swift
//  Hamster
//
//  Created by morse on 2/8/2023.
//

import OSLog

public extension Logger {
  private static var subsystem = Bundle.main.bundleIdentifier!

  static let statistics = Logger(subsystem: subsystem, category: "statistics")
}
