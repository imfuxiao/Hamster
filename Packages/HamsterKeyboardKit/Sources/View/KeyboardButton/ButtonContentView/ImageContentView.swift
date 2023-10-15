//
//  ImageContentView.swift
//
//
//  Created by morse on 2023/8/10.
//

import HamsterUIKit
import UIKit

class ImageContentView: NibLessView {
//  private let scaleFactor: CGFloat
  public let imageView: UIImageView
  public var style: KeyboardButtonStyle

  init(style: KeyboardButtonStyle, image: UIImage?, scaleFactor: CGFloat = .zero) {
    self.style = style
    self.imageView = UIImageView(image: image)
    imageView.contentMode = .center

    super.init(frame: .zero)

    setupImage()
  }

  func setupImage() {
    addSubview(imageView)

    if let color = style.foregroundColor {
      imageView.tintColor = color
    } else {
      imageView.tintColor = UIColor.label
    }

    imageView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
      imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      imageView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
      imageView.heightAnchor.constraint(lessThanOrEqualTo: heightAnchor),
    ])
  }
}
