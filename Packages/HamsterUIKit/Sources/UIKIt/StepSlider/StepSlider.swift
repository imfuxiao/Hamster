//
//  StepSlider.swift
//
//  源码来源：https://github.com/spromicky/StepSlider.git
//  将 OC 代码转为 swift, 并对部分代码做了调整
//
//  Created by morse on 2023/8/3.
//

import QuartzCore
import UIKit

public class StepSlider: UIControl {
  /// 文本标签位置
  public enum LabelOrientation {
    // 在划块下方设置文字标签
    case down
    // 在划块上方设置文本标签
    case up
  }
  
  // MARK: properties
  
  private static let kTrackAnimation = "kTrackAnimation"
  
  /// 划块中的最大数。必须是 `2` 或更大。注意：如果 `labels` 数组不是空的，则将 `maxCount` 设置为标签计数。
  public var maxCount: UInt = .zero
  
  /// 划块上当前选定的索引。
  public var index: UInt = .zero {
    didSet {
      generatorHapticFeedback()
    }
  }
  
  /// 划快轨道的高度
  public var trackHeight: CGFloat = .zero
  
  /// 轨道刻度圆的半径
  public var trackCircleRadius: CGFloat = .zero
  
  /// 划块圆的半径
  public var sliderCircleRadius: CGFloat = .zero
  
  /// 用于确定是否忽略用户与划块上刻度点的交互。默认值为"true"。
  public var dotsInteractionEnable: Bool = true
  
  /// 划块轨道的颜色
  public var trackColor: UIColor = .clear
  
  /// 划块指针颜色
  public var sliderCircleColor: UIColor = .clear
  
  /// 划块指针的图片
  public var sliderCircleImage: UIImage? = nil
  
  /// 用于在划块刻度附近显示的标签文本。
  /// 注意：如果 `labels` 数组不是空的，那么 `maxCount` 将等于 `labels.count`。
  public var labels: [String] = []
  private var attributedLabels: [NSAttributedString] = []
  
  /// 标签文本字体
  public var labelFont: UIFont = .systemFont(ofSize: UIFont.labelFontSize)
  
  /// 标签文本颜色
  public var labelColor: UIColor = .label
  
  /// 标签位置偏移
  public var labelOffset: CGFloat = .zero
  
  /// 标签位置
  public var labelOrientation: LabelOrientation = .down
  
  /// 如果“true”，请将第一个和最后一个标签调整到步进划块框架。并将对齐方式更改为左对齐和右对齐。否则，标签位置与轨道圆相同，并且对齐方式始终为中心。
  public var adjustLabel: Bool = false
  
  /// 值更改时产生触觉反馈。如果开启了低功耗模式，则忽略。
  /// 默认值为 "false"。
  public var enableHapticFeedback: Bool = false
  
  public var feedbackGeneratorBuild: ((Int) -> Void)?
  
  // MARK: private properties
  
  private var trackLayer: CAShapeLayer = .init()
  private var sliderCircleLayer: CAShapeLayer = .init()
  private var trackCircles: [CAShapeLayer] = []
  private var trackLabels: [CATextLayer] = []
  private var trackCircleImages: [UIControl.State.RawValue: UIImage] = [:]
  
  private var animateLayouts: Bool = false
  
  private var maxRadius: CGFloat = .zero
  private var diff: CGFloat = .zero
  
  private var startTouchPosition: CGPoint = .zero
  private var startSliderPosition: CGPoint = .zero
  
  private var contentSize: CGSize = .zero
  
  // MARK: methods
  
