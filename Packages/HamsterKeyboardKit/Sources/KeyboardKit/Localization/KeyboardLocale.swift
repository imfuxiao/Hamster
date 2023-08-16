//
//  KeyboardLocale.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-02-01.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This enum defines KeyboardKit-supported locales.

 该枚举定义了 KeyboardKit 支持的本地语言。

 Each keyboard locale refers to a native ``locale`` that can
 provide locale-specific information. A keyboard locale also
 has localized assets that can be translated with ``KKL10n``.

 每个键盘本地化指的是可以提供本地化特定信息的本地 ``locale`` 。
 键盘本地化也有本地化 assets，可以用 ``KL10n`` 翻译。
 */
public enum KeyboardLocale: String,
  CaseIterable,
  Codable,
  Identifiable
{
  case english = "en"
  case zh_Hans = "zh-Hans"
  case zh_Hant = "zh-Hant"
}

public extension KeyboardLocale {
  /**
   Get all LTR locales.
   */
  static var allLtr: [KeyboardLocale] {
    allCases.filter { $0.locale.isLeftToRight }
  }

  /**
   Get all RTL locales.
   */
  static var allRtl: [KeyboardLocale] {
    allCases.filter { $0.locale.isRightToLeft }
  }

  /**
   The locale's unique identifier.
   */
  var id: String { rawValue }

  /**
   The raw locale that is connected to the keyboard locale.
   */
  var locale: Locale { .init(identifier: localeIdentifier) }

  /**
   The identifier that is used to identify the raw locale.
   */
  var localeIdentifier: String { id }

  /**
   The corresponding flag emoji for the locale.

   Note that this property adjusts some locales, where the
   flag should not use the standard result.
   */
  var flag: String {
    switch self {
    case .english: return "🇺🇸"
    case .zh_Hans: return "🇨🇳"
    case .zh_Hant: return "🇨🇳"
    }
  }

  /**
   Whether or not the locale prefers to replace any single
   alternate ending quotation delimiters with begin ones.
   */
  var prefersAlternateQuotationReplacement: Bool {
    locale.prefersAlternateQuotationReplacement
  }

  /**
   Whether or not the locale matches a certain locale.
   */
  func matches(_ locale: Locale) -> Bool {
    self.locale == locale
  }
}

public extension Locale {
  /**
   Whether or not the locale matches a keyboard locale.
   */
  func matches(_ locale: KeyboardLocale) -> Bool {
    self == locale.locale
  }
}

public extension Collection where Element == KeyboardLocale {
  /**
   Get all LTR locales.
   */
  static var allLtr: [KeyboardLocale] {
    KeyboardLocale.allLtr
  }

  /**
   Get all RTL locales.
   */
  static var allRtl: [KeyboardLocale] {
    KeyboardLocale.allRtl
  }
}

public extension Collection where Element == KeyboardLocale {
  /**
   This condition is used by various extensions.
   */
  typealias KeyboardLocaleCondition = (Element) -> Bool

  /**
   Insert a certain a locale first in the collection.

   This will remove any other instances of the same locale.
   */
  func insertingFirst(_ locale: Element) -> [Element] {
    [locale] + removing(locale)
  }

  /**
   Remove a certain a locale from the collection.
   */
  func removing(_ locale: Element) -> [Element] {
    filter { $0 != locale }
  }

  /**
   Sort the collection by the localized name of every item.
   */
  func sorted() -> [Element] {
    sorted { $0.sortName < $1.sortName }
  }

  /**
   Sort the collection by the localized name of every item
   in the provided `locale`.

   - Parameters:
     - locale: The locale to use to get the localized name.
   */
  func sorted(in locale: Locale) -> [Element] {
    sorted { $0.sortName(in: locale) < $1.sortName(in: locale) }
  }
}

private extension KeyboardLocale {
  var sortName: String {
    locale.localizedName.lowercased()
  }

  func sortName(in locale: Locale) -> String {
    locale.localizedName(in: locale).lowercased()
  }
}

// MARK: - Locale

public extension Locale {
  /**
   The full name of this locale in its own words.
   */
  var localizedName: String {
    localizedString(forIdentifier: identifier) ?? ""
  }

  /**
   The full name of this locale in the provided locale.
   */
  func localizedName(in locale: Locale) -> String {
    locale.localizedString(forIdentifier: identifier) ?? ""
  }

  /**
   The language name of this locale in its own words.
   */
  var localizedLanguageName: String {
    localizedString(forLanguageCode: languageCode ?? "") ?? ""
  }

  /**
   The language name of this locale in the provided locale.
   */
  func localizedLanguageName(in locale: Locale) -> String {
    locale.localizedString(forLanguageCode: languageCode ?? "") ?? ""
  }
}
