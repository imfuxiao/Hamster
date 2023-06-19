//
//  HamsterAppSettings.swift
//  HamsterTests
//
//  Created by morse on 7/5/2023.
//

import XCTest
import Yams

@testable import Hamster

final class HamsterAppSettingsTest: XCTestCase {
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testAppSettingToYaml() throws {
    let settings = HamsterAppSettings()
    let yaml = settings.yaml()
    Logger.shared.log.debug("yaml:\n" + yaml)
    if let node = try Yams.compose(yaml: yaml) {
      settings.reset(node: node)
    }
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
