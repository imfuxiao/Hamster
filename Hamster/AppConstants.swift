import Foundation

enum AppConstants {
  // AppGroup ID
  static let appGroupName = "group.dev.fuxiao.app.Hamster"

  // 与Squirrel.app保持一致
  // 预先构建的数据目录中
  static let rimeSharedSupportPathName = "SharedSupport"
  static let rimeUserPathName = "Rime"

  // 注意: 此值需要与info.plist中的参数保持一致
  static let appURL = "hamster://dev.fuxiao.app.hamster"

  // 应用日志文件URL
  static let logFileURL = FileManager.default
    .containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupName)!
    .appendingPathComponent("HamsterApp.log")
}
