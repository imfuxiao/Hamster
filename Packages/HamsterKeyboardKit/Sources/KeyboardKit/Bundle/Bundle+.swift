//
//  Bundle+Resources.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-12-16.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

extension Bundle {
/**
 The name of the package bundle, which may change in new
 Xcode versions.
 
 软件包捆绑包的名称，在新的 Xcode 版本中可能会更改。
 
 If the Xcode name convention changes, you can print the
 path like this and look for the bundle name in the text:
 
 如果 Xcode 名称约定发生变化，您可以像这样打印路径，并在文本中查找捆绑包名称：
 
 ```
 Bundle(for: BundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent()
 ```
 */
//#if SBXLM
//  static let HamsterKeyboardBundleName = "SbxlmKeyboardKit_SbxlmKeyboardKit"
//#else
  static let HamsterKeyboardBundleName = "HamsterKeyboardKit_HamsterKeyboardKit"
//#endif

  /**
   This bundle lets us use resources from HamsterKeyboard.

   通过该捆绑包，我们可以使用 HamsterKeyboard 中的资源。

   Hopefully, Apple will fix this bundle bug to remove the
   need for this workaround.

   希望苹果公司能修复这个 bundle 错误，从而不再需要这种变通办法。

   Inspiration from here:
   https://developer.apple.com/forums/thread/664295
   https://dev.jeremygale.com/swiftui-how-to-use-custom-fonts-and-images-in-a-swift-package-cl0k9bv52013h6bnvhw76alid
   */
  public static let hamsterKeyboard: Bundle = {
    let candidates = [
      // Bundle should be present here when the package is linked into an App.
      // 当 bundle 链接到应用程序时，此处应出现 Bundle。
      Bundle.main.resourceURL,
      // Bundle should be present here when the package is linked into a framework.
      // 当 bundle 链接到 framework 时，此处应包含 Bundle。
      Bundle(for: BundleFinder.self).resourceURL,
      // For command-line tools.
      // 用于命令行工具。
      Bundle.main.bundleURL,
      // Bundle should be present here when running previews from a different package
      // (this is the path to "…/Debug-iphonesimulator/").
      // 从不同软件包运行预览时，此处应包含 Bundle（这是".../Debug-iphonesimulator/"的路径）。
      Bundle(for: BundleFinder.self)
        .resourceURL?
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent(),
      Bundle(for: BundleFinder.self)
        .resourceURL?
        .deletingLastPathComponent()
        .deletingLastPathComponent()
    ]

    for candidate in candidates {
      let bundlePath = candidate?.appendingPathComponent(HamsterKeyboardBundleName + ".bundle")
      if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
        return bundle
      }
    }
    fatalError("Can't find custom bundle. See Bundle+KeyboardKit.swift")
  }()

  func bundle(for locale: Locale) -> Bundle? {
    guard let bundlePath = bundlePath(for: locale) else { return nil }
    return Bundle(path: bundlePath)
  }

  func bundlePath(for locale: Locale) -> String? {
    // locale.identifier 的格式可能为 language_region，这里只截取前面的 language 部分
    // 如果本地化不支持的语言，则默认为英文
    bundlePath(named: String(locale.identifier.split(separator: "_")[0]))
      ?? bundlePath(named: locale.languageCode)
      ?? bundlePath(named: "en")
  }

  func bundlePath(named name: String?) -> String? {
    path(forResource: name ?? "", ofType: "lproj")
  }
}

private extension Bundle {
  class BundleFinder {}
}

extension Bundle {
  /**
   Get whether or not the bundle is an extension.

   获取 bundle 是否是应用扩展。
   */
  var isExtension: Bool {
    bundlePath.hasSuffix(".appex")
  }
}
