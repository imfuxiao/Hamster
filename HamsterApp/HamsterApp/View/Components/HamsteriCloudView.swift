//
//  HamsteriCloud.swift
//  HamsterApp
//
//  Created by morse on 24/4/2023.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

/// 用于读取导入的iCloud文件
class HamsterDocument: FileDocument {
  static var readableContentTypes: [UTType] {
    [.zip, .plist, .yaml]
  }

  var fileName: String
  var data: Data

  init(fileName: String = "", data: Data = Data()) {
    self.fileName = fileName
    self.data = data
  }

  required init(configuration: ReadConfiguration) throws {
    guard let filename = configuration.file.filename else {
      throw CocoaError(.fileReadInvalidFileName)
    }
    guard let data = configuration.file.regularFileContents else {
      throw CocoaError(.fileReadCorruptFile)
    }
    self.data = data
    self.fileName = filename
  }

  func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
    return FileWrapper(regularFileWithContents: data)
  }
}

/// iCloud导入导出组件
struct HamsteriCloudView: View {
  typealias ImportingCallback = (HamsterDocument) -> Void
  typealias ExportingCallback = (Result<URL, Error>) -> Void
  @State var document: HamsterDocument = .init()
  @State var needExporter: Bool = false
  @State var isImporting: Bool = false
  @State var isExporting: Bool = false
  
  @Binding var isShow: Bool
  @Binding var isShowMessage: Bool
  @Binding var showMessage: String

  @Environment(\.dismiss) var dismiss
  @Environment(\.colorScheme) var colorScheme

  var contentType: UTType
  var importingCallback: ImportingCallback?
  var exportingCallback: ExportingCallback?

  var body: some View {
    SheetView(isShow: $isShow, isShowMessage: $isShowMessage, showMessage: $showMessage) {
      VStack(spacing: 0) {
        Section {
          SectionButton(image: "arrow.down.doc.fill", title: "iCloud") {
            if isImporting {
              // TODO: 修复了在使用.fileImporter()时下拉隐藏，没有复位的bug
              // 需要等待苹果修复此bug
              isImporting = false
              DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isImporting = true
              }
            } else {
              isImporting = true
            }
          }

          // TODO: 添加其他云的支持
        } header: {
          SectionTitle(title: "导入")
        }

        if needExporter {
          Section {
            SectionButton(image: "arrow.up.doc.fill", title: "iCloud") {
              isExporting = true
            }

            // TODO: 添加其他云的支持
          } header: {
            SectionTitle(title: "导出")
          }
        }
      }
      .frame(minWidth: 0, maxWidth: .infinity)
      .frame(minHeight: 0, maxHeight: .infinity)
      .padding(.horizontal)
      .fileImporter(
        isPresented: $isImporting,
        allowedContentTypes: [contentType],
        allowsMultipleSelection: false
      ) { result in
        do {
          guard let selectFile: URL = try result.get().first else { return }

          // 注意使用URL前需要先获取权限，且读取结束后关闭，两条语句必须成对出现
          // guard selectFile.startAccessingSecurityScopedResource() else { return }
          // ...
          // selectFile.stopAccessingSecurityScopedResource()
          guard selectFile.startAccessingSecurityScopedResource() else { return }

          document.fileName = selectFile.lastPathComponent
          try document.data = Data(contentsOf: selectFile)
          selectFile.stopAccessingSecurityScopedResource()

          self.importingCallback?(document)
        } catch {
          Logger.shared.log.error("HamsteriCloud importer error: \(error.localizedDescription)")
        }
        isImporting = false
      }
      .fileExporter(
        isPresented: $isExporting,
        document: document,
        contentType: contentType,
        defaultFilename: document.fileName
      ) { result in
        if case .success(let url) = result {
          Logger.shared.log.info("Hamster iCloud exporting success! \(url)")
        }

        if case .failure(let failure) = result {
          Logger.shared.log.info("Hamster iCloud exporting failure: \(failure.localizedDescription)")
        }

        self.exportingCallback?(result)
        isExporting = false
      }
    }
  }
}

struct SectionTitle: View {
  var title: String
  var body: some View {
    HStack(spacing: 0) {
      Text(title)
        .font(.system(size: 16, weight: .bold))
        .foregroundColor(.gray)

      Spacer()
    }
    .frame(height: 30)
  }
}

struct SectionButton: View {
  typealias Action = () -> Void
  var image: String
  var title: String
  var action: Action?
  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      Image(systemName: image)
        .font(.system(size: 30))
        .foregroundColor(.blue)
        .padding(5)
        .onTapGesture {
          Logger.shared.log.debug("section button import")
        }

      VStack(alignment: .center, spacing: 0) {
        HStack(alignment: .bottom, spacing: 0) {
          Text(title)
            .font(.system(size: 17))
            .foregroundColor(.primary)
            .padding(.leading, 10)

          Spacer()
        }
        Divider()
          .padding(.top, 15)
          .padding(.leading, 10)
      }

      Spacer()
    }
    .frame(minWidth: 0, maxWidth: .infinity)
    .frame(height: 50)
    .contentShape(Rectangle())
    .onTapGesture {
      Logger.shared.log.debug("section button import")
      action?()
    }
  }
}

extension UTType {
  static let plist = UTType(filenameExtension: "plist")!
}

struct HamsteriCloud_Previews: PreviewProvider {
  @State
  static var isShow = true

  static var previews: some View {
    HamsteriCloudView(
      needExporter: true,
      isShow: $isShow,
      isShowMessage: .constant(false),
      showMessage: .constant(""),
      contentType: .zip,
      importingCallback: { _ in },
      exportingCallback: { _ in }
    )
  }
}
