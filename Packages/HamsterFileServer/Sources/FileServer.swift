//
//  FileServer.swift
//
//  Created by morse on 8/3/2023.
//
import Foundation
import GCDWebServers
import ZIPFoundation

public class FileServer {
  private let port: Int
  private let publicDirectory: URL
  private var isRunning: Bool = false
  private let server: GCDWebServer
  private var staticBundle: Bundle?

  public init(port: Int, publicDirectory: URL) {
    self.port = port
    self.publicDirectory = publicDirectory
    self.server = GCDWebServer()

    // 服务端 HTML
    let bundle = Bundle.module
    if let bundlePath = bundle.path(forResource: "FileServer", ofType: "bundle") {
      staticBundle = Bundle(path: bundlePath)
    }
  }

  public func start() {
    // index page
    if let staticBundle = staticBundle, let path = staticBundle.path(forResource: "index", ofType: "html") {
      // 服务端资源
      server.addGETHandler(forBasePath: "/", directoryPath: staticBundle.resourcePath!, indexFilename: nil, cacheAge: 3600, allowRangeRequests: false)
      server.addHandler(forMethod: "GET", path: "/", request: GCDWebServerRequest.self, processBlock: { _ in
        GCDWebServerDataResponse(htmlTemplate: path, variables: [:])
      })
    }

    // files 开头的 URL 需要重定向
    server.addHandler(forMethod: "GET", pathRegex: "/files/*", request: GCDWebServerRequest.self, processBlock: { _ in
      GCDWebServerResponse(redirect: URL(string: "/")!, permanent: false)
    })

    // 容量信息
    server.addHandler(forMethod: "GET", pathRegex: "/api/usage/*", request: GCDWebServerRequest.self, processBlock: { [unowned self] req in
      usageHandler(req)
    })

    // 资源信息
    server.addHandler(forMethod: "GET", pathRegex: "/api/resources/*", request: GCDWebServerRequest.self, processBlock: { [unowned self] req in
      resourcesHandler(req)
    })

    // 上传
    server.addHandler(forMethod: "POST", pathRegex: "/api/resources/*", request: GCDWebServerDataRequest.self, processBlock: { [unowned self] req in
      uploadFileHandler(req)
    })
    server.addHandler(forMethod: "POST", pathRegex: "/api/tus/*", request: GCDWebServerDataRequest.self, processBlock: { [unowned self] req in
      uploadFileHandler(req)
    })
    server.addHandler(forMethod: "HEAD", pathRegex: "/api/tus/*", request: GCDWebServerDataRequest.self, processBlock: { [unowned self] req in
      tusHeadHandler(req)
    })
    server.addHandler(forMethod: "GET", pathRegex: "/api/tus/*", request: GCDWebServerDataRequest.self, processBlock: { [unowned self] req in
      tusHeadHandler(req)
    })
    server.addHandler(forMethod: "PATCH", pathRegex: "/api/tus/*", request: GCDWebServerDataRequest.self, processBlock: { [unowned self] req in
      tusPatchHandler(req)
    })

    // 下载
    server.addHandler(forMethod: "GET", pathRegex: "/api/raw/*", request: GCDWebServerDataRequest.self, processBlock: { [unowned self] req in
      download(req)
    })

    // 删除
    server.addHandler(forMethod: "DELETE", pathRegex: "/api/resources/*", request: GCDWebServerRequest.self, processBlock: { [unowned self] req in
      deleteFileHandler(req)
    })

    server.start(withPort: UInt(port), bonjourName: nil)
  }

  public func shutdown() {
    guard server.isRunning else { return }
    server.stop()
  }

  /// 容量信息
  private func usageHandler(_ req: GCDWebServerRequest) -> GCDWebServerDataResponse? {
    var path = "/"
    let reqPath = req.path
    if reqPath.hasPrefix("/api/usage") {
      path = String(reqPath.dropFirst("/api/usage".count))
    }
    let documentsDirectory = publicDirectory.appendingPathComponent(path)
    var response = DirectoryUsageResponse()
    do {
      let fsInfo = try FileManager.default.attributesOfFileSystem(forPath: documentsDirectory.path)
      if let totalSize = fsInfo[.systemSize] as? NSNumber {
        response.total = totalSize.uintValue
      }
      if let freeSize = fsInfo[.systemFreeSize] as? NSNumber {
        response.used = response.total - freeSize.uintValue
      }
      let data = try JSONEncoder().encode(response)
      return GCDWebServerDataResponse(data: data, contentType: "application/json")
    } catch {
      print(error.localizedDescription)
    }
    return nil
  }

