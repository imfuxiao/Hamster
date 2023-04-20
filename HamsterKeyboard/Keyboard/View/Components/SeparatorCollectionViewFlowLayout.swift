import UIKit

// 代码来源: 在两者的基础上做了改造
// https://gist.github.com/tomaskraina/1eb291e4717f14ad6e0f8e60ffe9b7d3
// https://stackoverflow.com/questions/28691408/uicollectionview-custom-line-separators

public class SeparatorCollectionViewFlowLayout: UICollectionViewFlowLayout {
  private var indexPathsToInsert: [IndexPath] = []
  private var indexPathsToDelete: [IndexPath] = []
  
  // MARK: - Lifecycle
  
  override init() {
    super.init()
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  // 检索指定矩形中所有单元格和视图的布局属性。
  override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let layoutAttributesArray = super.layoutAttributesForElements(in: rect) else { return nil }
      
    var decorationAttributes: [UICollectionViewLayoutAttributes] = []
    for layoutAttributes in layoutAttributesArray {
      let indexPath = layoutAttributes.indexPath
      if let separatorAttributes = layoutAttributesForDecorationView(ofKind: CollectionSeparatorView.reusableIdentifier, at: indexPath) {
        if rect.intersects(separatorAttributes.frame) {
          decorationAttributes.append(separatorAttributes)
        }
      }
    }
      
    let allAttributes = layoutAttributesArray + decorationAttributes
    return allAttributes
  }
  
  // 检索指定装饰视图的布局属性。
  override public func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let cellAttributes = layoutAttributesForItem(at: indexPath) else {
      return createAttributesForMyDecoration(at: indexPath)
    }
    return layoutAttributesForMyDecoratinoView(at: indexPath, for: cellAttributes.frame, state: .normal)
  }

  // 检索被插入到集合视图中的装饰视图的起始布局信息。
  override public func initialLayoutAttributesForAppearingDecorationElement(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let cellAttributes = initialLayoutAttributesForAppearingItem(at: indexPath) else {
      return createAttributesForMyDecoration(at: indexPath)
    }
    return layoutAttributesForMyDecoratinoView(at: indexPath, for: cellAttributes.frame, state: .initial)
  }

  // 检索即将从集合视图中移除的装饰视图的最终布局信息。
  override public func finalLayoutAttributesForDisappearingDecorationElement(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    guard let cellAttributes = finalLayoutAttributesForDisappearingItem(at: indexPath) else {
      return createAttributesForMyDecoration(at: indexPath)
    }
    return layoutAttributesForMyDecoratinoView(at: indexPath, for: cellAttributes.frame, state: .final)
  }
  
  // MARK: - privates
  
  private enum State {
    case initial
    case normal
    case final
  }
  
  private func setup() {
    register(CollectionSeparatorView.self, forDecorationViewOfKind: CollectionSeparatorView.reusableIdentifier)
  }
  
  private func createAttributesForMyDecoration(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
    return UICollectionViewLayoutAttributes(forDecorationViewOfKind: CollectionSeparatorView.reusableIdentifier, with: indexPath)
  }
  
  private func layoutAttributesForMyDecoratinoView(at indexPath: IndexPath, for cellFrame: CGRect, state: State) -> UICollectionViewLayoutAttributes? {
    guard let rect = collectionView?.bounds else {
      return nil
    }
      
    // Add separator for every row except the first
    guard indexPath.item > 0 else {
      return nil
    }
      
    let separatorAttributes = createAttributesForMyDecoration(at: indexPath)
    separatorAttributes.alpha = 1.0
    separatorAttributes.isHidden = false
      
    let firstCellInRow = cellFrame.origin.x < cellFrame.width
    if firstCellInRow {
      // horizontal line
      // 注意: 因为设置行间距, y轴需要减去行间距的一半
      separatorAttributes.frame = CGRect(x: rect.minX, y: cellFrame.origin.y - 10, width: rect.width, height: 1)
      separatorAttributes.zIndex = 1000
          
    } else {
      // 屏蔽纵向线, 纵向线也有bug
      // vertical line
      // separatorAttributes.frame = CGRect(x: cellFrame.origin.x, y: cellFrame.origin.y, width: 1, height: rect.height)
      // separatorAttributes.zIndex = 1000
    }
      
    // Sync the decorator animation with the cell animation in order to avoid blinkining
    switch state {
    case .normal:
      separatorAttributes.alpha = 1
    default:
      separatorAttributes.alpha = 0.1
    }
      
    return separatorAttributes
  }
}

private final class CollectionSeparatorView: UICollectionReusableView {
  static let reusableIdentifier = "separator"
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = .gray
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    frame = layoutAttributes.frame
  }
}
