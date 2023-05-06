//
//  FileView.swift
//  HamsterApp
//
//  Created by morse on 4/4/2023.
//

import Foundation
import SwiftUI

struct FileURL: Identifiable {
  let id = UUID()
  let url: URL
  let fileResourceType: URLFileResourceType?
}

struct FinderView: View {
  let finderURL: URL
  @State var pathStack: [String] = []
  @State var selectFileURL: FileURL?
  @State var selectIdx: IndexSet?
  @State var showDeleteAlert = false
  @State var fileList: [FileURL] = []
  @State var selectFileList: Set<UUID> = []
  @Environment(\.editMode) var editMode

  func getFileURLs() -> [FileURL] {
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
      .map { FileURL(url: $0, fileResourceType: try? $0.resourceValues(forKeys: [.fileResourceTypeKey]).fileResourceType) }
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
        Text("路径: \(path)")
          .lineLimit(1)
          .minimumScaleFactor(0.5)
          .multilineTextAlignment(.leading)
        Spacer()
        Button {
          // 编辑模式
          if editMode?.wrappedValue.isEditing == true {
            return
          }

          _ = pathStack.popLast()
          fileList = getFileURLs()

        } label: {
          Text("上一层目录")
        }
        .disabled(pathStack.count == 0)
      }
      .padding(.horizontal)

      List(selection: $selectFileList) {
        ForEach(fileList, id: \.id) { file in
          FileCellView(
            fileResourceType: file.fileResourceType,
            fileName: file.url.lastPathComponent
          ) {
            // 编辑模式
            if editMode?.wrappedValue.isEditing == true {
              return
            }

            guard let fileResourceType = file.fileResourceType else { return }
            if fileResourceType == .directory {
              pathStack.append(file.url.lastPathComponent)
              fileList = getFileURLs()
              return
            }
            if fileResourceType == .regular {
              selectFileURL = file
            }
          }
          .listRowBackground(Color.HamsterBackgroundColor)
          .padding(.horizontal)
          .disabled(editMode?.wrappedValue.isEditing == true)
        }
//        .onDelete(perform: { idx in
//          // 编辑模式
//          if editMode?.wrappedValue.isEditing == true {
//            return
//          }
//
//          selectIdx = idx
//          showDeleteAlert = true
//        })
        .alert(isPresented: $showDeleteAlert) {
          Alert(
            title: Text("是否确认删除？"),
            primaryButton: .destructive(Text("删除")) {
              // 多选删除
              if editMode?.wrappedValue.isEditing == true {
                if selectFileList.count == 0 {
                  return
                }
                for file in fileList {
                  if selectFileList.contains(file.id) {
                    try? FileManager.default.removeItem(at: file.url)
                  }
                }
                selectFileList = []
                fileList = getFileURLs()
                editMode?.wrappedValue = .inactive
                return
              }

              // 单选删除
              guard let selectIdx = selectIdx else { return }
              selectIdx.forEach { idx in
                if fileList.count > idx {
                  try? FileManager.default.removeItem(at: fileList[idx].url)
                }
              }
              fileList = getFileURLs()
            },
            secondaryButton: .cancel(Text("取消")) {
              selectIdx = nil
            }
          )
        }
      }
      .toolbar {
        // 多选编辑
        ToolbarItem(placement: .navigationBarTrailing) {
          HStack {
            EditButton()
            if editMode?.wrappedValue.isEditing == true {
              Button {
                if selectFileList.count == 0 {
                  
                  return
                }
                showDeleteAlert = true
              } label: {
                Image(systemName: "trash")
                  .font(.system(size: 20))
                  .foregroundColor(Color.red)
              }
            }
          }
        }
      }
      .listStyle(.plain)
      .background(Color.HamsterBackgroundColor)
      .modifier(ListBackgroundModifier())
    }
    .fullScreenCover(item: $selectFileURL) { fileURL in
      FileEditorView(fileURL: fileURL.url)
    }
    .onAppear {
      fileList = getFileURLs()
    }
  }
}

struct FileEditorView: View {
  let fileURL: URL
  @State var fileContent: String
  @State var isSave = false
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
    let fileName = fileURL.lastPathComponent
    if fileName.hasSuffix(".yaml") {
      return .yaml
    }
    if fileName.hasSuffix(".lua") {
      return .lua
    }
    return .notSupported
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
          dismiss()
          isSave = true
        } label: {
          Text("保存")
        }
      }
      .padding(.horizontal)
      .padding(.top)

      TextEditorView(fileType: fileType, fileContent: $fileContent)
        .onDisappear {
          do {
            if isSave {
              try fileContent.write(toFile: fileURL.path, atomically: true, encoding: .utf8)
              Logger.shared.log.debug("TextEditorView save success")
            }
          } catch {
            Logger.shared.log.error("TextEditorView save error: \(error.localizedDescription)")
          }
        }
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
