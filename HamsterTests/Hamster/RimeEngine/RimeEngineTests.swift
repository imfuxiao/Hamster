//
//  RimeEngineTests.swift
//  HamsterAppTests
//
//  Created by morse on 20/2/2023.
//

import LibrimeKit
import XCTest

@testable import Hamster

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
  override func setUpWithError() throws {
    Rime.shared.start()
  }

  override func tearDownWithError() throws {
    Rime.shared.shutdown()
  }

  func testInputCharactor() throws {
    XCTAssertTrue(Rime.shared.inputKey("w"))
    print(Rime.shared.candidateList())
  }

  func testCustomSetting() throws {
    let handled = Rime.shared.customString(key: "switcher/hotkeys", value: "F4")
    print("setting: \(handled)")
    let hotKeys = Rime.shared.getHotkeys()
    print("hotKeys: \(hotKeys)")
  }

  func testColorSchema() throws {
    let appSettings = HamsterAppSettings()
    let schemaList = Rime.shared.colorSchema(appSettings.rimeUseSquirrelSettings)
    XCTAssertTrue(!schemaList.isEmpty)

    let colorSchema = schemaList.first(where: { $0.schemaName == "solarized_light" })
    XCTAssertNotNil(colorSchema)

    print(colorSchema!)
    let backColor = colorSchema!.backColor
    XCTAssertNotNil(backColor)
    XCTAssertEqual(backColor.bgrColor!.description, "#FBF6E5F0")

    let currentSchemaName = Rime.shared.currentColorSchemaName(appSettings.rimeUseSquirrelSettings)
    XCTAssertEqual(currentSchemaName, "metro")
  }

  //  func testPerformanceExample() throws {
  //    // This is an example of a performance test case.
  //    measure {
  //      // Put the code you want to measure the time of here.
  //    }
  //  }
}
