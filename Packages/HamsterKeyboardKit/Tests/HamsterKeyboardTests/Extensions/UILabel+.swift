//
//  UILabel+.swift
//
//
//  Created by morse on 2023/10/26.
//

import XCTest

@testable import HamsterKeyboardKit

final class UILabel_: XCTestCase {
  override func setUpWithError() throws {
    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testFontSizeMapping() throws {
    let targetSize = CGSize(width: 100, height: 100)

    for fontSize in 10 ... 30 {
      let font = UIFont.systemFont(ofSize: CGFloat(fontSize))
      let size = UILabel.estimatedSize("🉐", targetSize: targetSize, font: font)
      print("🉐 \(fontSize) font size: \(size), fontPointSize: \(font.pointSize)")
    }
    var size = UILabel.estimatedSize("得", targetSize: targetSize, font: UIFont.systemFont(ofSize: 20))
    print("得 size: \(size)")

    size = UILabel.estimatedSize("·", targetSize: targetSize, font: UIFont.systemFont(ofSize: 20))
    print("· size: \(size)")

    size = UILabel.estimatedSize("♀", targetSize: targetSize, font: UIFont.systemFont(ofSize: 20))
    print("♀ size: \(size)")

    print("🉐".count)
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
