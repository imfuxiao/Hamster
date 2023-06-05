//
//  String+.swift
//
//
//  Created by morse on 2023/8/7.
//
import XCTest

@testable import HamsterKeyboardKit

final class StringExtensionTests: XCTestCase {
  func testIsCapitalized() throws {
    XCTAssertTrue("Abc".isCapitalized)
    XCTAssertFalse("abc".isCapitalized)
  }
}
