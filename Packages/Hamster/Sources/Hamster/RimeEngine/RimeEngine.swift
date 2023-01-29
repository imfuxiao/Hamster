import Foundation
import LibrimeKit

public struct Candidate {
  let text: String
  let comment: String
}

public class RimeEngine: ObservableObject {
  @Published var inputKey: String = ""
  @Published var candidates: [Candidate] = []
  @Published var isAlphabet: Bool = false // true: 英文字母模式, false: 中文处理
  
  public static let shared: RimeEngine = .init()
  
  private let rimeAPI: IRimeAPI = .init()
  
  public func setNotificationDelegate(_ delegate: IRimeNotificationDelegate) {
    rimeAPI.setNotificationDelegate(delegate)
  }
  
  public func startService(_ traits: IRimeTraits) {
    if rimeAPI.isAlive() {
      return
    }
    rimeAPI.startRimeServer(traits)
  }
  
  public func stopService() {
    rimeAPI.shutdown()
  }
  
  public func inputKey(_ key: String) -> Bool {
    return rimeAPI.processKey(key)
  }
  
  public func inputKey(_ key: Int32) -> Bool {
    return rimeAPI.processKeyCode(key)
  }
  
  public func candidateList() -> [Candidate] {
    let candidates = rimeAPI.getCandidateList()
    if candidates != nil {
      return candidates!.map {
        Candidate(text: $0.text, comment: $0.comment)
      }
    }
    return []
  }
  
  public func candidateListWithIndex(index: Int, andCount count: Int) -> [Candidate] {
    let candidates = rimeAPI.getCandidateWith(Int32(index), andCount: Int32(count))
    if candidates != nil {
      return candidates!.map {
        Candidate(text: $0.text, comment: $0.comment)
      }
    }
    return []
  }
  
  public func getInputKeys() -> String {
    return rimeAPI.getInput()
  }
  
  public func getCommitText() -> String {
    return rimeAPI.getCommit()!
  }
  
  public func cleanAll() {
    inputKey = ""
    candidates = []
    cleanComposition()
  }
  
  public func cleanComposition() {
    rimeAPI.cleanComposition()
  }
  
  public func status() -> IRimeStatus {
    return rimeAPI.getStatus()
  }
  
  public func context() -> IRimeContext {
    return rimeAPI.getContext()
  }
  
  // 繁体模式
  public func traditionalMode(_ value: Bool) {
    rimeAPI.simplification(value)
  }
  
  public func isSimplifiedMode() -> Bool {
    return !rimeAPI.isSimplifiedMode()
  }
  
  // 字母模式
  public func asciiMode(_ value: Bool) {
    rimeAPI.asciiMode(value)
  }
  
  public func isAsciiMode() -> Bool {
    return rimeAPI.isAsciiMode()
  }
}

extension IRimeContext {
  func getCandidates() -> [Candidate] {
    candidates.map {
      Candidate(text: $0.text, comment: $0.comment)
    }
  }
}
