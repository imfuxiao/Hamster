//
//  File.swift
//
//
//  Created by morse on 13/4/2023.
//

import class Foundation.Bundle
import class Foundation.ProcessInfo
import struct Foundation.URL

private class BundleFinder {}

extension Foundation.Bundle {
  /// Returns the resource bundle associated with the current Swift module.
  static let files: Bundle = {
    let bundleName = "HamsterFileServer_HamsterFileServer"
    
    let overrides: [URL]
    #if DEBUG
      if let override = ProcessInfo.processInfo.environment["PACKAGE_RESOURCE_BUNDLE_URL"] {
        overrides = [URL(fileURLWithPath: override)]
      } else {
        overrides = []
      }
    #else
      overrides = []
    #endif
    
    let candidates = overrides + [
      // Bundle should be present here when the package is linked into an App.
      Bundle.main.resourceURL,
      
      // Bundle should be present here when the package is linked into a framework.
      Bundle(for: BundleFinder.self).resourceURL,
      
      // For command-line tools.
      Bundle.main.bundleURL,
    ]
    
    for candidate in candidates {
      let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
      if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
        return bundle
      }
    }
    fatalError("unable to find bundle named \(bundleName)")
  }()
}
