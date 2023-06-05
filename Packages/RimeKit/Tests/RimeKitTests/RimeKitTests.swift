import XCTest

@testable import RimeKit

final class RimeKitTests: XCTestCase {
  func testPCRime() throws {
    Rime.shared.start(Rime.createTraits(
      sharedSupportDir: "/Users/morse/Downloads/Squirrel",
      userDataDir: "/Users/morse/Downloads/temp"
    ))
    let handle = Rime.shared.setSchema("cangjie5")
    print("self.rimeEngine set schema: cangjie5, handle = \(handle)")
  }
}
