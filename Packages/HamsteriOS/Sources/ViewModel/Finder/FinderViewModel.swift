//
//  File.swift
//
//
//  Created by morse on 2023/7/7.
//

import Combine
import Foundation
import HamsterModel
import HamsterUIKit
import os
import ProgressHUD
import UIKit

public enum FinderSegmentAction {
  case settings
  case appFiles
  case appGroupFiles
  case iCloudFiles
}

public class FinderViewModel: ObservableObject {
  // MARK: properties

  private let logger = Logger(subsystem: "com.ihsiao.apps.Hamster.HamsteriOS", category: "FinderViewModel")
  private let configuration: HamsterConfiguration

  public var segmentActionPublished: AnyPublisher<FinderSegmentAction, Never> {
    segmentActionSubject.eraseToAnyPublisher()
  }

  private var segmentActionSubject = CurrentValueSubject<FinderSegmentAction, Never>(.settings)

  public var presentTextEditorPublished: AnyPublisher<URL, Never> {
    presentTextEditorSubject.eraseToAnyPublisher()
  }

  private let presentTextEditorSubject = PassthroughSubject<URL, Never>()

  public var conformPublished: AnyPublisher<Conform, Never> {
    conformSubject.eraseToAnyPublisher()
  }

  private let conformSubject = PassthroughSubject<Conform, Never>()

  public var enableAppleCloud: Bool {
    configuration.general?.enableAppleCloud ?? false
  }

  var regexOnCopyAppGroupDictFile: [String] {
    configuration.rime?.regexOnCopyAppGroupDictFile ?? ["^.*[.]userdb.*$", "^.*[.]txt$"]
  }

  // MARK: methods

  init(configuration: HamsterConfiguration) {
    self.configuration = configuration
  }

  @objc func segmentChangeAction(sender: UISegmentedControl) {
    switch sender.selectedSegmentIndex {
    case 0:
      segmentActionSubject.send(.settings)
    case 1:
      segmentActionSubject.send(.appFiles)
    case 2:
      segmentActionSubject.send(.appGroupFiles)
    case 3:
      segmentActionSubject.send(.iCloudFiles)
    default:
      return
    }
  }

  public func openFileEditorController(fileURL: URL) {
    presentTextEditorSubject.send(fileURL)
  }

  public func deleteFileConform(completion: @escaping () -> Void) {
    conformSubject.send(Conform(title: "是否删除？", message: "文件删除后无法恢复，确认删除？", okAction: completion))
  }

  public func overrideDirectoryConform(completion: @escaping () -> Void) {
    conformSubject.send(Conform(title: "是否覆盖？", message: "覆盖后应用文件无法恢复，确认覆盖？", okAction: completion))
  }

  /// 拷贝 AppGroup 下词库文件至应用沙盒目录
  public func copyAppGroupDictFileToAppDocument() async throws {
    await ProgressHUD.show("拷贝中……", interaction: true)
    do {
      try FileManager.copyAppGroupUserDict(regexOnCopyAppGroupDictFile)
    } catch {
      throw error
    }
    await ProgressHUD.showSuccess("拷贝词库成功", delay: 1.5)
  }

  /// 使用键盘文件覆盖应用沙盒文件
  public func overrideAppDocument() async throws {
    await ProgressHUD.show("覆盖中……", interaction: true)
    do {
      // 使用AppGroup下文件覆盖应用Sandbox下文件
      try FileManager.syncAppGroupSharedSupportDirectoryToSandbox(override: true)
      try FileManager.syncAppGroupUserDataDirectoryToSandbox(override: true)
    } catch {
      throw error
    }
    await ProgressHUD.showSuccess("完成", delay: 1.5)
  }
}
