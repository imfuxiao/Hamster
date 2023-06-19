//
//  Yaml.swift
//  HamsterTests
//
//  Created by morse on 2023/6/19.
//

import XCTest
import Yams

@testable import Hamster

final class YamlToModelTest: XCTestCase {
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testModelToYaml() {
    let settingModel = HamsterSettingModel(
      appSettings: AppSettingsModel(
        isFirstLaunch: true,
        showKeyPressBubble: true
      ),
      keyboardSettings: KeyboardSettingsModel(
        enableSymbolKeyboard: false,
        keys: ["a", "b", "c", "d"]
      )
    )
    let encoder = YAMLEncoder()
    let encodedYAML = try? encoder.encode(settingModel)
    XCTAssertNotNil(encoder)
    Logger.shared.log.debug("encode yaml: \n\(encodedYAML ?? "")")

    let decoder = YAMLDecoder()
    let decodedSettingModel = try? decoder.decode(HamsterSettingModel.self, from: encodedYAML!)
    XCTAssertNotNil(decodedSettingModel)
    Logger.shared.log.debug("decoder model : \(decodedSettingModel!)")
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
