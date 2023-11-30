//
//  StringTest.swift
//
//
//  Created by morse on 2023/7/4.
//

@testable import HamsterKit

import XCTest

final class StringTest: XCTestCase {
  func testRegex() throws {
    let simpleDigits = "[0-9]+"
    XCTAssertTrue("123".isMatch(regex: simpleDigits))
    XCTAssertFalse("abc".isMatch(regex: simpleDigits))

    let fileName = "^.*[.]userdb$"
    let target = "Rime/extended.userdb"
    let target2 = "Rime/user.yaml"
    let target3 = "Rimeuserdb"
    XCTAssertTrue(target.isMatch(regex: fileName))
    XCTAssertFalse(target2.isMatch(regex: fileName))
    XCTAssertFalse(target3.isMatch(regex: fileName))
    XCTAssertTrue("mi".isMatch(regex: "\\w.*"))
  }

  func testContainsChineseCharacters() throws {
    XCTAssertTrue("x你".containsChineseCharacters)
    XCTAssertTrue("你x".containsChineseCharacters)
    XCTAssertTrue("你".containsChineseCharacters)
    XCTAssertFalse("x".containsChineseCharacters)
  }
}
