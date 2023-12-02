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
  /// 完成
  public static let done = L10n.tr("Localizable", "done", fallback: "完成")
  /// 编辑
  public static let edit = L10n.tr("Localizable", "edit", fallback: "编辑")
  /// 启用
  public static let enabledLabel = L10n.tr("Localizable", "enabledLabel", fallback: "启用")
  /// 重置失败
  public static let resetFailed = L10n.tr("Localizable", "reset_failed", fallback: "重置失败")
  /// 重置成功
  public static let resetSuccessfully = L10n.tr("Localizable", "reset_successfully", fallback: "重置成功")
  /// 保存
  public static let save = L10n.tr("Localizable", "save", fallback: "保存")
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
    public enum Action {
      /// 拷贝键盘词库文件至应用
      public static let copyUserdb = L10n.tr("Localizable", "finder.action.copy_userdb", fallback: "拷贝键盘词库文件至应用")
      /// 使用键盘文件覆盖应用文件
      public static let overwriteKeyboard = L10n.tr("Localizable", "finder.action.overwrite_keyboard", fallback: "使用键盘文件覆盖应用文件")
    }
    public enum CopyUserdb {
      /// 拷贝中……
      public static let copying = L10n.tr("Localizable", "finder.copy_userdb.copying", fallback: "拷贝中……")
      /// 指后缀为“.txt”及文件夹名包含“.userdb”下的文件
      public static let remark = L10n.tr("Localizable", "finder.copy_userdb.remark", fallback: "指后缀为“.txt”及文件夹名包含“.userdb”下的文件")
      /// 拷贝词库成功
      public static let success = L10n.tr("Localizable", "finder.copy_userdb.success", fallback: "拷贝词库成功")
    }
    public enum Delete {
      /// 文件删除后无法恢复，确认删除？
      public static let alertMessage = L10n.tr("Localizable", "finder.delete.alert_message", fallback: "文件删除后无法恢复，确认删除？")
      /// 是否删除？
      public static let alertTitle = L10n.tr("Localizable", "finder.delete.alert_title", fallback: "是否删除？")
    }
    public enum Editor {
      /// 文本编辑器: 自动换行
      public static let lineWrappingEnabled = L10n.tr("Localizable", "finder.editor.line_wrapping_enabled", fallback: "文本编辑器: 自动换行")
      public enum Save {
        /// 保存失败
        public static let failed = L10n.tr("Localizable", "finder.editor.save.failed", fallback: "保存失败")
        /// 保存成功
        public static let success = L10n.tr("Localizable", "finder.editor.save.success", fallback: "保存成功")
      }
    }
    public enum ICloudDoc {
      /// iCloud异常
      public static let warning = L10n.tr("Localizable", "finder.i_cloud_doc.warning", fallback: "iCloud异常")
    }
    public enum Overwrite {
      /// 覆盖后应用文件无法恢复，确认覆盖？
      public static let alertMessage = L10n.tr("Localizable", "finder.overwrite.alert_message", fallback: "覆盖后应用文件无法恢复，确认覆盖？")
      /// 是否覆盖？
      public static let alertTitle = L10n.tr("Localizable", "finder.overwrite.alert_title", fallback: "是否覆盖？")
    }
    public enum OverwriteKeyboard {
      /// 覆盖中……
      public static let overwriting = L10n.tr("Localizable", "finder.overwrite_keyboard.overwriting", fallback: "覆盖中……")
      /// 完成
      public static let success = L10n.tr("Localizable", "finder.overwrite_keyboard.success", fallback: "完成")
    }
    public enum Tag {
      /// 应用文件
      public static let app = L10n.tr("Localizable", "finder.tag.app", fallback: "应用文件")
      /// 通用
      public static let general = L10n.tr("Localizable", "finder.tag.general", fallback: "通用")
      /// iCloud文件
      public static let iCloud = L10n.tr("Localizable", "finder.tag.i_cloud", fallback: "iCloud文件")
      /// 键盘文件
      public static let keyboard = L10n.tr("Localizable", "finder.tag.keyboard", fallback: "键盘文件")
    }
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
    /// 关闭后，Shift状态随当前输入状态变化。注意: 双击Shift会保持锁定
    public static let autoLowerRemark = L10n.tr("Localizable", "k_b.auto_lower_remark", fallback: "关闭后，Shift状态随当前输入状态变化。注意: 双击Shift会保持锁定")
    /// 划动文本显示关闭
    public static let disableSwipeLabel = L10n.tr("Localizable", "k_b.disableSwipeLabel", fallback: "划动文本显示关闭")
    /// 显示按键气泡
    public static let displayButtonBubbles = L10n.tr("Localizable", "k_b.displayButtonBubbles", fallback: "显示按键气泡")
    /// 显示按键底部边框
    public static let enableButtonUnderBorder = L10n.tr("Localizable", "k_b.enableButtonUnderBorder", fallback: "显示按键底部边框")
    /// 启用内嵌模式
    public static let enableEmbeddedInputMode = L10n.tr("Localizable", "k_b.enableEmbeddedInputMode", fallback: "启用内嵌模式")
    /// Shift状态锁定
    public static let lockShiftState = L10n.tr("Localizable", "k_b.lockShiftState", fallback: "Shift状态锁定")
    /// 数字九宫格
    public static let numberNineGrid = L10n.tr("Localizable", "k_b.number_nine_grid", fallback: "数字九宫格")
    /// 键盘相关
    public static let sectionTitle = L10n.tr("Localizable", "k_b.section_title", fallback: "键盘相关")
    /// 开启后，按键上方显示上划，下方显示下划。
    public static let showSwipeUpAndDownLayoutRemark = L10n.tr("Localizable", "k_b.show_swipe_up_and_down_layout_remark", fallback: "开启后，按键上方显示上划，下方显示下划。")
    /// 空格设置
    public static let spaceSettings = L10n.tr("Localizable", "k_b.space_settings", fallback: "空格设置")
    /// 不规则显示划动文本
    public static let swipeLabelUpAndDownIrregularLayout = L10n.tr("Localizable", "k_b.swipeLabelUpAndDownIrregularLayout", fallback: "不规则显示划动文本")
    /// 划动文本上下显示
    public static let swipeLabelUpAndDownLayout = L10n.tr("Localizable", "k_b.swipeLabelUpAndDownLayout", fallback: "划动文本上下显示")
    /// 分类符号键盘
    public static let symbolKeyboard = L10n.tr("Localizable", "k_b.symbol_keyboard", fallback: "分类符号键盘")
    /// 符号设置
    public static let symbolPrefs = L10n.tr("Localizable", "k_b.symbol_prefs", fallback: "符号设置")
    /// 键盘设置
    public static let title = L10n.tr("Localizable", "k_b.title", fallback: "键盘设置")
    /// 候选栏设置
    public static let toolbarPrefs = L10n.tr("Localizable", "k_b.toolbar_prefs", fallback: "候选栏设置")
    /// 开启后建议调整工具栏高度为：40。
    /// （位置：键盘设置 -> 候选栏设置 -> 工具栏高度）
    public static let toolbarRemark = L10n.tr("Localizable", "k_b.toolbar_remark", fallback: "开启后建议调整工具栏高度为：40。\n（位置：键盘设置 -> 候选栏设置 -> 工具栏高度）")
    /// 关闭后，按键右上侧为显示上划文本，左上侧显示下划文本。
    public static let upSwipeOnLeftRemark = L10n.tr("Localizable", "k_b.up_swipe_on_left_remark", fallback: "关闭后，按键右上侧为显示上划文本，左上侧显示下划文本。")
    /// 上划显示位置-左上侧
    public static let upSwipeOnLeft = L10n.tr("Localizable", "k_b.upSwipeOnLeft", fallback: "上划显示位置-左上侧")
    public enum ActionOption {
      /// 字符（由 RIME 处理）
      public static let character = L10n.tr("Localizable", "k_b.action_option.character", fallback: "字符（由 RIME 处理）")
      /// 切换键盘
      public static let keyboardType = L10n.tr("Localizable", "k_b.action_option.keyboardType", fallback: "切换键盘")
      /// 快捷指令
      public static let shortCommand = L10n.tr("Localizable", "k_b.action_option.shortCommand", fallback: "快捷指令")
      /// 符号字符（不由 RIME 处理）
      public static let symbol = L10n.tr("Localizable", "k_b.action_option.symbol", fallback: "符号字符（不由 RIME 处理）")
    }
    public enum Layout {
      /// 中文26键
      public static let chinese = L10n.tr("Localizable", "k_b.layout.chinese", fallback: "中文26键")
      /// 中文9键
      public static let chineseNineGrid = L10n.tr("Localizable", "k_b.layout.chineseNineGrid", fallback: "中文9键")
      /// 自定义键盘
      public static let custom = L10n.tr("Localizable", "k_b.layout.custom", fallback: "自定义键盘")
      /// 自定义-%@
      public static func customNamed(_ p1: Any) -> String {
        return L10n.tr("Localizable", "k_b.layout.custom_named", String(describing: p1), fallback: "自定义-%@")
      }
      /// 数字九宫格
      public static let numericNineGrid = L10n.tr("Localizable", "k_b.layout.numericNineGrid", fallback: "数字九宫格")
      /// 注意：
      /// 1. 内置键盘向左滑动进入设置页面。
      /// 2. 自定义布局通过配置文件调整，调整后需重新部署。
      public static let remark = L10n.tr("Localizable", "k_b.layout.remark", fallback: "注意：\n1. 内置键盘向左滑动进入设置页面。\n2. 自定义布局通过配置文件调整，调整后需重新部署。")
      /// 键盘布局
      public static let title = L10n.tr("Localizable", "k_b.layout.title", fallback: "键盘布局")
    }
    public enum LayoutAction {
      /// 设置
      public static let settings = L10n.tr("Localizable", "k_b.layout_action.settings", fallback: "设置")
      public enum Delete {
        /// 未找到此键盘
        public static let failed = L10n.tr("Localizable", "k_b.layout_action.delete.failed", fallback: "未找到此键盘")
        /// 删除成功
        public static let success = L10n.tr("Localizable", "k_b.layout_action.delete.success", fallback: "删除成功")
      }
      public enum Import {
        /// 自定义键盘配置文件加载失败
        public static let failed = L10n.tr("Localizable", "k_b.layout_action.import.failed", fallback: "自定义键盘配置文件加载失败")
        /// 导入中……
        public static let importing = L10n.tr("Localizable", "k_b.layout_action.import.importing", fallback: "导入中……")
        /// 导入成功
        public static let success = L10n.tr("Localizable", "k_b.layout_action.import.success", fallback: "导入成功")
        /// 导入文件读取受限，无法加载文件
        public static let unableToAccess = L10n.tr("Localizable", "k_b.layout_action.import.unable_to_access", fallback: "导入文件读取受限，无法加载文件")
      }
    }
    public enum LayoutSymbol {
      /// 启用分类符号键盘
      public static let enableSymbolKeyboard = L10n.tr("Localizable", "k_b.layout_symbol.enableSymbolKeyboard", fallback: "启用分类符号键盘")
      /// 常用符号 - 恢复默认值
      public static let resetCommonSymbol = L10n.tr("Localizable", "k_b.layout_symbol.reset_common_symbol", fallback: "常用符号 - 恢复默认值")
      /// 符号键盘设置
      public static let title = L10n.tr("Localizable", "k_b.layout_symbol.title", fallback: "符号键盘设置")
    }
    public enum LayoutZh26 {
      /// 启用中英切换按键
      public static let displayChineseEnglishSwitchButton = L10n.tr("Localizable", "k_b.layout_zh26.displayChineseEnglishSwitchButton", fallback: "启用中英切换按键")
      /// 启用符号按键
      public static let displayClassifySymbolButton = L10n.tr("Localizable", "k_b.layout_zh26.displayClassifySymbolButton", fallback: "启用符号按键")
      /// 启用分号按键
      public static let displaySemicolonButton = L10n.tr("Localizable", "k_b.layout_zh26.displaySemicolonButton", fallback: "启用分号按键")
      /// 启用空格左侧按键
      public static let displaySpaceLeftButton = L10n.tr("Localizable", "k_b.layout_zh26.displaySpaceLeftButton", fallback: "启用空格左侧按键")
      /// 启用空格右侧按键
      public static let displaySpaceRightButton = L10n.tr("Localizable", "k_b.layout_zh26.displaySpaceRightButton", fallback: "启用空格右侧按键")
      /// 左侧按键键值
      public static let keyValueOfSpaceLeftButton = L10n.tr("Localizable", "k_b.layout_zh26.keyValueOfSpaceLeftButton", fallback: "左侧按键键值")
      /// 右侧按键键值
      public static let keyValueOfSpaceRightButton = L10n.tr("Localizable", "k_b.layout_zh26.keyValueOfSpaceRightButton", fallback: "右侧按键键值")
      /// 设置
      public static let segmentSettings = L10n.tr("Localizable", "k_b.layout_zh26.segment_settings", fallback: "设置")
      /// 划动设置
      public static let segmentSwipe = L10n.tr("Localizable", "k_b.layout_zh26.segment_swipe", fallback: "划动设置")
      /// 显示大写字母
      public static let showUppercasedCharacterOnChineseKeyboard = L10n.tr("Localizable", "k_b.layout_zh26.showUppercasedCharacterOnChineseKeyboard", fallback: "显示大写字母")
      /// 左侧按键由RIME处理
      public static let spaceLeftButtonProcessByRIME = L10n.tr("Localizable", "k_b.layout_zh26.spaceLeftButtonProcessByRIME", fallback: "左侧按键由RIME处理")
      /// 右侧按键由RIME处理
      public static let spaceRightButtonProcessByRIME = L10n.tr("Localizable", "k_b.layout_zh26.spaceRightButtonProcessByRIME", fallback: "右侧按键由RIME处理")
      /// 按键位于空格左侧
      public static let switchOnLeftOfSpace = L10n.tr("Localizable", "k_b.layout_zh26.switch_on_left_of_space", fallback: "按键位于空格左侧")
      /// “按键位于空格左侧”选项：关闭状态则位于空格右侧，开启状态则位于空格左侧
      public static let switchOnLeftOfSpaceRemark = L10n.tr("Localizable", "k_b.layout_zh26.switch_on_left_of_space_remark", fallback: "“按键位于空格左侧”选项：关闭状态则位于空格右侧，开启状态则位于空格左侧")
      public enum SwipeKey {
        /// 新增滑动Action
        public static let addKeySwipeAction = L10n.tr("Localizable", "k_b.layout_zh26.swipe_key.add_key_swipe_action", fallback: "新增滑动Action")
        /// %@已经存在
        public static func keyExist(_ p1: Any) -> String {
          return L10n.tr("Localizable", "k_b.layout_zh26.swipe_key.key_exist", String(describing: p1), fallback: "%@已经存在")
        }
        /// 字符
        public static let title = L10n.tr("Localizable", "k_b.layout_zh26.swipe_key.title", fallback: "字符")
      }
    }
    public enum LayoutZh9grid {
      public enum SymbolEdit {
        /// 左侧划动符号栏
        public static let title = L10n.tr("Localizable", "k_b.layout_zh9grid.symbol_edit.title", fallback: "左侧划动符号栏")
      }
    }
    public enum SwipeSetting {
      /// 新增滑动
      public static let addSwipe = L10n.tr("Localizable", "k_b.swipe_setting.add_swipe", fallback: "新增滑动")
      /// 字符
      public static let character = L10n.tr("Localizable", "k_b.swipe_setting.character", fallback: "字符")
      /// 自定义键盘名称
      public static let customKeyboardName = L10n.tr("Localizable", "k_b.swipe_setting.custom_keyboard_name", fallback: "自定义键盘名称")
      /// 确认删除
      public static let deleteConfirm = L10n.tr("Localizable", "k_b.swipe_setting.delete_confirm", fallback: "确认删除")
      /// 划动方向
      public static let direction = L10n.tr("Localizable", "k_b.swipe_setting.direction", fallback: "划动方向")
      /// 划动方向:%@ 配置已存在
      public static func directionExists(_ p1: Any) -> String {
        return L10n.tr("Localizable", "k_b.swipe_setting.direction_exists", String(describing: p1), fallback: "划动方向:%@ 配置已存在")
      }
      /// 字符修改
      public static let editCharacter = L10n.tr("Localizable", "k_b.swipe_setting.edit_character", fallback: "字符修改")
      /// 快捷指令修改
      public static let editCommand = L10n.tr("Localizable", "k_b.swipe_setting.edit_command", fallback: "快捷指令修改")
      /// 是否显示文本
      public static let isShowingText = L10n.tr("Localizable", "k_b.swipe_setting.is_showing_text", fallback: "是否显示文本")
      /// 退格键
      public static let keyNameBackspace = L10n.tr("Localizable", "k_b.swipe_setting.key_name_backspace", fallback: "退格键")
      /// 回车键
      public static let keyNameReturn = L10n.tr("Localizable", "k_b.swipe_setting.key_name_return", fallback: "回车键")
      /// Shift
      public static let keyNameShift = L10n.tr("Localizable", "k_b.swipe_setting.key_name_shift", fallback: "Shift")
      /// 空格
      public static let keyNameSpace = L10n.tr("Localizable", "k_b.swipe_setting.key_name_space", fallback: "空格")
      /// 按键操作
      public static let keyOperation = L10n.tr("Localizable", "k_b.swipe_setting.key_operation", fallback: "按键操作")
      /// 划动Action不能为空
      public static let noAction = L10n.tr("Localizable", "k_b.swipe_setting.no_action", fallback: "划动Action不能为空")
      /// 字符不能为空
      public static let noCharacter = L10n.tr("Localizable", "k_b.swipe_setting.no_character", fallback: "字符不能为空")
      /// 无对应的键盘类型
      public static let noCorrespondingKbType = L10n.tr("Localizable", "k_b.swipe_setting.no_corresponding_kb_type", fallback: "无对应的键盘类型")
      /// 是否经过 RIME 处理
      public static let processByRIME = L10n.tr("Localizable", "k_b.swipe_setting.processByRIME", fallback: "是否经过 RIME 处理")
      /// 划动操作
      public static let swipeOperation = L10n.tr("Localizable", "k_b.swipe_setting.swipe_operation", fallback: "划动操作")
      /// 键盘切换
      public static let switchKeyboard = L10n.tr("Localizable", "k_b.swipe_setting.switch_keyboard", fallback: "键盘切换")
      /// 键盘显示文本
      public static let textDisplayed = L10n.tr("Localizable", "k_b.swipe_setting.text_displayed", fallback: "键盘显示文本")
      /// 显示文本
      public static let textPlaceholder = L10n.tr("Localizable", "k_b.swipe_setting.text_placeholder", fallback: "显示文本")
    }
    public enum Symbol {
      /// 未找到默认值
      public static let noDefaultConf = L10n.tr("Localizable", "k_b.symbol.no_default_conf", fallback: "未找到默认值")
      /// 未找到系统默认配置
      public static let noSysDefaultConf = L10n.tr("Localizable", "k_b.symbol.no_sys_default_conf", fallback: "未找到系统默认配置")
      /// 光标居中
      public static let segmentCursorBack = L10n.tr("Localizable", "k_b.symbol.segment_cursor_back", fallback: "光标居中")
      /// 成对上屏
      public static let segmentPairs = L10n.tr("Localizable", "k_b.symbol.segment_pairs", fallback: "成对上屏")
      /// 返回主键盘
      public static let segmentReturnToMainKeyboard = L10n.tr("Localizable", "k_b.symbol.segment_return_to_main_keyboard", fallback: "返回主键盘")
      /// 符号设置
      public static let title = L10n.tr("Localizable", "k_b.symbol.title", fallback: "符号设置")
    }
    public enum SymbolEdit {
      /// 我在这
      public static let here = L10n.tr("Localizable", "k_b.symbol_edit.here", fallback: "我在这")
      /// 点我添加新符号(回车键保存)。
      public static let tap2add = L10n.tr("Localizable", "k_b.symbol_edit.tap2add", fallback: "点我添加新符号(回车键保存)。")
      /// 点击行可编辑/划动可删除
      public static let tap2editOrSwipe2delete = L10n.tr("Localizable", "k_b.symbol_edit.tap2edit_or_swipe2delete", fallback: "点击行可编辑/划动可删除")
      public enum Reset {
        /// 恢复默认值
        public static let title = L10n.tr("Localizable", "k_b.symbol_edit.reset.title", fallback: "恢复默认值")
      }
    }
    public enum TypeOption {
      /// 英文键盘
      public static let alphabetic = L10n.tr("Localizable", "k_b.type_option.alphabetic", fallback: "英文键盘")
      /// 中文26键键盘
      public static let chinese = L10n.tr("Localizable", "k_b.type_option.chinese", fallback: "中文26键键盘")
      /// 中文九宫格键盘
      public static let chineseNineGrid = L10n.tr("Localizable", "k_b.type_option.chineseNineGrid", fallback: "中文九宫格键盘")
      /// 分类符号键盘
      public static let classifySymbolic = L10n.tr("Localizable", "k_b.type_option.classifySymbolic", fallback: "分类符号键盘")
      /// 自定义键盘
      public static let custom = L10n.tr("Localizable", "k_b.type_option.custom", fallback: "自定义键盘")
      /// 数字九宫格键盘
      public static let numericNineGrid = L10n.tr("Localizable", "k_b.type_option.numericNineGrid", fallback: "数字九宫格键盘")
    }
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