  override public init(frame: CGRect) {
    self.index = 2
    
    super.init(frame: frame)
    
    generalSetup()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func generalSetup() {
    addLayers()
    
    if maxCount == .zero {
      maxCount = 4
    }
    
    if trackHeight == .zero {
      trackHeight = 4
    }
    
    if trackCircleRadius == .zero {
      trackCircleRadius = 5
    }
    
    if sliderCircleRadius == .zero {
      sliderCircleRadius = 12.5
    }
    
    if labelOffset == .zero {
      labelOffset = 20
    }
    
    trackColor = UIColor(white: 0.41, alpha: 1)
    sliderCircleColor = UIColor.white
    labelColor = UIColor.white
    
    updateMaxRadius()
    
    setNeedsLayout()
  }
  
  private func addLayers() {
    dotsInteractionEnable = true
    trackCircles = []
    trackLabels = []
    trackCircleImages = [:]
    
    trackLayer = CAShapeLayer()
    sliderCircleLayer = CAShapeLayer()
    sliderCircleLayer.contentsScale = UIScreen.main.scale
    sliderCircleLayer.actions = ["contents": NSNull()]
    
    layer.addSublayer(sliderCircleLayer)
    layer.addSublayer(trackLayer)
    
    labelFont = UIFont.systemFont(ofSize: 15)
    contentSize = bounds.size
  }
  
  // 注意：要在 index 值变更后调用
  private func generatorHapticFeedback() {
    // TODO: 取消低电量模式不开启震动
    // if enableHapticFeedback && !ProcessInfo.processInfo.isLowPowerModeEnabled {
    if enableHapticFeedback {
      if let feedbackGeneratorBuild = feedbackGeneratorBuild {
        feedbackGeneratorBuild(Int(index))
      }
    }
  }
  
  override public var intrinsicContentSize: CGSize {
    return contentSize
  }
  
  // MARK: draw
  
  override public func prepareForInterfaceBuilder() {
    updateMaxRadius()
    
    super.prepareForInterfaceBuilder()
  }
  
  func layoutLayersAnimated(_ animated: Bool) {
    let tempIndexDiff = roundf(Float(indexCalculate())) - Float(index)
    let indexDiff = Int(fabsf(tempIndexDiff))
    let left: Bool = tempIndexDiff < 0
    
    let contentWidth: CGFloat = bounds.size.width - 2 * maxRadius
    let stepWidth: CGFloat = contentWidth / CGFloat(maxCount - 1)
    
    let sliderHeight = CGFloat(fmaxf(Float(maxRadius), Float(trackHeight / 2.0)) * 2.0)
    let labelHeight: CGFloat = labelHeightWithMaxWidth(stepWidth) + labelOffset
    let totalHeight: CGFloat = sliderHeight + labelHeight
    
    contentSize = CGSizeMake(CGFloat(fmaxf(44.0, Float(bounds.size.width))), CGFloat(fmaxf(44.0, Float(totalHeight))))
    
    if !CGSizeEqualToSize(bounds.size, contentSize) {
      if !constraints.isEmpty {
        invalidateIntrinsicContentSize()
      } else {
        var newFrame = frame
        newFrame.size = contentSize
        frame = newFrame
      }
    }
    
    var contentFrameY: CGFloat = (bounds.size.height - totalHeight) / 2.0
    if labelOrientation == .up && !labels.isEmpty {
      contentFrameY += labelHeight
    }
    
    let contentFrame = CGRectMake(maxRadius, contentFrameY, contentWidth, sliderHeight)
    
    let circleFrameSide: CGFloat = trackCircleRadius * 2.0
    let sliderDiameter: CGFloat = sliderCircleRadius * 2.0
    
    let oldPosition: CGPoint = sliderCircleLayer.position
    
    // TODO:
    let trackLayoutCopy = try? NSKeyedUnarchiver.unarchivedObject(
      ofClass: CAShapeLayer.self,
      from: NSKeyedArchiver.archivedData(withRootObject: trackLayer, requiringSecureCoding: true)
    )
    let oldPath = trackLayoutCopy?.path
    
    // TODO:
    let labelsY: CGFloat = labelOrientation == .up
      ? (bounds.size.height - totalHeight) / 2.0
      : (CGRectGetMaxY(contentFrame) + labelOffset)
    
    if !animated {
      CATransaction.begin()
      CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    }
    
    if let sliderCircleImage = sliderCircleImage {
      sliderCircleLayer.path = nil
      sliderCircleLayer.frame = CGRectMake(.zero, .zero,
                                           fmax(sliderCircleImage.size.width, 44.0),
                                           fmax(sliderCircleImage.size.height, 44.0))
      sliderCircleLayer.contents = sliderCircleImage.cgImage
      sliderCircleLayer.contentsGravity = .center
    } else {
      let sliderFrameSide: CGFloat = fmax(sliderCircleRadius * 2.0, 44.0)
      let xAndY: CGFloat = (sliderFrameSide - sliderDiameter) / 2.0
      let sliderDrawRect: CGRect = CGRectMake(
        xAndY,
        xAndY,
        sliderDiameter,
        sliderDiameter
      )
      sliderCircleLayer.path = UIBezierPath(roundedRect: sliderDrawRect, cornerRadius: sliderFrameSide / 2).cgPath
      sliderCircleLayer.frame = CGRectMake(.zero, .zero, sliderFrameSide, sliderFrameSide)
      sliderCircleLayer.contents = nil
      sliderCircleLayer.fillColor = sliderCircleColor.cgColor
    }
    
    let rectMidY = CGRectGetMidY(contentFrame) - trackHeight / 2.0
    sliderCircleLayer.position = CGPointMake(contentFrame.origin.x + stepWidth * CGFloat(index), rectMidY)
    
    if animated {
      let basicSliderAnimation = CABasicAnimation(keyPath: "position")
      basicSliderAnimation.duration = CATransaction.animationDuration()
      basicSliderAnimation.fromValue = NSValue(cgPoint: oldPosition)
      sliderCircleLayer.add(basicSliderAnimation, forKey: "position")
    }
    
    trackLayer.frame = CGRectMake(contentFrame.origin.x, rectMidY, contentFrame.size.width, trackHeight)
    trackLayer.path = fillingPath()
    trackLayer.backgroundColor = trackColor.cgColor
    trackLayer.fillColor = tintColor.cgColor
    
    if animated {
      let basicTrackAnimation = CABasicAnimation(keyPath: "path")
      basicTrackAnimation.duration = CATransaction.animationDuration()
      basicTrackAnimation.fromValue = oldPath
      trackLayer.add(basicTrackAnimation, forKey: "path")
    }
    
    trackCircles = clearExcessLayers(layers: trackCircles)
    
    let currentWidth = adjustLabel
      ? trackLabels.first?.bounds.size.width ?? .zero * 2
      : trackLabels.first?.bounds.size.width ?? .zero
    
    if (currentWidth > 0 && currentWidth != stepWidth) || !labels.isEmpty {
      removeLabelLayers()
    }
    
    var animationTimeDiff: TimeInterval = .zero
    let duration = CATransaction.animationDuration()
    if indexDiff > 0 {
      animationTimeDiff = (left ? duration : -duration) / Double(indexDiff)
    }
    var animationTime = left ? animationTimeDiff : duration + animationTimeDiff
    let circleAnimation = circleFrameSide / trackLayer.frame.size.width
    
    for i in 0 ..< maxCount {
      let trackCircle: CAShapeLayer
      var trackLabel: CATextLayer? = nil
      
      if !labels.isEmpty {
        trackLabel = textLayerWithSize(CGSizeMake(roundForTextDrawing(value: stepWidth), labelHeight - labelOffset), index: Int(i))
      }
      
      if i < trackCircles.count {
        trackCircle = trackCircles[Int(i)]
      } else {
        trackCircle = CAShapeLayer()
        trackCircle.actions = ["fillColor": NSNull(), "contents": NSNull()]
        layer.addSublayer(trackCircle)
        trackCircles.append(trackCircle)
      }
      
      let xPosition = contentFrame.origin.x + stepWidth * CGFloat(i)
      
      trackCircle.bounds = CGRectMake(.zero, .zero, circleFrameSide, circleFrameSide)
      trackCircle.position = CGPointMake(xPosition, CGRectGetMidY(contentFrame))
      
      let trackCircleImage = trackCircleImage(trackCircle)
      if let _ = trackCircleImage {
        trackCircle.path = nil
      } else {
        trackCircle.path = UIBezierPath(roundedRect: trackCircle.bounds, cornerRadius: circleFrameSide / 2).cgPath
        trackCircle.contents = nil
      }
      
      trackLabel?.position = CGPointMake(xPosition, labelsY)
      trackLabel?.foregroundColor = labelColor.cgColor
      if let trackLabel = trackLabel {
        layer.addSublayer(trackLabel)
        trackLabels.append(trackLabel)
      }
      
      if animated {
        if let trackCircleImage = trackCircleImage {
          let oldImage = trackCircle.contents as! CGImage
          if oldImage != trackCircleImage {
            trackCircle.contents = trackCircleImage
            animateTrackCircleChanges(trackCircle: trackCircle, from: oldImage, to: trackCircleImage, keyPath: "contents", beginTime: animationTime, duration: circleAnimation)
            animationTime += animationTimeDiff
          }
        } else {
          let newColor: CGColor = trackCircleColor(trackCircle)
          let oldColor: CGColor = trackCircle.fillColor!
          if newColor != oldColor {
            animateTrackCircleChanges(trackCircle: trackCircle, from: oldColor, to: newColor, keyPath: "fillColor", beginTime: animationTime, duration: circleAnimation)
            animationTime += animationTimeDiff
          }
        }
      } else {
        if let trackCircleImage = trackCircleImage {
          trackCircle.contents = trackCircleImage
        } else {
          trackCircle.fillColor = trackCircleColor(trackCircle)
        }
      }
    }
    
    if !animated {
      CATransaction.commit()
    }
    
    sliderCircleLayer.removeFromSuperlayer()
    layer.addSublayer(sliderCircleLayer)
  }
  
  override public func layoutSubviews() {
    super.layoutSubviews()
    
    layoutLayersAnimated(animateLayouts)
    animateLayouts = false
  }
}

// MARK: - Helpers

extension StepSlider {
  func animateTrackCircleChanges(trackCircle: CAShapeLayer, from fromValue: Any?, to toValue: Any?, keyPath: String, beginTime: CFTimeInterval, duration: CFTimeInterval) {
    let basicTrackCircleAnimation = CABasicAnimation(keyPath: Self.kTrackAnimation)
    basicTrackCircleAnimation.fillMode = CAMediaTimingFillMode.backwards
    basicTrackCircleAnimation.beginTime = CACurrentMediaTime() + beginTime
    basicTrackCircleAnimation.duration = CATransaction.animationDuration() * duration
    basicTrackCircleAnimation.keyPath = keyPath
    basicTrackCircleAnimation.fromValue = fromValue
    basicTrackCircleAnimation.toValue = toValue
    
    trackCircle.add(basicTrackCircleAnimation, forKey: Self.kTrackAnimation)
    trackCircle.setValue(basicTrackCircleAnimation.toValue, forKey: keyPath)
  }
  
