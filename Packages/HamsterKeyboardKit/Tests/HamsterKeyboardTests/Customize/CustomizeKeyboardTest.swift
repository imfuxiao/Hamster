//
//  CustomizeKeyboard.swift
//
//
//  Created by morse on 2023/9/1.
//

@testable import HamsterKeyboardKit

import Foundation
import XCTest
import Yams
// import ZippyJSON

final class CustomizeKeyboardTest: XCTestCase {
  let tempYamlPath = FileManager.default.temporaryDirectory.appendingPathComponent("test.yaml")
  let testYamlPath = FileManager.default.temporaryDirectory.appendingPathComponent("testHamster.yaml")
  let testJSONPath = FileManager.default.temporaryDirectory.appendingPathComponent("testHamster.json")
  let testPlistPath = FileManager.default.temporaryDirectory.appendingPathComponent("testHamster.plist")

  override func setUpWithError() throws {
    try? FileManager.default.removeItem(at: tempYamlPath)
    try? FileManager.default.removeItem(at: testYamlPath)
    try? FileManager.default.removeItem(at: testJSONPath)
    try? FileManager.default.removeItem(at: testPlistPath)

    if let data: Data = HamsterConfiguration.sampleString.data(using: .utf8) {
      FileManager.default.createFile(atPath: tempYamlPath.path, contents: data)
    }

    let configuration = try HamsterConfigurationRepositories.shared.loadFromYAML(tempYamlPath)
    try HamsterConfigurationRepositories.shared.saveToYAML(config: configuration, path: testYamlPath)
    try HamsterConfigurationRepositories.shared.saveToJSON(config: configuration, path: testJSONPath)
    try HamsterConfigurationRepositories.shared.saveToPropertyList(config: configuration, path: testPlistPath)
  }

