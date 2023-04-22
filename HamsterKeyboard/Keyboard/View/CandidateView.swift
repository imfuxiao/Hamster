//
//  CandidateView.swift
//  Hamster
//
//  Created by morse on 17/4/2023.
//

import KeyboardKit
import SwiftUI

struct CandidateView: View {
  let data: HamsterSuggestion
  let style: AutocompleteToolbarStyle
  let hamsterColor: ColorSchema
  let action: (HamsterSuggestion) -> Void

  @EnvironmentObject
  var keyboardContext: KeyboardContext

  init(data: HamsterSuggestion, style: AutocompleteToolbarStyle, hamsterColor: ColorSchema, action: @escaping (HamsterSuggestion) -> Void) {
    self.data = data
    self.style = style
    self.hamsterColor = hamsterColor
    self.action = action
  }

  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      Text(data.text)
        .font(style.item.titleFont)
        .foregroundColor(
          data.isAutocomplete
            ? hamsterColor.hilitedCandidateTextColor
            : hamsterColor.candidateTextColor
        )
      if let comment = data.comment {
        Text(comment)
          .font(style.item.subtitleFont)
          .foregroundColor(
            data.isAutocomplete
              ? hamsterColor.hilitedCommentTextColor
              : hamsterColor.commentTextColor
          )
      }
    }
    .padding(.all, 5)
    .background(data.isAutocomplete ? hamsterColor.hilitedCandidateBackColor ?? Color.standardButtonBackground(for: keyboardContext) : .clearInteractable)
    .cornerRadius(style.autocompleteBackground.cornerRadius)
    .onTapGesture {
      action(data)
    }
  }
}

/// 候选文字横向滑动
struct CandidateHStackView: View {
  let style: AutocompleteToolbarStyle
  let hamsterColor: ColorSchema
  @Binding var suggestions: [HamsterSuggestion]
  let action: (HamsterSuggestion) -> Void

  @EnvironmentObject var appSettings: HamsterAppSettings

  var body: some View {
    CollectionView(
      collection: self.suggestions,
      scrollDirection: .horizontal,
      contentSize: .custom { collectionView, _, data in

        // TODO: 动态计算每个候选字的宽度
        // 代码来源: https://stackoverflow.com/questions/1324379/how-to-calculate-the-width-of-a-text-string-of-a-specific-font-and-font-size

        // 注意需要使用: UIFont
        // TODO: 这里使用了系统字体, 如果将来换成用户维护代字体, 需要修改此处方法
        let titleFontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(appSettings.rimeCandidateTitleFontSize))]
        let titleFont = (data.title as NSString).size(withAttributes: titleFontAttributes)

        let commentFontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(appSettings.rimeCandidateCommentFontSize))]
        let commentFont = ((data.comment ?? "") as NSString).size(withAttributes: commentFontAttributes)
        return CGSize(width: titleFont.width + commentFont.width + CGFloat(12), height: collectionView.bounds.height)
      },
      itemSpacing: .init(mainAxisSpacing: 10, crossAxisSpacing: 10),
      rawCustomize: { collectionView in
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentOffset.x = .zero
      },
      contentForData: {
        CandidateView(data: $0, style: style, hamsterColor: hamsterColor, action: action)
      }
    )
  }
}

/// 候选文字纵向滑动
struct CandidateVStackView: View {
  let style: AutocompleteToolbarStyle
  let hamsterColor: ColorSchema
  @Binding var suggestions: [HamsterSuggestion]
  let action: (HamsterSuggestion) -> Void

  @EnvironmentObject var appSettings: HamsterAppSettings

  var body: some View {
    CollectionView(
      collection: self.suggestions,
      scrollDirection: .vertical,
      contentSize: .custom { _, _, data in

        // TODO: 动态计算每个候选字的宽度
        // 代码来源: https://stackoverflow.com/questions/1324379/how-to-calculate-the-width-of-a-text-string-of-a-specific-font-and-font-size

        // 注意需要使用: UIFont
        // TODO: 这里使用了系统字体, 如果将来换成用户维护代字体, 需要修改此处方法
        let titleFontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(appSettings.rimeCandidateTitleFontSize))]
        let titleFont = (data.title as NSString).size(withAttributes: titleFontAttributes)

        let commentFontAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(appSettings.rimeCandidateCommentFontSize))]
        let commentFont = ((data.comment ?? "") as NSString).size(withAttributes: commentFontAttributes)
        return CGSize(width: titleFont.width + commentFont.width + CGFloat(15), height: titleFont.height + 10)
      },
      itemSpacing: .init(mainAxisSpacing: 20, crossAxisSpacing: 0),
      rawCustomize: { collectionView in
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentOffset.x = .zero

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
          layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
          layout.minimumLineSpacing = 1

//          let separatorCollectionViewFlowLayout = SeparatorCollectionViewFlowLayout()
//          separatorCollectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
//          separatorCollectionViewFlowLayout.scrollDirection = layout.scrollDirection
//          separatorCollectionViewFlowLayout.minimumLineSpacing = 2
//          collectionView.collectionViewLayout = separatorCollectionViewFlowLayout

          collectionView.collectionViewLayout = layout
        }
      },
      contentForData: {
        CandidateView(data: $0, style: style, hamsterColor: hamsterColor, action: action)
      }
    )
  }
}
