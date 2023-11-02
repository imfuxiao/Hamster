//
//  ChineseStanderSystemKeyboardSwipeSettingsView.swift
//
//
//  Created by morse on 2023/9/15.
//

import Combine
import HamsterKeyboardKit
import HamsterUIKit
import UIKit

/// 中文标准26键划动设置
class ChineseStanderSystemKeyboardSwipeSettingsView: NibLessView {
  private let keyboardSettingsViewModel: KeyboardSettingsViewModel
  private var subscriptions = Set<AnyCancellable>()

  private lazy var searchBar: UISearchBar = {
    let view = UISearchBar(frame: .zero)
    view.searchBarStyle = .minimal
    view.translatesAutoresizingMaskIntoConstraints = false
    view.delegate = self
    return view
  }()

  public lazy var diffableDataSource: UICollectionViewDiffableDataSource<Int, Key> = {
    let cellRegistration = UICollectionView.CellRegistration<SwipeSettingsCell, Key> { cell, _, item in
      cell.updateWithKey(item)
    }

    return UICollectionViewDiffableDataSource(collectionView: swipeListView) { collectionView, indexPath, item in
      collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
    }
  }()

  public lazy var collectionLayout: UICollectionViewLayout = {
    var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
      guard let self = self else { return UISwipeActionsConfiguration(actions: []) }

      let deleteAction = UIContextualAction(style: .destructive, title: "删除") { [unowned self] _, _, completion in
        var keys = self.keyboardSettingsViewModel.chineseStanderSystemKeyboardSwipeList
        guard keys.count > indexPath.item else { return }
        keys.remove(at: indexPath.item)
        self.keyboardSettingsViewModel.chineseStanderSystemKeyboardSwipeList = keys
        self.reloadSwipeList()
        completion(true)
      }

      return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    let layout = UICollectionViewCompositionalLayout.list(using: configuration)
    return layout
  }()

  private lazy var swipeListView: SwipeListView = {
    let view = SwipeListView(frame: .zero, collectionViewLayout: collectionLayout)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.delegate = self
    return view
  }()

  init(keyboardSettingsViewModel: KeyboardSettingsViewModel) {
    self.keyboardSettingsViewModel = keyboardSettingsViewModel

    super.init(frame: .zero)

    setupView()

    self.keyboardSettingsViewModel.chineseStanderSystemKeyboardSwipeListReloadPublished
      .receive(on: DispatchQueue.main)
      .sink { [unowned self] _ in
        reloadSwipeList()
      }
      .store(in: &subscriptions)
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

  override func didMoveToWindow() {
    super.didMoveToWindow()
    if let _ = window {
      reloadSwipeList()
    }
  }

  func reloadSwipeList() {
    var items = keyboardSettingsViewModel.chineseStanderSystemKeyboardSwipeList
    if let searchText = searchBar.text, !searchText.isEmpty {
      items = items
        .filter { $0.action.labelText.uppercased().contains(searchText.uppercased()) }
    }
    var snapshot = NSDiffableDataSourceSnapshot<Int, Key>()
    snapshot.appendSections([0])
    snapshot.appendItems(items, toSection: 0)
    diffableDataSource.apply(snapshot)
  }
}

// MARK: - 处理 SwipeListView 委托

extension ChineseStanderSystemKeyboardSwipeSettingsView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let _ = collectionView.cellForItem(at: indexPath) else { return }
    let key = diffableDataSource.snapshot(for: indexPath.section).items[indexPath.item]
    keyboardSettingsViewModel.keySwipeSettingsActionSubject.send((key, .chinese(.lowercased)))
    collectionView.deselectItem(at: indexPath, animated: false)
  }
}

// MARK: - 处理 UISearchBar 委托

extension ChineseStanderSystemKeyboardSwipeSettingsView: UISearchBarDelegate {
  // 查询功能
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      let snapshot = keyboardSettingsViewModel.initChineseStanderSystemKeyboardSwipeDataSource()
      diffableDataSource.apply(snapshot)
      return
    }
    let items = diffableDataSource.snapshot(for: 0)
      .items
      .filter { $0.action.labelText.uppercased().contains(searchText.uppercased()) }

    var snapshot = NSDiffableDataSourceSnapshot<Int, Key>()
    snapshot.appendSections([0])
    snapshot.appendItems(items, toSection: 0)
    diffableDataSource.apply(snapshot)
  }
}
