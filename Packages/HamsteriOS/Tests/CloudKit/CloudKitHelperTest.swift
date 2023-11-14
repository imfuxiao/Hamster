//
//  CloudKitHelperTest.swift
//
//
//  Created by morse on 2023/11/11.
//

import XCTest

@testable import HamsteriOS

final class CloudKitHelperTest: XCTestCase {
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testInputSchemeList() async throws {
    try await CloudKitHelper.shared.inputSchemeList()
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
