//
//  SpaceContentView.swift
//
//
//  Created by morse on 2023/8/10.
//

import Combine
import UIKit

class SpaceContentView: UIView {
  private let keyboardContext: KeyboardContext
  private let item: KeyboardLayoutItem
  public var style: KeyboardButtonStyle
  private let loadingText: String
  private let loadingLabel: UILabel
  private let spaceView: TextContentView
  
  init(keyboardContext: KeyboardContext, item: KeyboardLayoutItem, style: KeyboardButtonStyle, loadingText: String, spaceText: String) {
    self.keyboardContext = keyboardContext
    self.item = item
    self.style = style
    self.loadingText = loadingText
    self.spaceView = TextContentView(
      keyboardContext: keyboardContext,
      item: item,
      style: style,
      text: spaceText,
      isInputAction: KeyboardAction.space.isInputAction
    )
    self.loadingLabel = UILabel(frame: .zero)
    loadingLabel.textAlignment = .center
    
    super.init(frame: .zero)
    
    setupSpaceView()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupSpaceView() {
    loadingLabel.text = loadingText
    loadingLabel.font = style.font?.font
    loadingLabel.alpha = 1
    addSubview(loadingLabel)
    loadingLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      loadingLabel.topAnchor.constraint(equalTo: topAnchor),
      loadingLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
      loadingLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
      loadingLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])
    
    spaceView.alpha = 0
    addSubview(spaceView)
    spaceView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      spaceView.topAnchor.constraint(equalTo: topAnchor),
      spaceView.bottomAnchor.constraint(equalTo: bottomAnchor),
      spaceView.leadingAnchor.constraint(equalTo: leadingAnchor),
      spaceView.trailingAnchor.constraint(equalTo: trailingAnchor),
    ])

    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      guard let self = self else { return }
      
      UIView.animate(withDuration: 0.5) {
        self.loadingLabel.alpha = 0
        self.spaceView.alpha = 1
      }
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    spaceView.style = style
  }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct SpaceContentView_Previews: PreviewProvider {
  static func spaceContent(loadingText: String, spaceView: UIView) -> some View {
    return UIViewPreview {
      let view = SpaceContentView(
        keyboardContext: KeyboardContext.preview,
        item: KeyboardLayoutItem(action: .character("a"), size: .init(width: .available, height: 24), insets: .zero, swipes: []),
        style: .preview1, loadingText: loadingText, spaceText: "空格"
      )
      view.frame = .init(x: 0, y: 0, width: 80, height: 80)
      return view
    }
  }
  
  static func spaceContent(loadingText: String, spaceText: String) -> some View {
    return UIViewPreview {
      let view = SpaceContentView(
        keyboardContext: KeyboardContext.preview,
        item: KeyboardLayoutItem(action: .character("a"), size: .init(width: .available, height: 24), insets: .zero, swipes: []),
        style: .preview1, loadingText: loadingText, spaceText: spaceText
      )
      view.frame = .init(x: 0, y: 0, width: 80, height: 80)
      return view
    }
  }

  static var previews: some View {
    HStack {
      spaceContent(loadingText: "测试", spaceText: "空格")
      spaceContent(
        loadingText: "空格",
        spaceView: UIImageView(image: UIImage.keyboardGlobe)
      )
    }
  }
}

#endif
