//
//  CGFloat+.swift
//
//
//  Created by morse on 2023/8/14.
//

@testable import HamsterKeyboardKit
import XCTest

final class CGFloatTest: XCTestCase {
  func testRounded() throws {
    print(CGFloat.rounded(CGFloat(702) / CGFloat(10)))
    print(CGFloat.rounded(CGFloat(304) / CGFloat(9)))
    print(CGFloat.rounded(CGFloat(304) / CGFloat(9)))
    print(CGFloat.rounded(CGFloat(304) / CGFloat(9)).rounded(.down))
    print(CGFloat.rounded(CGFloat(12.9999)))
  }
}