  func clearExcessLayers(layers: [CAShapeLayer]) -> [CAShapeLayer] {
    guard layers.count > maxCount else { return layers }
    
    for i in Int(maxCount) ..< layers.count {
      layers[i].removeFromSuperlayer()
    }
    
    return Array(layers.prefix(Int(maxCount)))
  }
  
  func labelHeightWithMaxWidth(_ maxWidth: CGFloat) -> CGFloat {
    guard !labels.isEmpty else { return .zero }
    
    var labelHeight: CGFloat = .zero
    for i in 0 ..< labels.count {
      let size: CGSize
      if adjustLabel && (i == 0 || i == labels.count - 1) {
        size = CGSizeMake(roundForTextDrawing(value: maxWidth / 2.0 + maxRadius), CGFLOAT_MAX)
      } else {
        size = CGSizeMake(roundForTextDrawing(value: maxWidth), CGFLOAT_MAX)
      }
      
      // TODO:
      let height: CGFloat = NSString(string: labels[i])
        .boundingRect(
          with: size,
          options: .usesLineFragmentOrigin,
          attributes: [NSAttributedString.Key.font: labelFont],
          context: nil
        )
        .size
        .height
      
      labelHeight = fmax(ceil(height), labelHeight)
    }
    return labelHeight
  }
  
