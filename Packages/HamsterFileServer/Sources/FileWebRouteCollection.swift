//
//  FileWebRouteCollection.swift
//  LearnVapor
//
//  Created by morse on 8/3/2023.
//

import Vapor
import ZIPFoundation

struct FileWebRouteCollection: RouteCollection {
  let rootDocumentDirectory: URL
  // let rootDocumentDirectory =

  // #available(iOS 15, *) URL.documentsDirectory
  init(
    publicDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  ) {
    rootDocumentDirectory = publicDirectory
  }

  func boot(routes: RoutesBuilder) throws {
    routes.get("", use: indexHandler)
    routes.get("files", use: {
      $0.redirect(to: "/")
    })
    routes.get("files", "**", use: {
      $0.redirect(to: "/")
    })
    routes.group("api") { api in
      // 容量信息
      api.get("usage", use: usageHandler)
      api.get("usage", "**", use: usageHandler)

      // 资源信息
      api.get("resources", use: resourcesHandler)
      api.get("resources", "**", use: resourcesHandler)

      // 上传
      api.post("resources", "**", use: uploadFileHandler)

      // 下载
      api.get("raw", use: raw)
      api.get("raw", "**", use: raw)

      // 删除
      api.delete("resources", "**", use: deleteFileHandler)
    }
  }

  func indexHandler(_ req: Request) async throws -> Vapor.View {
    return try await req.view.render("index")
  }

  func usageHandler(_ req: Request) throws -> DirectoryUsageResponse {
    var response = DirectoryUsageResponse()
    let documentsDirectory = rootDocumentDirectory.appendingPathComponent(req.path)
    let fsInfo = try FileManager.default.attributesOfFileSystem(forPath: documentsDirectory.path)
    if let totalSize = fsInfo[.systemSize] as? NSNumber {
      response.total = totalSize.uintValue
    }
    if let freeSize = fsInfo[.systemFreeSize] as? NSNumber {
      response.used = response.total - freeSize.uintValue
    }
    return response
  }

  func resourcesHandler(_ req: Request) throws -> DirectoryResourcesResponse {
    let path = req.path
    let documentsDirectory = rootDocumentDirectory.appendingPathComponent(path)
    let fm = FileManager.default

    var result = try DirectoryResourcesResponse(documentsDirectory)
    result.name = documentsDirectory.lastPathComponent
    result.path = path
    result.isDir = true

    let directoryContent = try fm.contentsOfDirectory(
      at: documentsDirectory,
      includingPropertiesForKeys: nil,
      options: .skipsSubdirectoryDescendants
    )

    let items =
      try directoryContent
        .sorted(by: { $0.path < $1.path })
        .map {
          var dir = try DirectoryResourcesResponse($0)
          dir.path = result.path + dir.name
          return dir
        }

    result.numFiles = items.reduce(UInt(0)) { $0 + ($1.isDir ? 0 : 1) }
    result.numDirs = UInt(directoryContent.count) - result.numFiles!
    result.items = items
    // TODO:
    result.sorting = DirectorySortBy(by: "name", asc: false)

    return result
  }

  func uploadFileHandler(_ req: Request) throws -> Response {
    let override: Bool = req.query["override"] ?? false
    let path = req.path

    req.logger.debug("parameter path: \(path)")
    req.logger.debug("parameter override: \(override)")

    // just create directory
    if path.hasSuffix("/") {
      let directoryURL = rootDocumentDirectory.appendingPathComponent(path, isDirectory: true)
      try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
      return Response(status: .ok)
    }

    let fileURL = rootDocumentDirectory.appendingPathComponent(path, isDirectory: false)
    let directoryURL = fileURL.deletingLastPathComponent()
    if !FileManager.default.fileExists(atPath: directoryURL.path) {
      try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }

    if FileManager.default.fileExists(atPath: fileURL.path) && !override {
      req.logger.debug("\(fileURL.path) file exists")
      return Response(status: .ok)
    }

    guard let buffer = req.body.data else { return .init(status: .noContent) }
    // https://docs.vapor.codes/advanced/files/
    // https://theswiftdev.com/file-upload-api-server-in-vapor-4/
    do {
      try Data(buffer: buffer).write(to: fileURL)
    } catch {
      req.logger.error("upload error: \(error)")
    }
    return Response(status: .ok, headers: .init(), body: .empty)
  }

