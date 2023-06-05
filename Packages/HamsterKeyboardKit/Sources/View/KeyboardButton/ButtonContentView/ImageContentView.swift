//
//  ImageContentView.swift
//
//
//  Created by morse on 2023/8/10.
//

import HamsterUIKit
import UIKit

class ImageContentView: NibLessView {
  private var style: KeyboardButtonStyle
  private var oldBounds: CGRect = .zero
  private let image: UIImage?
  private let scaleFactor: CGFloat

  private lazy var imageView: UIImageView = {
    let imageView = UIImageView(frame: .zero)
    imageView.image = image
    return imageView
  }()

  init(style: KeyboardButtonStyle, image: UIImage? = nil, scaleFactor: CGFloat = .zero) {
    self.style = style
    self.image = image
    self.scaleFactor = scaleFactor

    super.init(frame: .zero)

    setupImage()
    setupAppearance()
  }

  func setupImage() {
    addSubview(imageView)
  }

  override func setupAppearance() {
    imageView.tintColor = style.foregroundColor ?? UIColor.label
    imageView.contentScaleFactor = scaleFactor
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    guard self.bounds != .zero, self.bounds != oldBounds else { return }

    self.oldBounds = self.bounds

    let imageSize = CGSize(width: 25, height: 20)
    let origin = CGPoint(
      x: (oldBounds.width - imageSize.width) / 2,
      y: (oldBounds.height - imageSize.height) / 2)
    imageView.frame = CGRect(origin: origin, size: imageSize)
  }

  func setStyle(_ style: KeyboardButtonStyle) {
    guard self.style != style else { return }
    self.style = style
    setupAppearance()
  }

  func setImage(_ image: UIImage) {
    self.imageView.image = image
  }
}
