//
//  EnglishCalloutActionProvider.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-02-01.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This class provides U.S. English callout actions.
 
 该类提供美式英语呼出操作。
 
 You can use the class as a template when you want to create
 your own callout action provider.
 
 当您想创建自己的呼出动作提供程序时，可以将该类作为模板。
 */
open class EnglishCalloutActionProvider: BaseCalloutActionProvider {
  /**
   Get callout actions as a string for the provided `char`.
   
   以字符串形式获取所提供的 `char` 的呼出操作。
   */
  override open func calloutActionString(for char: String) -> String {
    switch char {
    case "0": return "0°"

    case "a": return "aàáâäæãåā"
    case "c": return "cçćč"
    case "e": return "eèéêëēėę"
    case "i": return "iîïíīįì"
    case "l": return "lł"
    case "n": return "nñń"
    case "o": return "oôöòóœøōõ"
    case "s": return "sßśš"
    case "u": return "uûüùúū"
    case "y": return "yÿ"
    case "z": return "zžźż"
            
    case "-": return "-–—•"
    case "/": return "/\\"
    case "$": return "$€£¥₩₽¢"
    case "&": return "&§"
    case "”", "“": return "\"”“„»«"
    case ".": return ".…"
    case "?": return "?¿"
    case "!": return "!¡"
    case "'", "’": return "'’‘`"
            
    case "%": return "%‰"
    case "=": return "=≠≈"
            
    default: return ""
    }
  }
}
