import Leaf
import Vapor

public class FileServer {
  private var app: Application
  private let port: Int
  private let publicDirectory: URL
  private var isRunning: Bool = false

  public init(port: Int, publicDirectory: URL) {
    self.port = port
    self.publicDirectory = publicDirectory

    #if DEBUG
    app = Application(.development)
    #else
    app = Application(.production)
    #endif

    configure(app)
  }

  func configure(_ app: Application) {
    app.http.server.configuration.hostname = "0.0.0.0"
    app.http.server.configuration.port = port

    app.views.use(.leaf)
    app.leaf.cache.isEnabled = app.environment.isRelease
    app.leaf.configuration.rootDirectory = Bundle.files.bundlePath.appending("/static")

    app.routes.defaultMaxBodySize = "150MB"

    let file = FileMiddleware(publicDirectory: Bundle.files.bundlePath.appending("/static"))
    app.middleware.use(file)

    let encoder = JSONEncoder()
    encoder.outputFormatting = .withoutEscapingSlashes
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    encoder.dateEncodingStrategy = .formatted(formatter)
    ContentConfiguration.global.use(encoder: encoder, for: .json)
  }

  public func start() {
    Task(priority: .background) {
      guard self.isRunning == false else { return }
      self.isRunning = true
      do {
        try self.app.register(collection: FileWebRouteCollection(publicDirectory: self.publicDirectory))
        try self.app.start()
      } catch {
        fatalError(error.localizedDescription)
      }
    }
  }

  public func shutdown() {
    guard self.isRunning == true else { return }
    self.isRunning = false
    app.server.shutdown()
    do {
      try app.server.onShutdown.wait()
    } catch {
      fatalError(error.localizedDescription)
    }
  }
}
