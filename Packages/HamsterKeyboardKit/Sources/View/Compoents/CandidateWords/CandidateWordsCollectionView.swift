//
//  CandidateWordsCollectionView.swift
//
//
//  Created by morse on 2023/8/19.
//

import Combine
import HamsterKit
import HamsterModel
import UIKit

/**
 候选文字集合视图
 */
public class CandidateWordsCollectionView: UICollectionView {
  /// RIME 上下文
  let rimeContext: RimeContext

  /// 滚动方向
  let direction: UICollectionView.ScrollDirection

  /// 水平滚动方向布局
  let horizontalLayout: UICollectionViewLayout

  /// Combine
  var subscriptions = Set<AnyCancellable>()

  private var diffableDataSource: UICollectionViewDiffableDataSource<Int, CandidateSuggestion>! = nil

  init(rimeContext: RimeContext, direction: UICollectionView.ScrollDirection = .horizontal) {
    self.rimeContext = rimeContext
    self.direction = direction

    self.horizontalLayout = {
      let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(40), heightDimension: .fractionalHeight(1.0))
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(40), heightDimension: .fractionalHeight(1.0))
      let group: NSCollectionLayoutGroup
      if #available(iOS 16.0, *) {
        group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: 1)
      } else {
        group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      }
      let section = NSCollectionLayoutSection(group: group)
      // 控制水平方向 item 之间间距
      section.interGroupSpacing = 5
      section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
      // 控制垂直方向距拼写区的间距
      section.contentInsets = .init(top: 5, leading: 0, bottom: 0, trailing: 0)
      return UICollectionViewCompositionalLayout(section: section)
    }()

    super.init(frame: .zero, collectionViewLayout: horizontalLayout)

    self.delegate = self
    self.diffableDataSource = makeDataSource()

    // init data
    var snapshot = NSDiffableDataSourceSnapshot<Int, CandidateSuggestion>()
    snapshot.appendSections([0])
    snapshot.appendItems([], toSection: 0)
    diffableDataSource.apply(snapshot, animatingDifferences: false)

    self.backgroundColor = UIColor.clearInteractable
    self.showsHorizontalScrollIndicator = false

    if direction == .horizontal {
      self.alwaysBounceHorizontal = true
    }

    combine()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  /// 构建数据源
  func makeDataSource() -> UICollectionViewDiffableDataSource<Int, CandidateSuggestion> {
    let candidateWordCellRegistration = UICollectionView.CellRegistration<CandidateWordCell, CandidateSuggestion>
    { cell, _, candidateSuggestion in
      cell.updateWithCandidateSuggestion(candidateSuggestion, color: nil)
    }

    let dataSource = UICollectionViewDiffableDataSource<Int, CandidateSuggestion>(collectionView: self) { collectionView, indexPath, candidateSuggestion in
      collectionView.dequeueConfiguredReusableCell(using: candidateWordCellRegistration, for: indexPath, item: candidateSuggestion)
    }

    return dataSource
  }

  func combine() {
    Task {
      await self.rimeContext.$suggestions
        .receive(on: DispatchQueue.main)
        .sink { [weak self] candidates in
          guard let self = self else { return }

          print("self.rimeContext.$suggestions: \(candidates.count)")

          var snapshot = NSDiffableDataSourceSnapshot<Int, CandidateSuggestion>()
          snapshot.appendSections([0])
          snapshot.appendItems(candidates, toSection: 0)
          diffableDataSource.apply(snapshot, animatingDifferences: false)
          if !candidates.isEmpty {
            let invalidateContext = self.collectionViewLayout.invalidationContext(forBoundsChange: self.bounds)
            self.collectionViewLayout.invalidateLayout(with: invalidateContext)
          }
        }
        .store(in: &self.subscriptions)
    }
  }
}

/// MAKE: - UICollectionViewDelegateFlowLayout
extension CandidateWordsCollectionView: UICollectionViewDelegate {}