  /// 计算从刻度圆与轨道线交叉点的距离。
  func updateDiff() {
    let maxValue: CGFloat = fmax(.zero, pow(trackCircleRadius, 2.0) - pow(trackHeight / 2.0, 2.0))
    diff = CGFloat(sqrtf(Float(maxValue)))
  }
  
  func updateMaxRadius() {
    maxRadius = fmax(trackCircleRadius, sliderCircleRadius)
  }
  
  func updateIndex() {
    assert(maxCount > 1, "Elements count must be greater than 1!")
    if index > maxCount - 1 {
      index = maxCount - 1
      sendActions(for: .valueChanged)
    }
  }
  
  func fillingPath() -> CGPath {
    var fillRect = trackLayer.bounds
    fillRect.size.width = sliderPosition()
    return UIBezierPath(rect: fillRect).cgPath
  }
  
  func sliderPosition() -> CGFloat {
    sliderCircleLayer.position.x - maxRadius
  }
  
  func trackCirclePosition(_ trackCircle: CAShapeLayer) -> CGFloat {
    trackCircle.position.x - maxRadius
  }
  
  func indexCalculate() -> CGFloat {
    let divisor = trackLayer.bounds.size.width / CGFloat(maxCount - 1)
    if divisor == 0 {
      return 0
    }
    return sliderPosition() / divisor
  }
  
