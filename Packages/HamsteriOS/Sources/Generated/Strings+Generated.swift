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
    /// 作者： %@
    public static func authorName(_ p1: Any) -> String {
      return L10n.tr("Localizable", "color_scheme.author_name", String(describing: p1), fallback: "作者： %@")
    }
    /// 启用配色
    public static let enableCustomKeyboardColor = L10n.tr("Localizable", "color_scheme.enable_custom_keyboard_color", fallback: "启用配色")
    /// 方案名称： %@
    public static func schemeName(_ p1: Any) -> String {
      return L10n.tr("Localizable", "color_scheme.scheme_name", String(describing: p1), fallback: "方案名称： %@")
    }
    /// 系统浅色模式
    public static let systemDarkMode = L10n.tr("Localizable", "color_scheme.system_dark_mode", fallback: "系统浅色模式")
    /// 系统深色模式
    public static let systemLightMode = L10n.tr("Localizable", "color_scheme.system_light_mode", fallback: "系统深色模式")
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
    /// 按键震动
    public static let haptic = L10n.tr("Localizable", "feedback.haptic", fallback: "按键震动")
    /// 开启震动需要为键盘开启“完全访问权限”
    public static let hapticPermission = L10n.tr("Localizable", "feedback.haptic_permission", fallback: "开启震动需要为键盘开启“完全访问权限”")
    /// 开启按键声
    public static let sound = L10n.tr("Localizable", "feedback.sound", fallback: "开启按键声")
    /// 按键音与震动
    public static let title = L10n.tr("Localizable", "feedback.title", fallback: "按键音与震动")
    /// 键盘反馈
    public static let title2 = L10n.tr("Localizable", "feedback.title2", fallback: "键盘反馈")
  }
  public enum Finder {
    /// 文件管理
    public static let title = L10n.tr("Localizable", "finder.title", fallback: "文件管理")
  }
  public enum ICloud {
    /// 拷贝应用文件至iCloud
    public static let copyFileToICloud = L10n.tr("Localizable", "i_cloud.copy_file_to_i_cloud", fallback: "拷贝应用文件至iCloud")
    /// 默认为全量拷贝，如需过滤拷贝内容，需要结合过滤表达式一起使用；
    public static let copyRemark = L10n.tr("Localizable", "i_cloud.copy_remark", fallback: "默认为全量拷贝，如需过滤拷贝内容，需要结合过滤表达式一起使用；")
    /// iCloud
    public static let enableAppleCloud = L10n.tr("Localizable", "i_cloud.enable_apple_cloud", fallback: "iCloud")
    /// 1. 启用后，“重新部署”会复制iCloud中仓输入法`RIME`文件夹下全部文件；
    /// 2. 复制时，差异文件会被覆盖；
    public static let enableAppleCloudRemark = L10n.tr("Localizable", "i_cloud.enable_apple_cloud_remark", fallback: "1. 启用后，“重新部署”会复制iCloud中仓输入法`RIME`文件夹下全部文件；\n2. 复制时，差异文件会被覆盖；")
    /// 正则过滤
    public static let regexOnCopyFile = L10n.tr("Localizable", "i_cloud.regex_on_copy_file", fallback: "正则过滤")
    /// 1. 过滤表达式在“重新部署”功能中也会生效；
    /// 2. 多个正则表达式使用英文逗号分隔；
    /// 3. 常用示例（点击可复制全部表达式，请按需修改）:
    ///    * 过滤userdb目录 ^.*[.]userdb.*$
    ///    * 过滤build目录 ^.*build.*$
    ///    * 过滤SharedSupport目录 ^.*SharedSupport.*$
    ///    * 过滤编译后的词库文件 ^.*[.]bin$
    public static let regexRemark = L10n.tr("Localizable", "i_cloud.regex_remark", fallback: "1. 过滤表达式在“重新部署”功能中也会生效；\n2. 多个正则表达式使用英文逗号分隔；\n3. 常用示例（点击可复制全部表达式，请按需修改）:\n   * 过滤userdb目录 ^.*[.]userdb.*$\n   * 过滤build目录 ^.*build.*$\n   * 过滤SharedSupport目录 ^.*SharedSupport.*$\n   * 过滤编译后的词库文件 ^.*[.]bin$")
    /// iCloud同步
    public static let title = L10n.tr("Localizable", "i_cloud.title", fallback: "iCloud同步")
    public enum Upload {
      /// 拷贝中……
      public static let copying = L10n.tr("Localizable", "i_cloud.upload.copying", fallback: "拷贝中……")
      /// 拷贝失败: %@
      public static func failed(_ p1: Any) -> String {
        return L10n.tr("Localizable", "i_cloud.upload.failed", String(describing: p1), fallback: "拷贝失败: %@")
      }
      /// 拷贝成功
      public static let success = L10n.tr("Localizable", "i_cloud.upload.success", fallback: "拷贝成功")
    }
  }
  public enum InputSchema {
    /// 需要保留至少一个输入方案。
    public static let selectAtLeastOne = L10n.tr("Localizable", "input_schema.select_at_least_one", fallback: "需要保留至少一个输入方案。")
    /// 方案部署中……
    public static let solutionDeploying = L10n.tr("Localizable", "input_schema.solution_deploying", fallback: "方案部署中……")
    /// 输入方案设置
    public static let title = L10n.tr("Localizable", "input_schema.title", fallback: "输入方案设置")
    /// 未能获取上传方案文件信息
    public static let uploadFileInfoError = L10n.tr("Localizable", "input_schema.upload_file_info_error", fallback: "未能获取上传方案文件信息")
    /// 方案文件不能超过 50 MB
    public static let uploadSizeLimitError = L10n.tr("Localizable", "input_schema.upload_size_limit_error", fallback: "方案文件不能超过 50 MB")
    /// 方案上传中……
    public static let uploading = L10n.tr("Localizable", "input_schema.uploading", fallback: "方案上传中……")
    public enum Action {
      /// 方案下载
      public static let download = L10n.tr("Localizable", "input_schema.action.download", fallback: "方案下载")
      /// 导入方案
      public static let `import` = L10n.tr("Localizable", "input_schema.action.import", fallback: "导入方案")
      /// 开源方案上传
      public static let upload = L10n.tr("Localizable", "input_schema.action.upload", fallback: "开源方案上传")
    }
    public enum Cloud {
      /// 下载中……
      public static let downloading = L10n.tr("Localizable", "input_schema.cloud.downloading", fallback: "下载中……")
      /// 覆盖并部署
      public static let installByOverwrite = L10n.tr("Localizable", "input_schema.cloud.install_by_overwrite", fallback: "覆盖并部署")
      /// 替换并部署
      public static let installByReplace = L10n.tr("Localizable", "input_schema.cloud.install_by_replace", fallback: "替换并部署")
      /// 替换：删除当前 Rime 路径下文件，并将下载的方案文件存放至 Rime 路径下。
      /// 覆盖：将下载方案文件存放至 Rime 目录下，相同文件名称文件覆盖，不同文件追加。
      public static let installRemark = L10n.tr("Localizable", "input_schema.cloud.install_remark", fallback: "替换：删除当前 Rime 路径下文件，并将下载的方案文件存放至 Rime 路径下。\n覆盖：将下载方案文件存放至 Rime 目录下，相同文件名称文件覆盖，不同文件追加。")
      /// 加载中……
      public static let listLoading = L10n.tr("Localizable", "input_schema.cloud.list_loading", fallback: "加载中……")
      /// 开源输入方案
      public static let title = L10n.tr("Localizable", "input_schema.cloud.title", fallback: "开源输入方案")
      public enum AlertOverwrite {
        /// 使用下载方案覆盖当前Rime目录，覆盖后原Rime路径下相同文件名文件会被覆盖，是否确认覆盖
        public static let message = L10n.tr("Localizable", "input_schema.cloud.alert_overwrite.message", fallback: "使用下载方案覆盖当前Rime目录，覆盖后原Rime路径下相同文件名文件会被覆盖，是否确认覆盖")
        /// 覆盖安装
        public static let title = L10n.tr("Localizable", "input_schema.cloud.alert_overwrite.title", fallback: "覆盖安装")
      }
      public enum AlertReplace {
        /// 使用下载方案替换当前Rime目录，替换后原Rime路径下文件不可恢复，是否确认替换？
        public static let message = L10n.tr("Localizable", "input_schema.cloud.alert_replace.message", fallback: "使用下载方案替换当前Rime目录，替换后原Rime路径下文件不可恢复，是否确认替换？")
        /// 替换安装
        public static let title = L10n.tr("Localizable", "input_schema.cloud.alert_replace.title", fallback: "替换安装")
      }
    }
    public enum Create {
      /// 确认上传
      public static let alertConfirm = L10n.tr("Localizable", "input_schema.create.alert_confirm", fallback: "确认上传")
      /// 请勿上传非自己创作且无版权的输入方案，不符合规范的方案会被定期清除。
      public static let alertMessage = L10n.tr("Localizable", "input_schema.create.alert_message", fallback: "请勿上传非自己创作且无版权的输入方案，不符合规范的方案会被定期清除。")
      /// 上传输入方案
      public static let alertTitle = L10n.tr("Localizable", "input_schema.create.alert_title", fallback: "上传输入方案")
      /// 作者
      public static let author = L10n.tr("Localizable", "input_schema.create.author", fallback: "作者")
      /// 请输入方案作者
      public static let authorError = L10n.tr("Localizable", "input_schema.create.author_error", fallback: "请输入方案作者")
      /// 请勿上传非自己创作且无版权的输入方案，不符合规范的方案会被定期删除。
      public static let bannerMessage = L10n.tr("Localizable", "input_schema.create.banner_message", fallback: "请勿上传非自己创作且无版权的输入方案，不符合规范的方案会被定期删除。")
      /// 请注意
      public static let bannerTitle = L10n.tr("Localizable", "input_schema.create.banner_title", fallback: "请注意")
      /// 方案描述：
      public static let description = L10n.tr("Localizable", "input_schema.create.description", fallback: "方案描述：")
      /// 请输入方案描述
      public static let descriptionError = L10n.tr("Localizable", "input_schema.create.description_error", fallback: "请输入方案描述")
      /// 请输入方案名称
      public static let nameError = L10n.tr("Localizable", "input_schema.create.name_error", fallback: "请输入方案名称")
      /// 请选择需要上传的方案文件
      public static let noUploadFileError = L10n.tr("Localizable", "input_schema.create.no_upload_file_error", fallback: "请选择需要上传的方案文件")
      /// 选择输入方案Zip文件
      public static let pickFile = L10n.tr("Localizable", "input_schema.create.pick_file", fallback: "选择输入方案Zip文件")
      /// 注意：请勿上传无版权输入方案。
      /// %@
      public static func remark(_ p1: Any) -> String {
        return L10n.tr("Localizable", "input_schema.create.remark", String(describing: p1), fallback: "注意：请勿上传无版权输入方案。\n%@")
      }
      /// 输入方案名称
      public static let solutionName = L10n.tr("Localizable", "input_schema.create.solution_name", fallback: "输入方案名称")
      /// 上传开源输入方案
      public static let title = L10n.tr("Localizable", "input_schema.create.title", fallback: "上传开源输入方案")
      /// 上传
      public static let upload = L10n.tr("Localizable", "input_schema.create.upload", fallback: "上传")
    }
    public enum Import {
      /// 导入Zip文件失败, %@
      public static func failed(_ p1: Any) -> String {
        return L10n.tr("Localizable", "input_schema.import.failed", String(describing: p1), fallback: "导入Zip文件失败, %@")
      }
      /// 方案导入中……
      public static let importing = L10n.tr("Localizable", "input_schema.import.importing", fallback: "方案导入中……")
      /// 导入成功
      public static let success = L10n.tr("Localizable", "input_schema.import.success", fallback: "导入成功")
    }
    public enum Upload {
      /// http://%@
      public static func address(_ p1: Any) -> String {
        return L10n.tr("Localizable", "input_schema.upload.address", String(describing: p1), fallback: "http://%@")
      }
      /// 局域网访问地址(点击复制)
      public static let clickToCopy = L10n.tr("Localizable", "input_schema.upload.click_to_copy", fallback: "局域网访问地址(点击复制)")
      /// 上传方案失败：%@
      public static func failed(_ p1: Any) -> String {
        return L10n.tr("Localizable", "input_schema.upload.failed", String(describing: p1), fallback: "上传方案失败：%@")
      }
      /// 无法获取 IP 地址，请在系统设置 - WiFi 中查看地址。
      public static let noAddressAvailable = L10n.tr("Localizable", "input_schema.upload.no_address_available", fallback: "无法获取 IP 地址，请在系统设置 - WiFi 中查看地址。")
      /// 
      /// 1. 连接到相同的 Wi-Fi，注意：开启服务请不要离开此页面或锁定手机；
      /// 2. 请将个人方案上传至“Rime”文件夹内，可先删除原“Rime”文件夹内文件在上传;
      /// 3. 上传完毕后，需要“重新部署”，否则方案不会生效；
      /// 4. 浏览器内支持全选/拖拽上传等动作。
      public static let remark = L10n.tr("Localizable", "input_schema.upload.remark", fallback: "\n1. 连接到相同的 Wi-Fi，注意：开启服务请不要离开此页面或锁定手机；\n2. 请将个人方案上传至“Rime”文件夹内，可先删除原“Rime”文件夹内文件在上传;\n3. 上传完毕后，需要“重新部署”，否则方案不会生效；\n4. 浏览器内支持全选/拖拽上传等动作。")
      /// 启动服务
      public static let startService = L10n.tr("Localizable", "input_schema.upload.start_service", fallback: "启动服务")
      /// 停止服务
      public static let stopService = L10n.tr("Localizable", "input_schema.upload.stop_service", fallback: "停止服务")
      /// 方案上传成功……
      public static let success = L10n.tr("Localizable", "input_schema.upload.success", fallback: "方案上传成功……")
      /// Wi-Fi上传方案
      public static let title = L10n.tr("Localizable", "input_schema.upload.title", fallback: "Wi-Fi上传方案")
      /// 输入方案上传
      public static let title2 = L10n.tr("Localizable", "input_schema.upload.title2", fallback: "输入方案上传")
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