  /// 资源信息
  func resourcesHandler(_ req: GCDWebServerRequest) -> GCDWebServerDataResponse? {
    var path = "/"
    let reqPath = req.path
    if reqPath.hasPrefix("/api/resources") {
      path = String(reqPath.dropFirst("/api/resources".count))
    }

    let documentsDirectory = publicDirectory.appendingPathComponent(path)
    let fm = FileManager.default
    var response: DirectoryResourcesResponse?
    do {
      response = try? DirectoryResourcesResponse(documentsDirectory)
      response?.name = documentsDirectory.lastPathComponent
      response?.path = path
      response?.isDir = true

      let directoryContent = try fm.contentsOfDirectory(
        at: documentsDirectory,
        includingPropertiesForKeys: nil,
        options: .skipsSubdirectoryDescendants
      )

      let items = try directoryContent
        .sorted(by: { $0.path < $1.path })
        .map {
          var dir = try DirectoryResourcesResponse($0)
          dir.path = response?.path ?? "" + dir.name
          return dir
        }

      let numFiles = items.reduce(UInt(0)) { $0 + ($1.isDir ? 0 : 1) }
      response?.numDirs = UInt(directoryContent.count) - numFiles
      response?.numFiles = numFiles
      response?.items = items
      response?.sorting = DirectorySortBy(by: "name", asc: false)

      let data = try JSONEncoder().encode(response)
      return GCDWebServerDataResponse(data: data, contentType: "application/json")
    } catch {
      print(error.localizedDescription)
    }
    return nil
  }

