//
//  UserDefault+.swift
//
//
//  Created by morse on 13/7/2023.
//

import Combine
import UIKit

extension UserDefaults {
  private static let favoriteButtonKey = "com.ihsiao.apps.Hamster.FavoriteButton"

  // 收藏按钮 Subject
  static let favoriteButtonSubject = PassthroughSubject<[FavoriteButton], Never>()

  func getFavoriteButtons() -> [FavoriteButton] {
    let favoritesButtons = (object(forKey: Self.favoriteButtonKey) as? [String]) ?? [String]()
    return favoritesButtons.compactMap { FavoriteButton(rawValue: $0) }
  }

  func setFavoriteButton(button: FavoriteButton) {
    var favoritesButtons = (object(forKey: Self.favoriteButtonKey) as? [String]) ?? [String]()
    guard !favoritesButtons.contains(button.rawValue) else { return }
    favoritesButtons.append(button.rawValue)
    setValue(favoritesButtons, forKey: Self.favoriteButtonKey)
    // 保存时发送订阅
    Self.favoriteButtonSubject.send(favoritesButtons.compactMap { FavoriteButton(rawValue: $0) })
  }

  // true: 存在  false: 不存在
  func favoriteButtonExist(button: FavoriteButton) -> Bool {
    let favoritesButtons = (object(forKey: Self.favoriteButtonKey) as? [String]) ?? [String]()
    return favoritesButtons.contains(button.rawValue)
  }

  func removeFavoriteButton(button: FavoriteButton) {
    var favoritesButtons = (object(forKey: Self.favoriteButtonKey) as? [String]) ?? [String]()
    if let (index, _) = favoritesButtons.enumerated().first(where: { $1 == button.rawValue }) {
      favoritesButtons.remove(at: index)
      setValue(favoritesButtons, forKey: Self.favoriteButtonKey)
      // 删除时发送订阅
      Self.favoriteButtonSubject.send(favoritesButtons.compactMap { FavoriteButton(rawValue: $0) })
    }
  }
}
