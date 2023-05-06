//
//  CandidateView.swift
//  Hamster
//
//  Created by morse on 17/4/2023.
//

import Combine
import KeyboardKit
import SwiftUI

struct CandidateView: View {
  init(
    appearance: HamsterKeyboardAppearance,
    style: AutocompleteToolbarStyle,
    padding: EdgeInsets,
    data: HamsterSuggestion,
    actionHandler: KeyboardActionHandler,
    isInScrollView: Bool = false
  ) {
    self.appearance = appearance
    self.data = data
    self.style = style
    self.padding = padding
    self.actionHandler = actionHandler
    self.isInScrollView = isInScrollView
  }

  let appearance: HamsterKeyboardAppearance
  let style: AutocompleteToolbarStyle
  let padding: EdgeInsets
  let data: HamsterSuggestion
  private let actionHandler: KeyboardActionHandler
  private let isInScrollView: Bool

  @State private var isPressed: Bool = false
  @EnvironmentObject var keyboardContext: KeyboardContext

  var foregroundColor: Color {
    guard let colorSchema = appearance.hamsterColorSchema else { return .primary }
    if data.isAutocomplete {
      return colorSchema.hilitedCandidateTextColor == .clear ? .primary : colorSchema.hilitedCandidateTextColor
    }
    return colorSchema.candidateTextColor == .clear ? .primary : colorSchema.candidateTextColor
  }

  var commentForegroundColor: Color {
    guard let colorSchema = appearance.hamsterColorSchema else { return .primary }
    if data.isAutocomplete {
      return colorSchema.hilitedCommentTextColor == .clear ? .primary : colorSchema.hilitedCommentTextColor
    }
    return colorSchema.commentTextColor == .clear ? .primary : colorSchema.commentTextColor
  }

  var backgroundColor: Color {
    guard let colorSchema = appearance.hamsterColorSchema else {
      return data.isAutocomplete ? Color.standardButtonBackground(for: keyboardContext) : .clear
    }
    return data.isAutocomplete ? colorSchema.hilitedCandidateBackColor : .clear
  }

  var body: some View {
    HStack(alignment: .center, spacing: 0) {
      Text(data.text)
        .font(style.item.titleFont.font)
        .foregroundColor(foregroundColor)

      if let comment = data.comment {
        Text(comment)
          .font(style.item.subtitleFont.font)
          .foregroundColor(commentForegroundColor)
      }
    }
    .padding(padding)
    .background(backgroundColor)
    .cornerRadius(style.autocompleteBackground.cornerRadius)
    .background(Color.clearInteractable)
    .hamsterKeyboardGestures(
      for: KeyboardAction.custom(named: "#selectIndex:\(data.index)"),
      actionHandler: actionHandler,
      calloutContext: nil,
      isInScrollView: isInScrollView,
      isPressed: $isPressed
    )
  }
}

// struct CandidateView: View {
//  let data: HamsterSuggestion
//  let style: AutocompleteToolbarStyle
//  let hamsterColor: ColorSchema
//  let action: (HamsterSuggestion) -> Void
//
//  @EnvironmentObject
//  var keyboardContext: KeyboardContext
//
//  init(data: HamsterSuggestion, style: AutocompleteToolbarStyle, hamsterColor: ColorSchema, action: @escaping (HamsterSuggestion) -> Void) {
//    self.data = data
//    self.style = style
//    self.hamsterColor = hamsterColor
//    self.action = action
//  }
//
//  var body: some View {
//    HStack(alignment: .center, spacing: 0) {
//      Text(data.text)
//        .font(style.item.titleFont.font)
//        .foregroundColor(
//          data.isAutocomplete
//            ? (hamsterColor.hilitedCandidateTextColor.bgrColor ?? .primary)
//            : (hamsterColor.candidateTextColor.bgrColor ?? .primary)
//        )
//      if let comment = data.comment {
//        Text(comment)
//          .font(style.item.subtitleFont.font)
//          .foregroundColor(
//            data.isAutocomplete
//              ? (hamsterColor.hilitedCommentTextColor.bgrColor ?? .primary)
//              : (hamsterColor.commentTextColor.bgrColor ?? .primary)
//          )
//      }
//    }
//    .padding(.all, 5)
//    .background(data.isAutocomplete ? (hamsterColor.hilitedCandidateBackColor.bgrColor ?? Color.standardButtonBackground(for: keyboardContext)) : .clear)
//    .cornerRadius(style.autocompleteBackground.cornerRadius)
//    .onTapGesture {
//      action(data)
//    }
//  }
// }
//
/// 候选文字横向滑动
struct CandidateHStackView: View {
  let appearance: HamsterKeyboardAppearance
  let style: AutocompleteToolbarStyle
  @Binding var suggestions: [HamsterSuggestion]
  var actionHandler: KeyboardActionHandler

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
        return CGSize(width: titleFont.width + commentFont.width + CGFloat(17), height: collectionView.bounds.height)
      },
      itemSpacing: .init(mainAxisSpacing: 0, crossAxisSpacing: 5),
      rawCustomize: { collectionView in
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentOffset.x = .zero
      },
      contentForData: { data in
        CandidateView(
          appearance: appearance,
          style: style,
          padding: .init(top: 6, leading: 6, bottom: 6, trailing: 6),
          data: data,
          actionHandler: actionHandler,
          isInScrollView: true
        )
        .contentShape(Rectangle())
      }
    )
  }
}

/// 候选文字纵向滑动
struct CandidateVStackView: View {
  init(appearance: HamsterKeyboardAppearance, style: AutocompleteToolbarStyle, suggestions: Binding<[HamsterSuggestion]>, actionHandler: KeyboardActionHandler) {
    self.appearance = appearance
    self.style = style
    self._suggestions = suggestions
    self.actionHandler = actionHandler
  }

  let appearance: HamsterKeyboardAppearance
  let style: AutocompleteToolbarStyle
  @Binding var suggestions: [HamsterSuggestion]
  var actionHandler: KeyboardActionHandler

  @EnvironmentObject var appSettings: HamsterAppSettings
  @EnvironmentObject var rimeContext: RimeContext
  @State var suggestionsSize: [CGSize] = []

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
        return CGSize(width: titleFont.width + commentFont.width + CGFloat(22), height: titleFont.height + 10)
      },
      itemSpacing: .init(mainAxisSpacing: 10, crossAxisSpacing: 0),
      rawCustomize: { collectionView in
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentOffset.y = .zero

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
          layout.sectionInset = UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 0)
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
        CandidateView(
          appearance: appearance,
          style: style,
          padding: .init(top: 6, leading: 10, bottom: 6, trailing: 10),
          data: $0,
          actionHandler: actionHandler,
          isInScrollView: true
        )
        .contentShape(Rectangle())
      }
    )
  }
}