  func trackCircleIsSelected(_ trackCircle: CAShapeLayer) -> Bool {
    sliderPosition() + diff >= trackCirclePosition(trackCircle)
  }
}

// MARK: - Track Circle

extension StepSlider {
  func trackCircleColor(_ trackCircle: CAShapeLayer) -> CGColor {
    trackCircleIsSelected(trackCircle) ? tintColor.cgColor : trackColor.cgColor
  }
  
  func trackCircleImage(_ trackCircle: CAShapeLayer) -> CGImage? {
    let selected = trackCircleIsSelected(trackCircle)
    return trackCircleImageForState(selected ? .selected : .normal)?.cgImage
  }
  
  /**
   * 设置指定状态的轨道图像。
   * 目前仅支持 `normal` 和 `selected`。
   * @param image 指定状态要使用的图像。
   * @param state 使用指定图像的状态。
   */
  func setTrackCircleImage(_ image: UIImage, for forState: UIControl.State) {
    trackCircleImages[forState.rawValue] = image
    setNeedsLayout()
  }
  
  func trackCircleImageForState(_ state: UIControl.State) -> UIImage? {
    trackCircleImages[state.rawValue] ?? trackCircleImages[UIControl.State.normal.rawValue]
  }
}

// MARK: - Touches

public extension StepSlider {
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//    print("gestureRecognizerShouldBegin")
    
    guard gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) else { return false }
    
