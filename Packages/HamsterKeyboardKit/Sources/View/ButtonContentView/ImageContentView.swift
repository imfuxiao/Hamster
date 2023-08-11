//
//  ImageContentView.swift
//
//
//  Created by morse on 2023/8/10.
//

import UIKit

class ImageContentView: UIView {
  private let imageView: UIImageView
  private let scaleFactor: CGFloat

  init(image: UIImage?, scaleFactor: CGFloat = .zero, tintColor: UIColor? = nil) {
    self.imageView = UIImageView(image: image)
    self.scaleFactor = scaleFactor
    imageView.contentMode = .center

    if let tintColor = tintColor {
      imageView.tintColor = tintColor
    }

    super.init(frame: .zero)

    setupImage()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupImage() {
    addSubview(imageView)

    imageView.contentScaleFactor = scaleFactor
    imageView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: topAnchor),
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
      imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ImageContentView_Previews: PreviewProvider {
  static func imageContent(action: KeyboardAction, scaleFactor: CGFloat = 1, tintColor: UIColor? = nil) -> some View {
    let appearance: KeyboardAppearance = .preview
    return UIViewPreview {
      let view = ImageContentView(
        image: appearance.buttonImage(for: action),
        scaleFactor: scaleFactor,
        tintColor: tintColor
      )
//      view.frame = .init(origin: .zero, size: .init(width: 40, height: 40))
      return view
    }
  }

  static var previews: some View {
    HStack {
      imageContent(action: .backspace, scaleFactor: 2, tintColor: .gray)
      imageContent(action: .nextKeyboard, tintColor: .blue)
      imageContent(action: .keyboardType(.emojis))
    }
  }
}

#endif
