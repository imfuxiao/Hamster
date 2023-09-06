//
//  File.swift
//
//
//  Created by morse on 2023/9/5.
//

import Combine
import Foundation

class ClassifySymbolicViewModel {
  /// 当前符号分类
  @Published
  var currentCategory: SymbolCategory = .frequent
}