    let position = gestureRecognizer.location(in: self)
    return CGRectContainsPoint(bounds, position)
  }
  
  override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    startTouchPosition = touch.location(in: self)
    startSliderPosition = sliderCircleLayer.position
    
    let touchContainsPoint = CGRectContainsPoint(sliderCircleLayer.frame, startTouchPosition)
    guard !touchContainsPoint else {
      return true
    }
    
    guard dotsInteractionEnable else { return false }
    
    for i in 0 ..< trackCircles.count {
      let dot = trackCircles[i]
      
      let dotRadiusDiff: CGFloat = 22 - trackCircleRadius
      let frameToCheck: CGRect = dotRadiusDiff > 0
        ? CGRectInset(dot.frame, -dotRadiusDiff, -dotRadiusDiff)
        : dot.frame
      
      if CGRectContainsPoint(frameToCheck, startTouchPosition) {
        if index != i {
          index = UInt(i)
          sendActions(for: .valueChanged)
          feedbackGeneratorBuild?(Int(index))
        }
        animateLayouts = true
        setNeedsLayout()
        return false
      }
    }
    return false
  }
  
  override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
    let position: CGFloat = startTouchPosition.x - (startTouchPosition.x - touch.location(in: self).x)
    let limitedPosition: CGFloat = fmin(fmax(maxRadius, position), bounds.size.width - maxRadius)
    
    withoutCAAnimation { [unowned self] in
      sliderCircleLayer.position = CGPointMake(limitedPosition, sliderCircleLayer.position.y)
      trackLayer.path = fillingPath()
      
      let index = UInt(sliderPosition() + diff) / (UInt(trackLayer.bounds.size.width) / (maxCount - 1))
      if self.index != index {
        trackCircles.forEach { trackCircle in
          let trackCircleImage = self.trackCircleImage(trackCircle)
          if let trackCircleImage = trackCircleImage {
            trackCircle.contents = trackCircleImage
          } else {
            trackCircle.fillColor = trackCircleColor(trackCircle)
          }
        }
        self.index = index
        sendActions(for: .valueChanged)
        feedbackGeneratorBuild?(Int(index))
      }
    }
    
    return true
  }
  
  override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
    endTouches()
  }
  
  override func cancelTracking(with event: UIEvent?) {
    endTouches()
  }
  
  private func endTouches() {
//    print("endTouches")
    let newIndex = lroundf(Float(indexCalculate()))
    
    if newIndex != index {
      index = UInt(newIndex)
      sendActions(for: .valueChanged)
    } else {
      generatorHapticFeedback()
    }

    feedbackGeneratorBuild?(Int(index))
    animateLayouts = true
    setNeedsLayout()
  }
  
  private func withoutCAAnimation(_ code: @escaping () -> Void) {
    CATransaction.begin()
    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    code()
    CATransaction.commit()
  }
}

// MARK: - Texts

extension StepSlider {
  func textLayerWithSize(_ size: CGSize, index: Int) -> CATextLayer {
    guard index >= trackLabels.count else { return trackLabels[index] }
    
    var size = size
    let trackLabel = CATextLayer()
    var anchorPoint = CGPointMake(0.5, .zero)
    var alignmentMode = CATextLayerAlignmentMode.center
    
    if adjustLabel {
      if index == 0 {
        alignmentMode = .left
        size.width = size.width / 2.0 + maxRadius
        anchorPoint.x = maxRadius / size.width
      } else if index == labels.count - 1 {
        alignmentMode = .right
        size.width = size.width / 2.0 + maxRadius
        anchorPoint.x = 1.0 - maxRadius / size.width
      }
    }
    
    trackLabel.alignmentMode = alignmentMode
    trackLabel.isWrapped = true
    trackLabel.contentsScale = UIScreen.main.scale
    trackLabel.anchorPoint = anchorPoint
    
    let fontName = labelFont.fontName as CFString
    let font = CGFont(fontName)
    
    trackLabel.font = font
    trackLabel.fontSize = labelFont.pointSize
    
    // TODO:
    //  CGFontRelease(font);
    
    trackLabel.string = labels[index]
    trackLabel.bounds = CGRectMake(.zero, .zero, size.width, size.height)
    
    return trackLabel
  }
  
  func removeLabelLayers() {
    trackLabels.forEach { $0.removeFromSuperlayer() }
    trackLabels.removeAll()
  }
  
  func roundForTextDrawing(value: CGFloat) -> CGFloat {
    let scale = window?.windowScene?.screen.scale ?? UIScreen.main.scale
    return floor(value * scale) / scale
  }
}

// MARK: - Access methods

public extension StepSlider {
  /**
   * 将 `index` 属性设置为参数值。参数 index 您希望选择的索引
   * @param index 您想要选择的索引。
   * @param 动画“YES”以动画方式更改“index”属性。
   */
  func setIndex(_ index: Int, animated: Bool) {
    animateLayouts = animated
    self.index = UInt(index)
  }
  
  func setTintColor(_ tintColor: UIColor) {
    super.tintColor = tintColor
    setNeedsLayout()
  }
  
