// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  /// 禁用
  public static let disabledLabel = L10n.tr("Localizable", "disabledLabel", fallback: "禁用")
  /// 启用
  public static let enabledLabel = L10n.tr("Localizable", "enabledLabel", fallback: "启用")
  public enum About {
    /// 关于
    public static let title = L10n.tr("Localizable", "about.title", fallback: "关于")
  }
  public enum App {
    /// 输入法设置
    public static let title = L10n.tr("Localizable", "app.title", fallback: "输入法设置")
  }
  public enum Backup {
    /// 软件备份
    public static let title = L10n.tr("Localizable", "backup.title", fallback: "软件备份")
  }
  public enum ColorScheme {
    /// 键盘配色
    public static let title = L10n.tr("Localizable", "color_scheme.title", fallback: "键盘配色")
  }
  public enum Favbtn {
    /// 应用备份
    public static let backup = L10n.tr("Localizable", "favbtn.backup", fallback: "应用备份")
    /// 重新部署
    public static let redeploy = L10n.tr("Localizable", "favbtn.redeploy", fallback: "重新部署")
    /// RIME同步
    public static let sync = L10n.tr("Localizable", "favbtn.sync", fallback: "RIME同步")
  }
  public enum Feedback {
    /// 按键音与震动
    public static let title = L10n.tr("Localizable", "feedback.title", fallback: "按键音与震动")
  }
  public enum Finder {
    /// 文件管理
    public static let title = L10n.tr("Localizable", "finder.title", fallback: "文件管理")
  }
  public enum ICloud {
    /// iCloud同步
    public static let title = L10n.tr("Localizable", "i_cloud.title", fallback: "iCloud同步")
  }
  public enum InputSchema {
    /// 输入方案设置
    public static let title = L10n.tr("Localizable", "input_schema.title", fallback: "输入方案设置")
    public enum Upload {
      /// Wi-Fi上传方案
      public static let title = L10n.tr("Localizable", "input_schema.upload.title", fallback: "Wi-Fi上传方案")
    }
  }
  public enum KB {
    /// 键盘相关
    public static let sectionTitle = L10n.tr("Localizable", "k_b.section_title", fallback: "键盘相关")
    /// 键盘设置
    public static let title = L10n.tr("Localizable", "k_b.title", fallback: "键盘设置")
  }
  public enum LoadAppData {
    /// 部署完成
    public static let deployed = L10n.tr("Localizable", "load_app_data.deployed", fallback: "部署完成")
    /// 导入数据异常
    public static let error = L10n.tr("Localizable", "load_app_data.error", fallback: "导入数据异常")
    /// 初次启动，需要编译输入方案，请耐心等待……
    public static let initialize = L10n.tr("Localizable", "load_app_data.initialize", fallback: "初次启动，需要编译输入方案，请耐心等待……")
    /// 迁移完成
    public static let migrated = L10n.tr("Localizable", "load_app_data.migrated", fallback: "迁移完成")
    /// 迁移 1.0 配置中……
    public static let migratingV1Data = L10n.tr("Localizable", "load_app_data.migrating_v1_data", fallback: "迁移 1.0 配置中……")
  }
  public enum Rime {
    /// RIME
    public static let title = L10n.tr("Localizable", "rime.title", fallback: "RIME")
  }
  public enum Solution {
    /// 输入相关
    public static let title = L10n.tr("Localizable", "solution.title", fallback: "输入相关")
  }
  public enum Syncbackup {
    /// 同步与备份
    public static let title = L10n.tr("Localizable", "syncbackup.title", fallback: "同步与备份")
  }
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