  // 文件下载
  func raw(_ req: Request) throws -> Response {
    let path = req.path

    // TODO: 目前只支持zip算法压缩, 可以通过此参数扩展下载格式
    // let algo: String = req.query["alog"] ?? "zip"

    let fileNames: String? = req.query["files"]
    let fm = FileManager()

    if path == "/" && fileNames == nil {
      throw Abort(.badRequest)
    }

    // this will hold the URL of the zip file
    let archiveUrl = try URL(
      fileURLWithPath: fm.url(
        for: .cachesDirectory,
        in: .userDomainMask,
        appropriateFor: rootDocumentDirectory,
        create: true
      )
      .path
    )
    .appendingPathComponent("export.zip", isDirectory: false)

    // 检测文件是否存在
    if fm.fileExists(atPath: archiveUrl.path) {
      try fm.removeItem(at: archiveUrl)
    }

    req.logger.debug("download temp url \(archiveUrl)")

    if let fileNames = fileNames {
      guard let archive = Archive(url: archiveUrl, accessMode: .create) else {
        throw Abort(.internalServerError, reason: "archive zip file error")
      }
      for fileName in fileNames.components(separatedBy: ",") {
        let fileURL =
          rootDocumentDirectory
            .appendingPathComponent(path)
            .appendingPathComponent(fileName)

        if !fm.isDirectory(fileURL) {
          try archive.addEntry(
            with: fileURL.lastPathComponent, relativeTo: fileURL.deletingLastPathComponent()
          )
          continue
        }

        let subPaths = try fm.subpathsOfDirectory(atPath: fileURL.path)
        let directoryPrefix = fileURL.lastPathComponent
        for entryPath in subPaths {
          let finalEntryPath = directoryPrefix + "/" + entryPath
          let finalBaseURL = fileURL.deletingLastPathComponent()
          try archive.addEntry(with: finalEntryPath, relativeTo: finalBaseURL)
        }
      }
    } else {
      try fm.zipItem(
        at: rootDocumentDirectory.appendingPathComponent(path, isDirectory: true),
        to: archiveUrl
      )
    }

    return req.fileio.streamFile(at: archiveUrl.path)
  }

  func deleteFileHandler(_ req: Request) throws -> Response {
    let path = req.path

    req.logger.debug("delete path: \(path)")

    if path.isEmpty {
      throw Abort(.badRequest)
    }

    let fileURL = rootDocumentDirectory.appendingPathComponent(path)
    try FileManager.default.removeItem(at: fileURL)

    return req.redirect(to: "/")
  }
}

struct DirectoryUsageResponse: Content {
  var used: UInt = 0
  var total: UInt = 0
}

struct DirectoryResourcesResponse: Content {
  var path = ""
  var name = ""
  var size: UInt64 = 0
  var `extension` = ""
  var modified: Date = .init()
  var mode: UInt64 = 0
  var isDir: Bool = true
  var isSymlink: Bool = false
  var type = ""
  var numDirs: UInt?
  var numFiles: UInt?
  var sorting: DirectorySortBy?
  var items: [DirectoryResourcesResponse]?
}

extension DirectoryResourcesResponse {
  init(_ directory: URL) throws {
    let fileInfos = try directory.resourceValues(forKeys: [
      .contentModificationDateKey,
      .fileSizeKey,
      .isDirectoryKey,
      .isSymbolicLinkKey,
      .fileResourceTypeKey,
    ])

    name = directory.lastPathComponent
    path = directory.path
    self.extension = directory.pathExtension.isEmpty ? "" : "." + directory.pathExtension

    if let modificationDate = fileInfos.contentModificationDate {
      modified = modificationDate
    }

    if let fileSize = fileInfos.fileSize {
      size = UInt64(fileSize)
    }

    let fileAttr = try FileManager.default.attributesOfItem(atPath: directory.path)
    if let permissions = fileAttr[FileAttributeKey.posixPermissions] {
      mode = permissions as! UInt64
    }

    isDir = fileInfos.isDirectory == true
    isSymlink = fileInfos.isSymbolicLink == true
    if let fileResourceType = fileInfos.fileResourceType {
      switch fileResourceType {
      case .directory:
        type = ""
      case .regular:
        type = "text"
      case .blockSpecial:
        type = "blob"
      default:
        type = ""
      }
    }
  }
}

struct DirectorySortBy: Content {
  var by = "name"
  var asc = false
}

extension Response {
  static let OK = Response(status: .ok)
}

extension Request {
  var path: String {
    var path = parameters.getCatchall().joined(separator: "/")
    if !path.contains(".") && !path.hasSuffix("/") {
      path = path + "/"
    }
    if !path.hasPrefix("/") {
      path = "/" + path
    }
    return path
  }
}

extension FileManager {
  func isDirectory(_ path: URL) -> Bool {
    var isDirectory: ObjCBool = false
    if fileExists(atPath: path.path, isDirectory: &isDirectory) && isDirectory.boolValue {
      return true
    }
    return false
  }
}
