//
//  ImageContentView.swift
//
//
//  Created by morse on 2023/8/10.
//

import HamsterUIKit
import UIKit

class ImageContentView: NibLessView {
  private let imageView: UIImageView
  private var style: KeyboardButtonStyle
  private var oldBounds: CGRect = .zero

  init(style: KeyboardButtonStyle, image: UIImage? = nil, scaleFactor: CGFloat = .zero) {
    self.style = style
    self.imageView = UIImageView(frame: .zero)
    imageView.contentMode = .center
    imageView.contentScaleFactor = scaleFactor
    imageView.tintColor = style.foregroundColor
    imageView.image = image

    super.init(frame: .zero)

    setupImage()
    setupAppearance()
  }

  func setupImage() {
    addSubview(imageView)
  }

  override func setupAppearance() {
    imageView.tintColor = style.foregroundColor ?? UIColor.label
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    guard self.bounds != .zero, self.bounds != oldBounds else { return }

    self.oldBounds = self.bounds
    imageView.frame = self.oldBounds
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
