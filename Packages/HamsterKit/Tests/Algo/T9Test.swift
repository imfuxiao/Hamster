//
//  T9Test.swift
//
//
//  Created by morse on 2023/9/8.
//

@testable import HamsterKit
import XCTest

final class T9Test: XCTestCase {
  static let allPinyin = ["a", "ai", "an", "ang", "ao", "ba", "bai", "ban", "bang", "bao", "bei", "ben", "beng", "bi", "bian", "biao", "bie", "bin", "bing", "bo", "bu",
                          "ca", "cai", "can", "cang", "cao", "ce", "cen", "ceng", "cha", "chai", "chan", "chang", "chao", "che", "chen", "cheng", "chi", "chong", "chou", "chu", "chua", "chuai", "chuan", "chuang", "chui", "chun", "chuo", "ci", "cong", "cou", "cu", "cuan", "cui", "cun", "cuo", "da", "dai", "dan", "dang", "dao", "de", "dei", "den", "deng", "di", "dia", "dian", "diao", "die", "ding", "diu", "dong", "dou", "du", "duan", "dui", "dun", "duo", "e", "ei", "en", "eng", "er", "fa", "fan", "fang", "fei", "fen", "feng", "fo", "fou", "fu",
                          "ga", "gai", "gan", "gang", "gao", "ge", "gei", "gen", "geng", "gong", "gou", "gu", "gua", "guai", "guan", "guang", "gui", "gun", "guo", "ha", "hai", "han", "hang", "hao", "he", "hei", "hen", "heng", "hm", "hong", "hou", "hu", "hua", "huai", "huan", "huang", "hui", "hun", "huo",
                          "ji", "jia", "jian", "jiang", "jiao", "jie", "jin", "jing", "jiong", "jiu", "ju", "juan", "jue", "jun", "ka", "kai", "kan", "kang", "kao", "ke", "kei", "ken", "keng", "kong", "kou", "ku", "kua", "kuai", "kuan", "kuang", "kui", "kun", "kuo",
                          "la", "lai", "lan", "lang", "lao", "le", "lei", "leng", "li", "lia", "lian", "liang", "liao", "lie", "lin", "ling", "liu", "lo", "long", "lou", "lu", "lv", "luan", "lve", "lun", "luo", "m", "ma", "mai", "man", "mang", "mao", "me", "mei", "men", "meng", "mi", "mian", "miao", "mie", "min", "ming", "miu", "mo", "mou", "mu",
                          "na", "nai", "nan", "nang", "nao", "ne", "nei", "nen", "neng", "ni", "nia", "nian", "niang", "niao", "nie", "nin", "ning", "niu", "nong", "nou", "nu", "nv", "nuan", "nve", "nuo", "o", "ou",
                          "pa", "pai", "pan", "pang", "pao", "pei", "pen", "peng", "pi", "pian", "piao", "pie", "pin", "ping", "po", "pou", "pu", "qi", "qia", "qian", "qiang", "qiao", "qie", "qin", "qing", "qiong", "qiu", "qu", "quan", "que", "qun",
                          "ran", "rang", "rao", "re", "ren", "reng", "ri", "rong", "rou", "ru", "ruan", "rui", "run", "ruo", "sa", "sai", "san", "sang", "sao", "se", "sen", "seng", "sha", "shai", "shan", "shang", "shao", "she", "shei", "shen", "sheng", "shi", "shou", "shu", "shua", "shuai", "shuan", "shuang", "shui", "shun", "shuo", "si", "song", "sou", "su", "suan", "sui", "sun", "suo",
                          "ta", "tai", "tan", "tang", "tao", "te", "teng", "ti", "tian", "tiao", "tie", "ting", "tong", "tou", "tu", "tuan", "tui", "tun", "tuo", "wa", "wai", "wan", "wang", "wei", "wen", "weng", "wo", "wu",
                          "xi", "xia", "xian", "xiang", "xiao", "xie", "xin", "xing", "xiong", "xiu", "xu", "xuan", "xue", "xun", "ya", "yan", "yang", "yao", "ye", "yi", "yin", "ying", "yo", "yong", "you", "yu", "yuan", "yue", "yun",
                          "za", "zai", "zan", "zang", "zao", "ze", "zei", "zen", "zeng", "zha", "zhai", "zhan", "zhang", "zhao", "zhe", "zhei", "zhen", "zheng", "zhi", "zhong", "zhou", "zhu", "zhua", "zhuai", "zhuan", "zhuang", "zhui", "zhun", "zhuo", "zi", "zong", "zou", "zu", "zuan", "zui", "zun", "zuo"]

  static let t9Map = [
    "a": "2",
    "b": "2",
    "c": "2",
    "d": "3",
    "e": "3",
    "f": "3",
    "g": "4",
    "h": "4",
    "i": "4",
    "j": "5",
    "k": "5",
    "l": "5",
    "m": "6",
    "n": "6",
    "o": "6",
    "p": "7",
    "q": "7",
    "r": "7",
    "s": "7",
    "t": "8",
    "u": "8",
    "v": "8",
    "w": "9",
    "x": "9",
    "y": "9",
    "z": "9",
  ]

  override func setUpWithError() throws {}

  override func tearDownWithError() throws {}

  func testT9Mapping() throws {
    let t9Mapping = Self.allPinyin
      .map { pinyin in (pinyin, pinyin.map { Self.t9Map[String($0)]! }.reduce("", +)) }
      .reduce(into: [String: [String]]()) {
        if let value = $0[$1.1] {
          $0[$1.1] = value + [$1.0]
        } else {
          $0[$1.1] = [$1.0]
        }
      }
    let keys = t9Mapping.keys.sorted()
    print("[")
    for key in keys {
      print("\"\(key)\": \(t9Mapping[key]!),")
    }
    print("]")
  }

  func testPinyinToT9Mapping() {
    let t9mapping = Self.allPinyin
      .map { pinyin in
        let t9 = pinyin
          .map { Self.t9Map[String($0)] ?? "" }
          .reduce("") { $0 + $1 }
        return (pinyin, t9)
      }
      .reduce(into: [String: String]()) {
        $0[$1.0] = $1.1
      }

    let keys = t9mapping.keys.sorted()
    print("[")
    for key in keys {
      print("\"\(key)\": \"\(t9mapping[key]!)\",")
    }
    print("]")
  }

  func testGetMaxLength() throws {
    if let maxString = Self.allPinyin.max(by: { $1.count > $0.count }) {
      print("maxString: \(maxString)")
    }
  }

  func testT9ToPinyin() throws {
    XCTAssertEqual("7436444".replaceT9pinyin, "pgdmggg")
  }

  func testT9Input() throws {
    var prefixKeys = t9PinyinTrie.collections(startingWith: "J")
    print(prefixKeys)
    prefixKeys = t9PinyinTrie.collections(startingWith: "JG")
    print(prefixKeys)
  }

  func testExample() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    // Any test you write for XCTest can be annotated as throws and async.
    // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
    // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
  }

  func testPerformanceExample() throws {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
}
