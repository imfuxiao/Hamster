//
//  StanderKeyboardAppearance.swift
//
//
//  Created by morse on 2023/11/2.
//

import XCTest

@testable import HamsterKeyboardKit

final class StanderKeyboardAppearanceTest: XCTestCase {
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testExample() throws {
    let appearance = StandardKeyboardAppearance(keyboardContext: .preview)
    var key = Key(action: .symbol(Symbol(char: "http")))
    var fontSize = appearance.buttonFontSize(for: key)
    var fontWeight = appearance.buttonFontWeight(for: key)
    print("\(key.labelText) fontSize: \(fontSize), fontWeight: \(String(describing: fontWeight))")

    key = Key(action: .symbol(Symbol(char: ".com")))
    fontSize = appearance.buttonFontSize(for: key)
    fontWeight = appearance.buttonFontWeight(for: key)
    print("\(key.labelText) fontSize: \(fontSize), fontWeight: \(String(describing: fontWeight))")

    key = Key(action: .character("/"))
    fontSize = appearance.buttonFontSize(for: key)
    fontWeight = appearance.buttonFontWeight(for: key)
    print("\(key.labelText) fontSize: \(fontSize), fontWeight: \(String(describing: fontWeight))")
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
