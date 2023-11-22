//
//  SeparatorCollectionViewFlowLayout.swift
//
//
//  Created by morse on 2023/10/8.
//

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

    var rows = [[UICollectionViewLayoutAttributes]]()
    var row = [UICollectionViewLayoutAttributes]()
    var rowIndex = 0
    var colIndex = 0

    var decorationAttributes: [UICollectionViewLayoutAttributes] = []
    for (index, layoutAttributes) in layoutAttributesArray.enumerated() {
      let indexPath = layoutAttributes.indexPath
      if let separatorAttributes = layoutAttributesForDecorationView(ofKind: CollectionSeparatorView.reusableIdentifier, at: indexPath) {
        if rect.intersects(separatorAttributes.frame) {
          decorationAttributes.append(separatorAttributes)
        }
      }

      if index != 0, layoutAttributes.frame.origin.x == 0 {
        rows.append(row)
        row = [UICollectionViewLayoutAttributes]()
        rowIndex += 1
        colIndex = 0
      }

      row.append(layoutAttributes)
      colIndex += 1
    }

    // 添加最后一行
    rows.append(row)

    // 修改最后一行 cell 的位置，与上一行保持一致
    if rows.count > 1, let lastRow = rows.last {
      let previousRow = rows[rowIndex - 1]
      for (cellIndex, layoutAttributes) in lastRow.enumerated() {
        guard cellIndex != 0 else { continue }
        guard cellIndex < previousRow.count else { break }

        let previousCell = previousRow[cellIndex - 1]
        let width = layoutAttributes.frame.width
        if width == previousCell.frame.width && width == previousRow[cellIndex].frame.width {
          layoutAttributes.frame = CGRect(
            origin: CGPoint(x: previousRow[cellIndex].frame.minX, y: layoutAttributes.frame.minY),
            size: layoutAttributes.size)
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

    // 除第一行之外的每一行添加分隔符
    guard indexPath.item > 0 else { return nil }

    let separatorAttributes = createAttributesForMyDecoration(at: indexPath)
    separatorAttributes.alpha = 1.0
    separatorAttributes.isHidden = false

    let firstCellInRow = cellFrame.origin.x < cellFrame.width
    if firstCellInRow {
      // horizontal line
      // 注意: 因为设置行间距, y轴需要减去行间距的一半
      separatorAttributes.frame = CGRect(x: rect.minX, y: cellFrame.origin.y - 1, width: rect.width, height: 1)
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
    self.backgroundColor = .gray.withAlphaComponent(0.1)
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
    frame = layoutAttributes.frame
  }
}
