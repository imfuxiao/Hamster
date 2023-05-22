import Foundation
import LibrimeKit
import ProgressHUD
import SwiftUI

public class RimeContext: ObservableObject {
  /// 候选字上限
  var maxCandidateCount: Int = 100

  /// 用户输入键值
  @Published
  var userInputKey: String = ""

  /// 简繁中文模式
  @Published
  var simplifiedChineseMode: Bool = true

  /// 字母模式
  @Published
  var asciiMode: Bool = false

  /// 候选字
  @Published
  var suggestions: [HamsterSuggestion] = []
}

extension RimeContext {
  func reset() {
    userInputKey = ""
    suggestions = []
    Rime.shared.cleanComposition()
  }

  func candidateListLimit() -> [HamsterSuggestion] {
    let candidates = Rime.shared.getCandidate(index: 0, count: maxCandidateCount)
    var result: [HamsterSuggestion] = []
    for (index, candidate) in candidates.enumerated() {
      var suggestion = HamsterSuggestion(
        text: candidate.text
      )
      suggestion.index = index
      suggestion.comment = candidate.comment
      suggestion.isAutocomplete = index == 0
      result.append(suggestion)
    }
    return result
  }

  // 拷贝 AppGroup 下词库文件
  func copyAppGroupUserDict() throws {
    // TODO: 将AppGroup下词库文件copy至应用目录
    // 只copy用户词库文件
    let regex = ["^.*[.]userdb.*$", "^.*[.]txt$"]
    try RimeContext.copyAppGroupSharedSupportDirectoryToSandbox(regex, filterMatchBreak: false)
    try RimeContext.copyAppGroupUserDirectoryToSandbox(regex, filterMatchBreak: false)
  }

  /// 重新部署
  func redeployment(_ appSettings: HamsterAppSettings) throws {
    // 如果开启 iCloud，则先将 iCloud 下文件增量复制到 Sandbox
    if appSettings.enableAppleCloud {
      do {
        let regexList = appSettings.copyToCloudFilterRegex.split(separator: ",").map { String($0) }
        try RimeContext.copyAppleCloudSharedSupportDirectoryToSandbox(regexList)
        try RimeContext.copyAppleCloudUserDataDirectoryToSandbox(regexList)
      } catch {
        Logger.shared.log.error("RIME redeploy error \(error.localizedDescription)")
        throw error
      }
    }

    // 重新部署
    Rime.shared.shutdown()
    Rime.shared.start(Rime.createTraits(
      sharedSupportDir: RimeContext.sandboxSharedSupportDirectory.path,
      userDataDir: RimeContext.sandboxUserDataDirectory.path
    ), maintenance: true, fullCheck: true)
//    Logger.shared.log.debug("rimeEngine deploy handled \(deployHandled)")

    // 将 Sandbox 目录下方案复制到AppGroup下
    try RimeContext.syncSandboxSharedSupportDirectoryToApGroup(override: true)
    try RimeContext.syncSandboxUserDataDirectoryToApGroup(override: true)
  }

  /// RIME同步
  func syncRime() throws -> Bool {
    Rime.shared.shutdown()
    Rime.shared.start(Rime.createTraits(
      sharedSupportDir: RimeContext.sandboxSharedSupportDirectory.path,
      userDataDir: RimeContext.sandboxUserDataDirectory.path
    ), maintenance: true, fullCheck: true)
    let handled = Rime.shared.API().syncUserData()
    Rime.shared.shutdown()
    return handled
  }
}
