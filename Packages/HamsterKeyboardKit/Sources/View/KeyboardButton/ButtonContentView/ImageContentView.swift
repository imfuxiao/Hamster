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
    imageView.contentMode = .center
    return imageView
  }()

  init(style: KeyboardButtonStyle, image: UIImage? = nil, scaleFactor: CGFloat = .zero) {
    self.style = style
    self.image = image
    self.scaleFactor = scaleFactor

    super.init(frame: .zero)

    constructViewHierarchy()
    setupAppearance()
  }

  override func constructViewHierarchy() {
    addSubview(imageView)
  }

  override func setupAppearance() {
    imageView.tintColor = style.foregroundColor ?? UIColor.label
    imageView.contentScaleFactor = scaleFactor
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    guard self.bounds != oldBounds else { return }
    self.oldBounds = self.bounds

    imageView.translatesAutoresizingMaskIntoConstraints = false
    if !imageView.constraints.isEmpty {
      NSLayoutConstraint.deactivate(imageView.constraints)
    }
    NSLayoutConstraint.activate([
      imageView.widthAnchor.constraint(equalToConstant: self.oldBounds.width),
      imageView.heightAnchor.constraint(equalToConstant: self.oldBounds.height),
    ])
  }

  func setStyle(_ style: KeyboardButtonStyle) {
    guard self.style != style else { return }
    self.style = style
    setupAppearance()
  }

  func setImage(_ image: UIImage) {
    self.imageView.image = image
    self.imageView.sizeToFit()
  }
}
