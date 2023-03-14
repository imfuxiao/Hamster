import SwiftUI

#if DEBUG
  private var loadInjection: () = {
    guard objc_getClass("InjectionClient") == nil else { return }
    #if os(macOS) || targetEnvironment(macCatalyst)
      let bundleName = "macOSInjection.bundle"
    #elseif os(tvOS)
      let bundleName = "tvOSInjection.bundle"
    #elseif targetEnvironment(simulator)
      let bundleName = "iOSInjection.bundle"
    #else
      let bundleName = "maciOSInjection.bundle"
    #endif
    Bundle(path: "/Applications/InjectionIII.app/Contents/Resources/" + bundleName)!.load()
  }()

  import Combine

  public let injectionObserver = InjectionObserver()

  public class InjectionObserver: ObservableObject {
    @Published var injectionNumber = 0
    var cancellable: AnyCancellable?
    let publisher = PassthroughSubject<(), Never>()
    init() {
      self.cancellable = NotificationCenter.default.publisher(
        for:
          Notification.Name("INJECTION_BUNDLE_NOTIFICATION")
      )
      .sink { [weak self] _ in
        self?.injectionNumber += 1
        self?.publisher.send()
      }
    }
  }

  extension View {
    public func eraseToAnyView() -> some View {
      _ = loadInjection
      return AnyView(self)
    }

    public func onInjection(bumpState: @escaping () -> Void) -> some View {
      return
        self
        .onReceive(injectionObserver.publisher, perform: bumpState)
        .eraseToAnyView()
    }
  }
#else
  extension View {
    public func eraseToAnyView() -> some View { return self }
    public func onInjection(bumpState: @escaping () -> Void) -> some View {
      return self
    }
  }
#endif
