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
  }

  func testStringComponents() throws {
    XCTAssertEqual("ni'h", "MGG".t9ToPinyin(comment: "ni hao"))
    XCTAssertEqual("ni'h", "MG G".t9ToPinyin(comment: "ni hao"))
    XCTAssertEqual("ni'hao", "MG GAM".t9ToPinyin(comment: "ni hao"))
    XCTAssertEqual("ni", "MG".t9ToPinyin(comment: "ni"))
    XCTAssertEqual("n", "M".t9ToPinyin(comment: "ni"))
    XCTAssertEqual("jin't", "JGMT".t9ToPinyin(comment: "jin tian"))
    XCTAssertEqual("ji'go", "JGMT".t9ToPinyin(comment: "ji gou"))
  }
}
