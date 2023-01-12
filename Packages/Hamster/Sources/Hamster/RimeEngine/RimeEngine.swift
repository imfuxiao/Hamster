import Foundation
import LibrimeKit

public final class RimeEngine {
  public static let shared: RimeEngine = .init()
  
  private let rimeAPI: IRimeAPI = IRimeAPI()
  
  private init() {}
  
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
  
  public func inputKey(_ key: String) -> [String] {
    if rimeAPI.processKey(key) {
      return []
    }
    return rimeAPI.candidateList()
  }
  
  public func getInputKeys() -> String {
    return rimeAPI.getInput()
  }
  
  public func cleanComposition() {
    rimeAPI.cleanComposition()
  }
  
  // 繁体模式
  public func traditionalMode(_ value: Bool) {
    rimeAPI.simplification(value)
  }
  
  public func isSimplifiedMode() -> Bool {
    return !rimeAPI.isSimplifiedMode()
  }
  
  public func asciiMode(_ value: Bool) {
    rimeAPI.asciiMode(value)
  }
  
  public func isAsciiMode() -> Bool {
    return rimeAPI.isAsciiMode()
  }
}
