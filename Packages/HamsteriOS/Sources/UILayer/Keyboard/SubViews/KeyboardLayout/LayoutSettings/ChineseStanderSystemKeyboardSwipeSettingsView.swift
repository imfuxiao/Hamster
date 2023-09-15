//
//  ChineseStanderSystemKeyboardSwipeSettingsView.swift
//
//
//  Created by morse on 2023/9/15.
//

import HamsterKeyboardKit
import HamsterUIKit
import UIKit

class ChineseStanderSystemKeyboardSwipeSettingsView: NibLessView {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel

  private lazy var searchBar: UISearchBar = {
    let view = UISearchBar(frame: .zero)
    view.searchBarStyle = .minimal
    view.translatesAutoresizingMaskIntoConstraints = false
    view.delegate = self
    return view
  }()

  private lazy var swipeListView: SwipeListView = {
    let view = SwipeListView(keyboardSettingsViewModel: keyboardSettingsViewModel)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.delegate = self
    return view
  }()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: .zero)

    setupView()
  }

  func setupView() {
    backgroundColor = .secondarySystemBackground
    addSubview(searchBar)
    addSubview(swipeListView)
    NSLayoutConstraint.activate([
      searchBar.topAnchor.constraint(equalTo: topAnchor),
      // TODO: 达不到效果，改用常量约束 8
      // searchBar.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
      searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
      searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

      swipeListView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
      swipeListView.leadingAnchor.constraint(equalTo: leadingAnchor),
      swipeListView.trailingAnchor.constraint(equalTo: trailingAnchor),
      swipeListView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }
}

extension ChineseStanderSystemKeyboardSwipeSettingsView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let key = swipeListView.diffableDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    keyboardSettingsViewModel.keySwipeSettingsActionSubject.send(key)
  }
}

extension ChineseStanderSystemKeyboardSwipeSettingsView: UISearchBarDelegate {
  // TODO: 查询功能
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        performQuery(with: searchText)
//    }
}

private class SwipeListView: NibLessCollectionView {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel
  public var diffableDataSource: UICollectionViewDiffableDataSource<Int, Key>!

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    let layout = UICollectionViewCompositionalLayout.list(using: configuration)

    super.init(frame: .zero, collectionViewLayout: layout)

    self.diffableDataSource = makeDataSource()
    self.diffableDataSource.apply(keyboardSettingsViewModel.initChineseStanderSystemKeyboardSwipeDataSource())
  }

  func cellRegistration() -> UICollectionView.CellRegistration<SwipeSettingsCell, Key> {
    return UICollectionView.CellRegistration { cell, _, item in
      cell.updateWithKey(item)
    }
  }

  func makeDataSource() -> UICollectionViewDiffableDataSource<Int, Key> {
    let cellRegistration = cellRegistration()
    return UICollectionViewDiffableDataSource(collectionView: self) { collectionView, indexPath, item in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }
  }
}
