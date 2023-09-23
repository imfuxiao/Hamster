//
//  File.swift
//
//
//  Created by morse on 2023/7/7.
//

import Foundation

public struct FileInfo: Identifiable, Hashable {
  public let id = UUID()
  public var url: URL
  public var fileResourceType: URLFileResourceType?
  public var fileModifiedDate: Date?
}
