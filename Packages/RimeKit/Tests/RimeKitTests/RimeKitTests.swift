import XCTest

@testable import RimeKit

final class RimeKitTests: XCTestCase {
  var t9inputMap = [
    "a": 2,
    "b": 2,
    "c": 2,
    "d": 3,
    "e": 3,
    "f": 3,
    "g": 4,
    "h": 4,
    "i": 4,
    "j": 5,
    "k": 5,
    "l": 5,
    "m": 6,
    "n": 6,
    "o": 6,
    "p": 7,
    "q": 7,
    "r": 7,
    "s": 7,
    "t": 8,
    "u": 8,
    "v": 8,
    "w": 9,
    "x": 9,
    "y": 9,
    "z": 9,
  ]

  func testT9Rime() throws {
    let traits = Rime.createTraits(
      sharedSupportDir: "/Users/morse/Downloads/rime-ice-main",
      userDataDir: "/Users/morse/Downloads/rime-ice-main"
    )

    Rime.shared.start(traits, maintenance: true, fullCheck: true)

    // tang lai xiao qu
    let inputKeys = "tanglaixiaoqu"
    inputKeys.forEach {
      let inputKey = t9inputMap[String($0)]!
      let handle = Rime.shared.inputKey("\(inputKey)")
      print("self.rimeEngine inputKey \(inputKey), handle = \(handle)")
    }

    var context = Rime.shared.context()
    print(context.commitTextPreview ?? "")

    var handle = Rime.shared.selectCandidate(index: 2)
    print("self.rimeEngine selectIndex \(2), handle = \(handle)")

    context = Rime.shared.context()
    print(context.commitTextPreview ?? "")

    handle = Rime.shared.replaceInputKeys("kai", startPos: Int(context.composition.selStart + 1), count: "kai".count)
    print("self.rimeEngine change input, handle = \(handle)")

    context = Rime.shared.context()
    print(context.commitTextPreview ?? "")
  }
}
