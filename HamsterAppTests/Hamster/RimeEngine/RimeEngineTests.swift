//
//  RimeEngineTests.swift
//  HamsterAppTests
//
//  Created by morse on 20/2/2023.
//

import LibrimeKit
import XCTest

@testable import HamsterApp

class RimeTestNotification: IRimeNotificationDelegate {
  func onDeployStart() {
    print("HamsterRimeNotification: onDelployStart")
  }

  func onDeploySuccess() {
    print("HamsterRimeNotification: onDeploySuccess")
  }

  func onDeployFailure() {
    print("HamsterRimeNotification: onDeployFailure")
  }

  func onChangeMode(_ mode: String) {
    print("HamsterRimeNotification: onChangeMode, mode: ", mode)
  }

  func onLoadingSchema(_ schema: String) {
    print("HamsterRimeNotification: onLoadingSchema, schema: ", schema)
  }
}

final class RimeEngineTests: XCTestCase {
  let rimeEngine = RimeEngine()
  let appSettings = HamsterAppSettings()

  override func setUpWithError() throws {
//    rimeEngine.setupRime()
//    rimeEngine.startRime(nil, fullCheck: false)
    rimeEngine.initialize()
  }

  override func tearDownWithError() throws {
    rimeEngine.shutdownRime()
  }

  func testInputCharactor() throws {
    XCTAssertTrue(rimeEngine.inputKey("w"))
    print(rimeEngine.candidateList())
  }

  func testColorSchema() throws {
    let schemaList = rimeEngine.colorSchema(appSettings.rimeUseSquirrelSettings)
    XCTAssertTrue(!schemaList.isEmpty)

    let colorSchema = schemaList.first(where: { $0.schemaName == "solarized_light" })
    XCTAssertNotNil(colorSchema)

    print(colorSchema!)
    let backColor = colorSchema!.backColor
    XCTAssertNotNil(backColor)
    XCTAssertEqual(backColor.bgrColor!.description, "#FBF6E5F0")

    let currentSchemaName = rimeEngine.currentColorSchemaName(appSettings.rimeUseSquirrelSettings)
    XCTAssertEqual(currentSchemaName, "metro")
  }

  //  func testPerformanceExample() throws {
  //    // This is an example of a performance test case.
  //    measure {
  //      // Put the code you want to measure the time of here.
  //    }
  //  }
}
