//
//  NibLessCollectionView.swift
//
//
//  Created by morse on 2023/9/13.
//

import UIKit

open class NibLessCollectionView: UICollectionView {
  override public init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
  }

  @available(*, unavailable)
  public required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