  override func tearDownWithError() throws {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func testLoadKeyboardByYaml() throws {
    let tempYamlPath = FileManager.default.temporaryDirectory.appendingPathComponent(Self.fileName)
    FileManager.default.createFile(atPath: tempYamlPath.path, contents: Self.previewYaml.data(using: .utf8))
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(Self.fileName)
    let data = try Data(contentsOf: url)
    let keyboards = try YAMLDecoder().decode(Keyboards.self, from: data)
    print(keyboards)
  }

  func testEncoder() throws {
    let tempYamlPath = FileManager.default.temporaryDirectory.appendingPathComponent(Self.fileName)
    FileManager.default.createFile(atPath: tempYamlPath.path, contents: Self.previewYaml.data(using: .utf8))
    let url = FileManager.default.temporaryDirectory.appendingPathComponent(Self.fileName)
    var data = try Data(contentsOf: url)
    let keyboards = try YAMLDecoder().decode(Keyboards.self, from: data)

    data = try PropertyListEncoder().encode(keyboards)
    let otherKeyboards = try JSONDecoder().decode(Keyboards.self, from: data)

    XCTAssertEqual(keyboards, otherKeyboards)
  }

  func testAttributeParse() throws {
    var result = "chinese(26)".attributeParse()
    XCTAssertNotNil(result)
    XCTAssertEqual("chinese", result?.0)
    XCTAssertEqual("26", result?.1)

    result = "chinese()".attributeParse()
    XCTAssertNotNil(result)
    XCTAssertEqual("chinese", result?.0)
    XCTAssertEqual("", result?.1)

    result = "keyboardType(chinese(name))".attributeParse()
    XCTAssertNotNil(result)
    XCTAssertEqual("keyboardType", result?.0)
    XCTAssertEqual("chinese(name)", result?.1)

    XCTAssertNil("chinese(".attributeParse())
    XCTAssertNil("chinese)".attributeParse())
  }

  func testPerformanceDecodeYaml() throws {
    self.measure {
      do {
        let _ = try HamsterConfigurationRepositories.shared.loadFromYAML(testYamlPath)
      } catch {
        fatalError(error.localizedDescription)
      }
    }
  }

  func testPerformanceDecodeJSON() throws {
    self.measure {
      do {
        let data = try Data(contentsOf: testJSONPath)
        let _ = try JSONDecoder().decode(HamsterConfiguration.self, from: data)
      } catch {
        fatalError(error.localizedDescription)
      }
    }
  }

  func testPerformanceDecodePlist() throws {
    self.measure {
      do {
        let data = try Data(contentsOf: testPlistPath)
        let _ = try PropertyListDecoder().decode(HamsterConfiguration.self, from: data)
      } catch {
        fatalError(error.localizedDescription)
      }
    }
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}

extension CustomizeKeyboardTest {
  static let fileName = "keyboard.yaml"
  static let previewYaml =
    """
    # 键盘布局
    # 注意：文件编码格式必须为 UTF-8
    #
    # action 按键操作：
    # 必须值
    # backspace: 删除键
    # character(value): 文本字符按键, value 是对应的输入文本
    # characterMargin(value): 空白占位字符，不显示(所以会忽略 label)，但点击会输出里面定义的 value, 如 A键 L键两侧.
    #                         注意： characterMargin 类型的宽度固定为 available
    # keyboardType(KeyboardType): 键盘切换键，里面的 KeyboardType 包含 alphabetic/numeric/symbolic/chinese(name) 三种类型
    # return: 回车键
    # shift：shift键, 默认为小写
    # space: 空格键
    #
    # width 宽度类型
    # 可选值，默认值为 input
    # 已当前屏幕宽度的 1/10 为单位，去定义每个按键的宽度。
    # 注意： 宽度值中包含了每个按键的边距，这个边距值是固定的，不可以自定义。
    # input: 表示 1/10 个单位
    # inputPercentage(value): 表示 input 类型的百分比。例如：0.1表示 input 值的 1 / 10, 2 表示 input 类型值的 2 倍宽度
    # percentage(value): 当前屏幕宽度的百分比。例如 0.2 当前屏幕宽度的 1/5.
    # points(value): 固定宽度。例如 50 表示 50 个 point
    # available: 同行中剩余未分配宽度，如果有多个按键为此属性，则会平均分配。
    #
    # label 按键显示文本，character 类型如果不设置 label 则默认显示 character 中的 String 值
    # 注意：characterMargin 会忽略
    #
    # processByRIME: 是否经过 rime 处理。
    # 默认的 character(value) 中的 String 会经过 rime 处理，如果不希望通过 rime 引擎，则改为 false。
    #
    # display: BOOL 是否显示, 默认值为 true。

    keyboards:
      - type: custom(26)
        name: "中文26键"
        rows:
          - keys:
              - action: character(q)
                label: "Q"
                swipe:
                  - direction: up
                    action: character(1)
                    display: true
                  - direction: down
                    action: character(~)
                    processByRIME: true
              - action: character(w)
                label: "W"
                swipe:
                  - direction: up
                    action: character(2)
                  - direction: down
                    action: character(@)
              - action: character(e)
                label: "E"
                swipe:
                  - direction: up
                    action: character(3)
                  - direction: down
                    action: character(#)
              - action: character(r)
                width: input
                label: "R"
                swipe:
                  - direction: up
                    action: character(4)
                  - direction: down
                    action: character($)
              - action: character(t)
                label: "T"
                swipe:
                  - direction: up
                    action: character(5)
                  - direction: down
                    action: character(%)
              - action: character(y)
                width: input
                label: "Y"
                swipe:
                  - direction: up
                    action: character(6)
                  - direction: down
                    action: character(^)
              - action: character(u)
                label: "U"
                swipe:
                  - direction: up
                    action: character(7)
                  - direction: down
                    action: character(&)
              - action: character(i)
                label: "I"
                swipe:
                  - direction: up
                    action: character(8)
                  - direction: down
                    action: character(*)
              - action: character(o)
                label: "O"
                swipe:
                  - direction: up
                    action: character(9)
                  - direction: down
                    action: character(()
              - action: character(p)
                label: "P"
                swipe:
                  - direction: up
                    action: character(0)
                  - direction: down
                    action: character())
          - keys:
              - action: characterMargin(a)
              - action: character(a)
                label: "A"
                swipe:
                  - direction: up
                    action: character(1)
                  - direction: down
                    action: character(~)
              - action: character(s)
                label: "S"
              - action: character(d)
                label: "D"
              - action: character(f)
                label: "F"
              - action: character(g)
                label: "G"
              - action: character(h)
                label: "H"
              - action: character(j)
                label: "J"
              - action: character(k)
                label: "K"
              - action: character(l)
                label: "L"
              - action: characterMargin(l)
          - keys:
              - action: shift
                width: percentage(0.13)
              - action: characterMargin(z)
              - action: character(z)
                label: "Z"
              - action: character(x)
                label: "X"
              - action: character(c)
                label: "C"
              - action: character(v)
                label: "V"
              - action: character(b)
                label: "B"
              - action: character(n)
                label: "n"
              - action: character(m)
                label: "M"
              - action: characterMargin(m)
              - action: backspace
                width: percentage(0.13)
          - keys:
              - action: keyboardType(numeric)
                label: "123"
                width:
                  portrait: percentage(0.25)
                  landscape: percentage(0.195)
              - action: space
                label:
                  loadingText: "仓输入法"
                  text: "空格"
                width: available
              - action: keyboardType(alphabetic)
                width: input
                label: "英"
              - action: return
                width:
                  portrait: percentage(0.25)
                  landscape: percentage(0.195)


    """
}
