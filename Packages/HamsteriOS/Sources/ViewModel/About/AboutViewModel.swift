//
//  File.swift
//
//
//  Created by morse on 2023/7/7.
//

import Combine
import HamsterKeyboardKit
import HamsterKit
import ProgressHUD
import UIKit

public class AboutViewModel: ObservableObject {
  init() {}

  @Published
  public var displayOpenSourceView = false

  private let restUISettingsSubject = PassthroughSubject<() -> Void, Never>()
  public var restUISettingsPublished: AnyPublisher<() -> Void, Never> {
    restUISettingsSubject.eraseToAnyPublisher()
  }

  private let exportConfigurationSubject = PassthroughSubject<URL, Never>()
  public var exportConfigurationPublished: AnyPublisher<URL, Never> {
    exportConfigurationSubject.eraseToAnyPublisher()
  }

  lazy var settingItems: [SettingSectionModel] = [
    .init(items: [
      .init(text: "RIME版本", secondaryText: AppInfo.rimeVersion, type: .settings, buttonAction: {
        UIPasteboard.general.string = AppInfo.rimeVersion
        await ProgressHUD.success("复制成功", interaction: false, delay: 1.5)
      }),
      .init(text: "许可证", secondaryText: "GPLv3", type: .settings, buttonAction: {
        let link = "https://www.gnu.org/licenses/gpl-3.0.html"
        if let url = URL(string: link) {
          DispatchQueue.main.async {
            UIApplication.shared.open(url)
          }
        }
      }),
      .init(text: "联系邮箱", secondaryText: "morse.hsiao@gmail.com", type: .settings, buttonAction: {
        let link = "morse.hsiao@gmail.com"
        if let url = URL(string: "mailto:\(link)") {
          DispatchQueue.main.async {
            UIApplication.shared.open(url)
          }
        }
      }),
      .init(text: "开源地址", secondaryText: "https://github.com/imfuxiao/Hamster", type: .settings, buttonAction: {
        let link = "https://github.com/imfuxiao/Hamster"
        if let url = URL(string: link) {
          DispatchQueue.main.async {
            UIApplication.shared.open(url)
          }
        }
      }),
      .init(text: "使用开源库列表", accessoryType: .disclosureIndicator, type: .navigation, navigationAction: { [unowned self] in displayOpenSourceView = true })
    ]),

    .init(
      footer: "重置通过界面修改的配置项。\n注意：不包含新增/修改配置文件中的配置项。",
      items: [
        .init(text: "重置界面设置", textTintColor: .systemRed, type: .button, buttonAction: { [unowned self] in
          self.restUISettingsSubject.send {
            HamsterAppDependencyContainer.shared.resetAppConfiguration()
          }
        })
      ]),

    .init(
      footer: "导出的通过界面修改的配置项。\n注意：不包新增/修改配置文件中的设置。",
      items: [
        .init(text: "导出界面设置", type: .button, buttonAction: { [unowned self] in
          let appConfig = HamsterAppDependencyContainer.shared.applicationConfiguration
          let url = FileManager.hamsterAppConfigFileOnUserData
          do {
            try HamsterConfigurationRepositories.shared.saveToYAML(config: appConfig, path: url)
            exportConfigurationSubject.send(url)
          } catch {
            await ProgressHUD.failed("导出 UI 设置失败")
          }
        })
      ])
//    .init(
//      footer: "应用设置：指当前应用全部设置，包含 UI 交互产生的设置及自定义配置文件中的设置。\n导出文件默认存放在 `Rime/hamster.all.yaml` 中，但不会对应用有任何作用。",
//      items: [
//        .init(text: "导出应用设置", type: .button, buttonAction: { [unowned self] in
//          let config = HamsterAppDependencyContainer.shared.configuration
//          let url = FileManager.hamsterAllConfigFileOnUserData
//          do {
//            try HamsterConfigurationRepositories.shared.saveToYAML(config: config, yamlPath: url)
//            exportConfigurationSubject.send(url)
//          } catch {
//            await ProgressHUD.failed("导出 UI 设置失败")
//          }
//        })
//      ])
  ]
}
