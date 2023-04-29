//
//  FileTest.swift
//  HamsterAppTests
//
//  Created by morse on 28/4/2023.
//

import XCTest

@testable import HamsterApp

final class FileTest: XCTestCase {
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testGetSchemaIds() throws {
    let fm = FileManager.default
    let urls = fm.getSchemesFile(for: RimeEngine.appGroupSharedSupportDirectoryURL)
    XCTAssertTrue(!urls.isEmpty)
    let schemaIds = fm.getSchemaIds(urls)
    XCTAssertTrue(!schemaIds.isEmpty)
    Logger.shared.log.info("schemaIds = \(schemaIds)")
  }

  func testPatch() throws {
    let fm = FileManager.default
    let patchContent = fm.patchOfSchemaList(["1", "2"])
    XCTAssertNotNil(patchContent)
    Logger.shared.log.info("patchContent:\n \(patchContent ?? "")")
  }

  func testMergePatch() throws {
    let fm = FileManager.default
    let patchContent = fm.mergePatchSchemaList(RimeEngine.appGroupUserDataDefaultCustomYaml, schemaIds: ["xkjd6"])
    XCTAssertNotNil(patchContent)
    Logger.shared.log.info("patchContent:\n \(patchContent ?? "")")
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
