//
//  HorizontalFlowLayout.swift
//
//
//  Created by morse on 2023/8/22.
//

import UIKit

class HorizontalFlowLayout: UICollectionViewFlowLayout {
  override func invalidateLayout() {
    super.invalidateLayout()
  }

  override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
    let context = super.invalidationContext(forBoundsChange: newBounds)
    context.invalidateItems(at: (0 ..< 15).map { IndexPath(item: $0, section: 0) })
    return context
  }
}
