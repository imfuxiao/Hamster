//
//  File+Crypto.swift
//  Hamster
//
//  Created by morse on 11/5/2023.
//

import CommonCrypto
import Foundation
extension FileManager {
  func sha256OfFile(atPath path: String) -> String {
    guard let fileHandle = FileHandle(forReadingAtPath: path) else { return "" }
    defer { fileHandle.closeFile() }
    
    var context = CC_SHA256_CTX()
    CC_SHA256_Init(&context)
    
    let bufferSize = 1024 * 1024
    while autoreleasepool(invoking: {
      let data = fileHandle.readData(ofLength: bufferSize)
      if !data.isEmpty {
        data.withUnsafeBytes { ptr in
          _ = CC_SHA256_Update(&context, ptr.baseAddress, CC_LONG(data.count))
        }
        return true
      } else {
        return false
      }
    }) {}
    
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    CC_SHA256_Final(&hash, &context)
    
    return hash.map { String(format: "%02hhx", $0) }.joined()
  }
}
