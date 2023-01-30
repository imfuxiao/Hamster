import CoreGraphics
import Foundation
import KeyboardKit
import os

class CharacterSlideGestureHandler: SlideGestureHandler {
  private let characterSwipeConfig: [String: String]
  private let sensitivity: CharacterSlideSensitivity
  private let rimeEngine: RimeEngine?
  private let logger = Logger(subsystem: "dev.fuxiao.hamster", category: "CharacterSlideGestureHandler")
  
  var slideUp: String {
    KeyboardConstant.Character.SlideUp
  }
  
  var slideDown: String {
    KeyboardConstant.Character.SlideDown
  }
  
  init(config: [String: String] = [:], rimeEngine: RimeEngine?, sensitivity: CharacterSlideSensitivity = .low) {
    self.characterSwipeConfig = config
    self.rimeEngine = rimeEngine
    self.sensitivity = sensitivity
  }
  
  func handleDragGesture(action: KeyboardKit.KeyboardAction, from startLocation: CGPoint, to currentLocation: CGPoint) -> KeyboardAction.GestureAction? {
    logger.debug("from.x: \(startLocation.x), from.y: \(startLocation.y)")
    logger.debug("to.x: \(currentLocation.x), to.y: \(currentLocation.y)")
    
    guard case let .character(char) = action else {
      logger.debug("action is not character")
      return nil
    }
    
    // 上下滑动只关心Y轴, 且滑动距离需要大于设置的敏感度
    let slideYDelta = startLocation.y - currentLocation.y
    let sensitivityValue = sensitivity.points
    
    logger.debug("slide y delta: \(slideYDelta)")
    logger.debug("sensitivity.points: \(sensitivityValue)")
    
    if abs(slideYDelta) < CGFloat(sensitivityValue) {
      return nil
    }
    
    let actionKey = slideYDelta < 0 ? char.lowercased() + slideDown : char.lowercased() + slideUp
    logger.debug("action key: \(actionKey)")
    
    if let value = characterSwipeConfig[actionKey] {
      logger.debug("action value: \(value)")
      if value.hasPrefix("#") && value.count > 1 {
        let function = KeyboardConstant.Fuction(rawValue: value)
        switch function {
        case .SimplifiedTraditionalSwitch:
          return { [weak self] _ in
            if let status = self?.rimeEngine?.status() {
              self?.rimeEngine?.traditionalMode(!status.isSimplified)
            }
          }
        case .ChineseEnglishSwitch:
          return { [weak self] _ in
            if let status = self?.rimeEngine?.status() {
              self?.rimeEngine?.asciiMode(!status.isASCIIMode)
            }
          }
        case .BeginOfSentence:
          return nil
        case .EndOfSentence:
          return nil
        case .SelectSecond:
          return { [weak self] controller in
            if let status = self?.rimeEngine?.status() {
              if status.isComposing, let candidates = self?.rimeEngine?.context().candidates {
                if candidates.isEmpty {
                  return
                }
                if candidates.count == 2 {
                  controller?.keyboardContext.textDocumentProxy.insertText(candidates[1].text)
                  self?.rimeEngine?.rest()
                }
              }
            }
          }
        case .UndoCommitText:
          return nil
        default:
          return nil
        }
      }
      return { $0?.keyboardContext.textDocumentProxy.insertText(value) }
    }
    return nil
  }
}