  func setLabels(_ labels: [String]) {
    assert(labels.count != 1, "Labels count can not be equal to 1!")
    
    var tempLabel = [NSMutableAttributedString]()
    for index in 0 ..< labels.count {
      let attributedString = NSMutableAttributedString(string: labels[index])
      let fullRange = NSRange(location: 0, length: attributedString.length)
      attributedString.enumerateAttribute(.font, in: fullRange, options: .init(rawValue: 0)) { value, range, _ in
        if value == nil {
          attributedString.addAttributes([.font: self.labelFont], range: range)
        }
      }
      attributedString.enumerateAttribute(.foregroundColor, in: fullRange, options: .init(rawValue: 0)) { value, range, _ in
        if value == nil {
          attributedString.addAttributes([.foregroundColor: self.labelColor], range: range)
        }
      }
      tempLabel.append(attributedString)
    }
    
    if self.labels != labels {
      self.labels = labels
      attributedLabels = tempLabel
      
      if self.labels.count > 0 {
        maxCount = UInt(self.labels.count)
      }
      
      updateIndex()
      removeLabelLayers()
      setNeedsLayout()
    }
  }
  
  func setMaxCount(_ maxCount: UInt) {
    if maxCount != self.maxCount, labels.isEmpty {
      self.maxCount = maxCount
      
      updateIndex()
      setNeedsLayout()
    }
  }
  
  func setIndex(_ index: UInt) {
    if self.index != index {
      self.index = index
      updateIndex()
      sendActions(for: .valueChanged)
      setNeedsLayout()
    }
  }
  
  func setTrackHeight(_ trackHeight: CGFloat) {
    if self.trackHeight != trackHeight {
      self.trackHeight = trackHeight
      updateDiff()
      setNeedsLayout()
    }
  }
  
  func setTrackCircleRadius(_ trackCircleRadius: CGFloat) {
    if self.trackCircleRadius != trackCircleRadius {
      self.trackCircleRadius = trackCircleRadius
      updateDiff()
      updateMaxRadius()
      setNeedsLayout()
    }
  }
  
  func setTrackColor(_ trackColor: UIColor) {
    if self.trackColor != trackColor {
      self.trackColor = trackColor
      setNeedsLayout()
    }
  }
  
  func setSliderCircleRadius(_ sliderCircleRadius: CGFloat) {
    if self.sliderCircleRadius != sliderCircleRadius {
      self.sliderCircleRadius = sliderCircleRadius
      updateMaxRadius()
      setNeedsLayout()
    }
  }
  
  func setSliderCircleColor(_ sliderCircleColor: UIColor) {
    if self.sliderCircleColor != sliderCircleColor {
      self.sliderCircleColor = sliderCircleColor
      setNeedsLayout()
    }
  }
  
  func setSliderCircleImage(_ sliderCircleImage: UIImage) {
    if self.sliderCircleImage != sliderCircleImage {
      self.sliderCircleImage = sliderCircleImage
      setNeedsLayout()
    }
  }
  
  func setLabelFont(_ labelFont: UIFont) {
    if self.labelFont != labelFont {
      self.labelFont = labelFont
      removeLabelLayers()
      setNeedsLayout()
    }
  }
  
  func setLabelColor(_ labelColor: UIColor) {
    if self.labelColor != labelColor {
      self.labelColor = labelColor
      setNeedsLayout()
    }
  }
  
  func setLabelOffset(_ labelOffset: CGFloat) {
    if self.labelOffset != labelOffset {
      self.labelOffset = labelOffset
      setNeedsLayout()
    }
  }
  
  func setLabelOrientation(_ labelOrientation: LabelOrientation) {
    if self.labelOrientation != labelOrientation {
      self.labelOrientation = labelOrientation
      setNeedsLayout()
    }
  }
  
  func setAdjustLabel(_ adjustLabel: Bool) {
    if self.adjustLabel != adjustLabel {
      self.adjustLabel = adjustLabel
      setNeedsLayout()
    }
  }
}
