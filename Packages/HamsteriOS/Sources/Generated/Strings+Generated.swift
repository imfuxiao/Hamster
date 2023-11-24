// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  /// 取消
  public static let cancel = L10n.tr("Localizable", "cancel", fallback: "取消")
  /// 确认
  public static let confirm = L10n.tr("Localizable", "confirm", fallback: "确认")
  /// 复制成功
  public static let copySuccessfully = L10n.tr("Localizable", "copy_successfully", fallback: "复制成功")
  /// 删除
  public static let delete = L10n.tr("Localizable", "delete", fallback: "删除")
  /// 禁用
  public static let disabledLabel = L10n.tr("Localizable", "disabledLabel", fallback: "禁用")
  /// 启用
  public static let enabledLabel = L10n.tr("Localizable", "enabledLabel", fallback: "启用")
  /// 重置成功
  public static let resetSuccessfully = L10n.tr("Localizable", "reset_successfully", fallback: "重置成功")
  public enum About {
    /// 联系邮箱
    public static let email = L10n.tr("Localizable", "about.email", fallback: "联系邮箱")
    /// 许可证
    public static let license = L10n.tr("Localizable", "about.license", fallback: "许可证")
    /// RIME版本
    public static let rimeVersion = L10n.tr("Localizable", "about.rime_version", fallback: "RIME版本")
    /// 开源地址
    public static let source = L10n.tr("Localizable", "about.source", fallback: "开源地址")
    /// 关于
    public static let title = L10n.tr("Localizable", "about.title", fallback: "关于")
    public enum Export {
      /// 导出 UI 设置失败
      public static let error = L10n.tr("Localizable", "about.export.error", fallback: "导出 UI 设置失败")
      /// 导出的通过界面修改的配置项。
      /// 注意：不包新增/修改配置文件中的设置。
      public static let footer = L10n.tr("Localizable", "about.export.footer", fallback: "导出的通过界面修改的配置项。\n注意：不包新增/修改配置文件中的设置。")
      /// 导出界面设置
      public static let text = L10n.tr("Localizable", "about.export.text", fallback: "导出界面设置")
    }
    public enum Oss {
      /// 使用开源库列表
      public static let list = L10n.tr("Localizable", "about.oss.list", fallback: "使用开源库列表")
      /// 使用开源列表
      public static let title = L10n.tr("Localizable", "about.oss.title", fallback: "使用开源列表")
    }
    public enum Reset {
      /// 确定
      public static let confirm = L10n.tr("Localizable", "about.reset.confirm", fallback: "确定")
      /// 重置通过界面修改的配置项。
      /// 注意：不包含新增/修改配置文件中的配置项。
      public static let footer = L10n.tr("Localizable", "about.reset.footer", fallback: "重置通过界面修改的配置项。\n注意：不包含新增/修改配置文件中的配置项。")
      /// 确认重置 UI 交互生成的设置吗？
      public static let message = L10n.tr("Localizable", "about.reset.message", fallback: "确认重置 UI 交互生成的设置吗？")
      /// 重置界面设置
      public static let text = L10n.tr("Localizable", "about.reset.text", fallback: "重置界面设置")
      /// 重置 UI 设置
      public static let title = L10n.tr("Localizable", "about.reset.title", fallback: "重置 UI 设置")
    }
  }
  public enum App {
    /// 仓输入法
    public static let name = L10n.tr("Localizable", "app.name", fallback: "仓输入法")
    /// 输入法设置
    public static let title = L10n.tr("Localizable", "app.title", fallback: "输入法设置")
  }
  public enum Backup {
    /// 1. 向左划动操作文件；
    /// 2. 软件恢复后,请手动执行“重新部署”；
    public static let remark = L10n.tr("Localizable", "backup.remark", fallback: "1. 向左划动操作文件；\n2. 软件恢复后,请手动执行“重新部署”；")
    /// 软件备份
    public static let title = L10n.tr("Localizable", "backup.title", fallback: "软件备份")
    /// 备份与恢复
    public static let title2 = L10n.tr("Localizable", "backup.title2", fallback: "备份与恢复")
    public enum Create {
      /// 软件备份中，请等待……
      public static let backingUp = L10n.tr("Localizable", "backup.create.backing_up", fallback: "软件备份中，请等待……")
      /// 备份失败
      public static let failed = L10n.tr("Localizable", "backup.create.failed", fallback: "备份失败")
      /// 备份成功
      public static let success = L10n.tr("Localizable", "backup.create.success", fallback: "备份成功")
      /// 软件备份
      public static let title = L10n.tr("Localizable", "backup.create.title", fallback: "软件备份")
    }
    public enum Delete {
      /// 文件删除后无法恢复，确认删除？
      public static let alertMessage = L10n.tr("Localizable", "backup.delete.alert_message", fallback: "文件删除后无法恢复，确认删除？")
      /// 是否删除？
      public static let alertTitle = L10n.tr("Localizable", "backup.delete.alert_title", fallback: "是否删除？")
      /// 删除失败
      public static let errorMessage = L10n.tr("Localizable", "backup.delete.error_message", fallback: "删除失败")
      /// 删除文件
      public static let errorTitle = L10n.tr("Localizable", "backup.delete.error_title", fallback: "删除文件")
    }
    public enum Rename {
      /// 修改备份文件名称
      public static let alertTitle = L10n.tr("Localizable", "backup.rename.alert_title", fallback: "修改备份文件名称")
      /// 新文件名称
      public static let newName = L10n.tr("Localizable", "backup.rename.new_name", fallback: "新文件名称")
      /// 修改名称
      public static let title = L10n.tr("Localizable", "backup.rename.title", fallback: "修改名称")
    }
    public enum Restore {
      /// 恢复失败
      public static let failed = L10n.tr("Localizable", "backup.restore.failed", fallback: "恢复失败")
      /// 恢复中，请等待……
      public static let restoring = L10n.tr("Localizable", "backup.restore.restoring", fallback: "恢复中，请等待……")
      /// 恢复成功, 请重新部署。
      public static let success = L10n.tr("Localizable", "backup.restore.success", fallback: "恢复成功, 请重新部署。")
      /// 恢复
      public static let title = L10n.tr("Localizable", "backup.restore.title", fallback: "恢复")
    }
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
    public enum Deploy {
      /// RIME部署中, 请稍候……
      public static let deploying = L10n.tr("Localizable", "rime.deploy.deploying", fallback: "RIME部署中, 请稍候……")
      /// 部署成功
      public static let success = L10n.tr("Localizable", "rime.deploy.success", fallback: "部署成功")
      /// 重新部署
      public static let text = L10n.tr("Localizable", "rime.deploy.text", fallback: "重新部署")
    }
    public enum Logger {
      /// 请检查 %@，第 %@ 行。
      public static func bannerMessage(_ p1: Any, _ p2: Any) -> String {
        return L10n.tr("Localizable", "rime.logger.banner_message", String(describing: p1), String(describing: p2), fallback: "请检查 %@，第 %@ 行。")
      }
      /// RIME日志存在异常
      public static let bannerTitle = L10n.tr("Localizable", "rime.logger.banner_title", fallback: "RIME日志存在异常")
      /// RIME 部署异常
      public static let error = L10n.tr("Localizable", "rime.logger.error", fallback: "RIME 部署异常")
      /// RIME 日志
      public static let text = L10n.tr("Localizable", "rime.logger.text", fallback: "RIME 日志")
    }
    public enum OverrideDict {
      /// 如果您未使用自造词功能，请保持保持默认开启状态。
      public static let footer = L10n.tr("Localizable", "rime.override_dict.footer", fallback: "如果您未使用自造词功能，请保持保持默认开启状态。")
      /// 部署时覆盖键盘词库文件
      public static let text = L10n.tr("Localizable", "rime.override_dict.text", fallback: "部署时覆盖键盘词库文件")
    }
    public enum Reset {
      /// 重置
      public static let alertConfirm = L10n.tr("Localizable", "rime.reset.alert_confirm", fallback: "重置")
      /// 重置会恢复到初始安装状态，是否确认重置？
      public static let alertMessage = L10n.tr("Localizable", "rime.reset.alert_message", fallback: "重置会恢复到初始安装状态，是否确认重置？")
      /// RIME 重置
      public static let alertTitle = L10n.tr("Localizable", "rime.reset.alert_title", fallback: "RIME 重置")
      /// 重置失败
      public static let failed = L10n.tr("Localizable", "rime.reset.failed", fallback: "重置失败")
      /// RIME重置中, 请稍候……
      public static let reseting = L10n.tr("Localizable", "rime.reset.reseting", fallback: "RIME重置中, 请稍候……")
      /// 重置成功
      public static let success = L10n.tr("Localizable", "rime.reset.success", fallback: "重置成功")
      /// RIME重置
      public static let text = L10n.tr("Localizable", "rime.reset.text", fallback: "RIME重置")
    }
    public enum SimpTradSwtich {
      /// 配置文件中`switches`简繁转换选项的配置名称，仓用于中文简体与繁体之间快速切换。
      public static let footer = L10n.tr("Localizable", "rime.simp_trad_swtich.footer", fallback: "配置文件中`switches`简繁转换选项的配置名称，仓用于中文简体与繁体之间快速切换。")
      /// 简繁切换键值
      public static let placeholder = L10n.tr("Localizable", "rime.simp_trad_swtich.placeholder", fallback: "简繁切换键值")
      /// 简繁切换
      public static let title = L10n.tr("Localizable", "rime.simp_trad_swtich.title", fallback: "简繁切换")
    }
    public enum Sync {
      /// 同步失败:%@
      public static func failed(_ p1: Any) -> String {
        return L10n.tr("Localizable", "rime.sync.failed", String(describing: p1), fallback: "同步失败:%@")
      }
      /// 注意：
      /// 1. RIME同步自定义参数，需要手工添加至Rime目录下的`installation.yaml`文件中(如果没有，需要则自行创建)；
      /// 2. 同步配置示例：(点击可复制)
      /// ```
      /// %@
      /// ```
      public static func footer(_ p1: Any) -> String {
        return L10n.tr("Localizable", "rime.sync.footer", String(describing: p1), fallback: "注意：\n1. RIME同步自定义参数，需要手工添加至Rime目录下的`installation.yaml`文件中(如果没有，需要则自行创建)；\n2. 同步配置示例：(点击可复制)\n```\n%@\n```")
      }
      /// 同步成功
      public static let success = L10n.tr("Localizable", "rime.sync.success", fallback: "同步成功")
      /// RIME同步中, 请稍候……
      public static let syncing = L10n.tr("Localizable", "rime.sync.syncing", fallback: "RIME同步中, 请稍候……")
      /// RIME同步
      public static let text = L10n.tr("Localizable", "rime.sync.text", fallback: "RIME同步")
      /// 同步地址无写入权限：%@
      public static func writeError(_ p1: Any) -> String {
        return L10n.tr("Localizable", "rime.sync.write_error", String(describing: p1), fallback: "同步地址无写入权限：%@")
      }
      public enum SampleConfig {
        /// id可以自定义，但不能其他终端定义的ID重复
        public static let comment1 = L10n.tr("Localizable", "rime.sync.sample_config.comment1", fallback: "id可以自定义，但不能其他终端定义的ID重复")
        /// 仓的iOS中iCloud前缀路径固定为：
        public static let comment2 = L10n.tr("Localizable", "rime.sync.sample_config.comment2", fallback: "仓的iOS中iCloud前缀路径固定为：")
        /// iOS中的路径与MacOS及Windows的iCloud路径是不同的
        public static let comment3 = L10n.tr("Localizable", "rime.sync.sample_config.comment3", fallback: "iOS中的路径与MacOS及Windows的iCloud路径是不同的")
      }
    }
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
