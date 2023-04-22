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
  func onDelployStart() {
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
  var testResourcePath: URL? {
    Bundle.main.resourceURL?.appending(component: AppConstants.containerAppResourcesPath)
  }

  var sharedSupportPath: URL? {
    testResourcePath?.appending(component: AppConstants.rimeSharedSupportPathName)
  }

  var userPath: URL? {
    testResourcePath?.appending(component: AppConstants.rimeUserPathName)
  }

  let rimeEngine = RimeEngine()

  override func setUpWithError() throws {
    let traits = IRimeTraits()
    traits.sharedDataDir = sharedSupportPath?.path ?? ""
    traits.userDataDir = userPath?.path ?? ""
    traits.distributionCodeName = "Hamster"
    traits.distributionName = "仓鼠"
    traits.distributionVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
    // TODO: appName设置名字会产生异常
    // utilities.cc:365] Check failed: !IsGoogleLoggingInitialized() You called InitGoogleLogging() twice!
    // traits.appName = "rime.Hamster"

    rimeEngine.startService(traits)
    rimeEngine.setNotificationDelegate(RimeTestNotification())
  }

  override func tearDownWithError() throws {
    rimeEngine.stopService()
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
    let backColor = colorSchema!.backColor.bgrColor
    XCTAssertNotNil(backColor)
    XCTAssertEqual(backColor!.description, "#FBF6E5F0")

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
