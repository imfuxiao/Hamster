//
//  FileView.swift
//  HamsterApp
//
//  Created by morse on 4/4/2023.
//

import Foundation
import SwiftUI

private struct FileURL: Identifiable {
  let id = UUID()
  let url: URL
}

struct FinderView: View {
  let finderURL: URL
  @State var pathStack: [String] = []
  @State fileprivate var selectFileURL: FileURL?

  var urls: [URL] {
    do {
      let urls = try FileManager.default.contentsOfDirectory(
        at: finderURL.appendingPathComponent(pathStack.joined(separator: "/")),
        includingPropertiesForKeys: [.fileResourceTypeKey, .isDirectoryKey],
        options: [.skipsHiddenFiles]
      )
      // 按字母顺序排序, 文件夹优先
      return urls.sorted(by: {
        let firstIsDirectory = (try? $0.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
        let secondIsDirectory = (try? $1.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
        // 同是文件夹，则按字母排序
        if firstIsDirectory, secondIsDirectory {
          return $0.lastPathComponent < $1.lastPathComponent
        }
        // 1是文件夹，2是文件，则不需排序
        if firstIsDirectory, !secondIsDirectory {
          return true
        }
        // 2是文件夹，1是文件，则需要排序
        if secondIsDirectory, !firstIsDirectory {
          return false
        }
        // 都是文件则按字母顺序排序
        return $0.lastPathComponent < $1.lastPathComponent
      })
    } catch {
      Logger.shared.log.error("FinderView currentURL get error: \(error.localizedDescription)")
      return []
    }
  }

  var path: String {
    "/" + pathStack.joined(separator: "/")
  }

  var body: some View {
    VStack {
      HStack {
        Spacer()
      }
      .padding(.horizontal)

      HStack {
        Text("当前路径: \(path)")
          .lineLimit(2)
          .multilineTextAlignment(.leading)
        Spacer()
      }
      .padding(.horizontal)

      ScrollView {
        ForEach(urls, id: \.path) { url in
          VStack(spacing: 0) {
            if let fileResourceType =
              try? url.resourceValues(forKeys: [.fileResourceTypeKey]).fileResourceType
            {
              FileCellView(
                fileResourceType: fileResourceType,
                fileName: url.lastPathComponent,
                tapCallback: {
                  tapCallback(fileURL: url, fileResourceType: fileResourceType)
                }
              )
            } else {
              FileCellView(
                fileResourceType: nil,
                fileName: url.lastPathComponent,
                tapCallback: {}
              )
            }
          }
          .padding(.horizontal)
          // VStack
        }
        // ForEach
      }
      // ScrollView
    }
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          _ = pathStack.popLast()
        } label: {
          Text("上一层目录")
        }
        .disabled(pathStack.count == 0)
      }
    }
    .fullScreenCover(item: $selectFileURL) { fileURL in
      FileEditorView(fileURL: fileURL.url)
    }
  }

  func tapCallback(fileURL: URL, fileResourceType: URLFileResourceType) {
    if fileResourceType == .directory {
      pathStack.append(fileURL.lastPathComponent)
      return
    }
    if fileResourceType == .regular {
      selectFileURL = FileURL(url: fileURL)
    }
  }
}

struct FileEditorView: View {
  let fileURL: URL
  @State var fileContent: String
  @Environment(\.dismiss) var dismiss

  init(fileURL: URL) {
    self.fileURL = fileURL
    do {
      let content = try String(contentsOfFile: fileURL.path)
      Logger.shared.log.debug("read success: \(fileURL.path)")
      self._fileContent = State(initialValue: content)
    } catch {
      Logger.shared.log.debug("read error: \(fileURL.path)")
      self._fileContent = State(initialValue: "")
    }
  }

  var fileType: FileType {
    fileURL.lastPathComponent.hasSuffix(".yaml") ? .yaml : .notSupported
  }

  var body: some View {
    VStack {
      HStack {
        Button {
          dismiss()
        } label: {
          Text("取消")
        }

        Spacer()

        Button {
          print("button \(fileContent)")
          FileManager.default.createFile(atPath: fileURL.path, contents: fileContent.data(using: .utf8))
          dismiss()
        } label: {
          Text("保存")
        }
      }
      .padding(.horizontal)
      .padding(.top)

      TextEditorView(fileType: fileType, fileContent: $fileContent)
    }
  }
}

struct FileCellView: View {
  var fileResourceType: URLFileResourceType?
  let fileName: String
  let tapCallback: () -> Void
  var body: some View {
    HStack {
      if let fileResourceType = fileResourceType {
        if fileResourceType == URLFileResourceType.directory {
          Image(systemName: "folder")
        } else if fileResourceType == URLFileResourceType.regular {
          Image(systemName: "doc.plaintext")
        } else {
          Image(systemName: "camera.metering.unknown")
        }
      } else {
        Image(systemName: "camera.metering.unknown")
      }
      Text(fileName)
        .font(.system(size: 18))
        .lineLimit(1)
        .multilineTextAlignment(.leading)
      Spacer()
    }
    .frame(minHeight: 40)
    .contentShape(Rectangle())
    .onTapGesture {
      tapCallback()
    }
  }
}

struct Preview_FinderView: PreviewProvider {
  static var previews: some View {
    VStack {
//      FinderView(
//        finderURL: URL(string: "/Users/morse/Downloads/rimeTestResources")!
//      )
      FinderView(
        finderURL: URL(string: "/Users/morse/Downloads/rime")!
      )
    }
  }
}