  /// 上传文件
  func uploadFileHandler(_ req: GCDWebServerRequest) -> GCDWebServerResponse? {
    let override: Bool = (req.query?["override"] ?? "false") == "true"

    var path = "/"
    let reqPath = req.path

    if reqPath.hasPrefix("/api/tus") {
      path = String(reqPath.dropFirst("/api/tus".count))
    }

    print("upload path: \(path)")

    do {
      // just create directory
      if path.hasSuffix("/") {
        let directoryURL = publicDirectory.appendingPathComponent(path, isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return GCDWebServerDataResponse(jsonObject: [:])
      }

      let fileURL = publicDirectory.appendingPathComponent(path, isDirectory: false)
      let directoryURL = fileURL.deletingLastPathComponent()
      if !FileManager.default.fileExists(atPath: directoryURL.path) {
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
      }

      if FileManager.default.fileExists(atPath: fileURL.path) {
        if override {
          try FileManager.default.removeItem(at: fileURL)
        } else {
          return GCDWebServerDataResponse(jsonObject: [:])
        }
      }

      guard req.hasBody() else { return GCDWebServerDataResponse(jsonObject: [:]) }

      if let req = req as? GCDWebServerDataRequest {
        try req.data.write(to: fileURL)
      }
    } catch {
      print("upload write data error: \(error.localizedDescription)")
    }
    return GCDWebServerDataResponse(jsonObject: [:])
  }

  func tusHeadHandler(_ req: GCDWebServerRequest) -> GCDWebServerResponse? {
    var path = "/"
    let reqPath = req.path

    if reqPath.hasPrefix("/api/tus") {
      path = String(reqPath.dropFirst("/api/tus".count))
    }

    let fileURL = publicDirectory.appendingPathComponent(path, isDirectory: false)
    var offset = 0
    if FileManager.default.fileExists(atPath: fileURL.path), let attributeInfo = try? FileManager.default.attributesOfItem(atPath: fileURL.path) {
      offset = attributeInfo[FileAttributeKey.size] as? Int ?? 0
    }

    let response = GCDWebServerResponse(statusCode: 200)
    response.setValue("no-store", forAdditionalHeader: "Cache-Control")
    response.setValue("\(offset)", forAdditionalHeader: "Upload-Offset")
    response.setValue("-1", forAdditionalHeader: "Upload-Length")
    return response
  }

  func tusPatchHandler(_ req: GCDWebServerRequest) -> GCDWebServerResponse? {
    var path = "/"
    let reqPath = req.path

    if reqPath.hasPrefix("/api/tus") {
      path = String(reqPath.dropFirst("/api/tus".count))
    }

    let fileURL = publicDirectory.appendingPathComponent(path, isDirectory: false)
    let contentType = req.headers["Content-Type"] ?? ""
    guard contentType == "application/offset+octet-stream" else { return GCDWebServerResponse(statusCode: 415) }
    guard let offset = req.headers["Upload-Offset"], var offsetHeader = UInt64(offset) else { return GCDWebServerResponse(statusCode: 400) }

    do {
      // just create directory
      if path.hasSuffix("/") {
        let directoryURL = publicDirectory.appendingPathComponent(path, isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return GCDWebServerDataResponse(jsonObject: [:])
      }

      let directoryURL = fileURL.deletingLastPathComponent()
      if !FileManager.default.fileExists(atPath: directoryURL.path) {
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
      }

      guard req.hasBody() else { return GCDWebServerDataResponse(jsonObject: [:]) }

      if let req = req as? GCDWebServerDataRequest {
        if FileManager.default.fileExists(atPath: fileURL.path) {
          let fileHandle = try FileHandle(forWritingTo: fileURL)
          let fileOffset = try fileHandle.seekToEnd()
          if fileOffset != offsetHeader {
            return GCDWebServerResponse(statusCode: 409)
          }
          try fileHandle.write(contentsOf: req.data)
          offsetHeader = try fileHandle.seekToEnd()
          try fileHandle.close()
        } else {
          try req.data.write(to: fileURL)
        }
      }

      let response = GCDWebServerResponse(statusCode: 204)
      response.setValue("no-store", forAdditionalHeader: "Cache-Control")
      response.setValue("\(offsetHeader)", forAdditionalHeader: "Upload-Offset")
      response.setValue("-1", forAdditionalHeader: "Upload-Length")
      return response
    } catch {
      print("patch file error: \(error.localizedDescription)")
      return GCDWebServerResponse(statusCode: 500)
    }
  }

  /// 文件下载
  func download(_ req: GCDWebServerRequest) -> GCDWebServerResponse? {
    var path = "/"
    let reqPath = req.path
    if reqPath.hasPrefix("/api/raw") {
      path = String(reqPath.dropFirst("/api/raw".count))
    }

    // TODO: 目前只支持zip算法压缩, 可以通过此参数扩展下载格式
    // let algo: String = req.query["alog"] ?? "zip"

    let fileNames = req.query?["files"]
    let fm = FileManager()

    do {
      // this will hold the URL of the zip file
      let archiveUrl = try URL(
        fileURLWithPath: fm.url(
          for: .cachesDirectory,
          in: .userDomainMask,
          appropriateFor: publicDirectory,
          create: true
        )
        .path
      )
      .appendingPathComponent("export.zip", isDirectory: false)

      // 检测文件是否存在
      if fm.fileExists(atPath: archiveUrl.path) {
        try fm.removeItem(at: archiveUrl)
      }

      if let fileNames = fileNames {
        guard let archive = Archive(url: archiveUrl, accessMode: .create) else {
          return GCDWebServerDataResponse(statusCode: 500)
        }

        for fileName in fileNames.components(separatedBy: ",") {
          let fileURL = publicDirectory.appendingPathComponent(path).appendingPathComponent(fileName)

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
          at: publicDirectory.appendingPathComponent(path, isDirectory: true),
          to: archiveUrl
        )
      }

      return GCDWebServerFileResponse(file: archiveUrl.path)
    } catch {
      print("download file error: \(error.localizedDescription)")
    }
    return nil
  }

  func deleteFileHandler(_ req: GCDWebServerRequest) -> GCDWebServerResponse? {
    var path = "/"
    let reqPath = req.path
    if reqPath.hasPrefix("/api/resources") {
      path = String(reqPath.dropFirst("/api/resources".count))
    }

    if path.isEmpty {
      return GCDWebServerResponse(statusCode: 400)
    }

    let fileURL = publicDirectory.appendingPathComponent(path)
    do {
      try FileManager.default.removeItem(at: fileURL)
    } catch {
      print("delete file error: \(error.localizedDescription)")
      return GCDWebServerResponse(statusCode: 500)
    }

    return GCDWebServerResponse(statusCode: 200)
  }
}

struct DirectoryUsageResponse: Codable {
  var used: UInt = 0
  var total: UInt = 0
}

struct DirectorySortBy: Codable {
  var by = "name"
  var asc = false
}

struct DirectoryResourcesResponse: Codable {
  var path = ""
  var name = ""
  var size: UInt64 = 0
  var `extension` = ""
  var modified: String = ""
  var mode: UInt64 = 0
  var isDir: Bool = true
  var isSymlink: Bool = false
  var type = ""
  var numDirs: UInt?
  var numFiles: UInt?
  var sorting: DirectorySortBy?
  var items: [DirectoryResourcesResponse]?

  init(_ directory: URL) throws {
    let fileInfos = try directory.resourceValues(forKeys: [
      .contentModificationDateKey,
      .fileSizeKey,
      .isDirectoryKey,
      .isSymbolicLinkKey,
      .fileResourceTypeKey,
      .contentModificationDateKey,
    ])

    name = directory.lastPathComponent
    path = directory.path
    self.extension = directory.pathExtension.isEmpty ? "" : "." + directory.pathExtension

    if let modificationDate = fileInfos.contentModificationDate {
      modified = ISO8601DateFormatter().string(from: modificationDate)
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

extension FileManager {
  func isDirectory(_ path: URL) -> Bool {
    var isDirectory: ObjCBool = false
    if fileExists(atPath: path.path, isDirectory: &isDirectory) && isDirectory.boolValue {
      return true
    }
    return false
  }
}
