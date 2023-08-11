//
//  ViewPreview.swift
//
//
//  Created by morse on 2023/8/10.
//

import UIKit

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct UIViewPreview<View: UIView>: UIViewRepresentable {
  let view: View

  init(_ builder: @escaping () -> View) {
    view = builder()
  }

  // MARK: UIViewRepresentable

  func makeUIView(context: Context) -> UIView {
    return view
  }

  func updateUIView(_ view: UIView, context: Context) {
    view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    view.setContentHuggingPriority(.defaultHigh, for: .vertical)
  }
}
#endif
