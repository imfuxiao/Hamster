//
//  ExpandCandidatesView.swift
//  HamsterKeyboard
//
//  Created by morse on 21/4/2023.
//

import KeyboardKit
import SwiftUI

//struct ExpandCandidatesView: View {
//  init(style: AutocompleteToolbarStyle, actionHandler: KeyboardActionHandler) {
//    Logger.shared.log.debug("ExpandCandidatesView init")
//    self.style = style
//    self.actionHandler = actionHandler
//  }
//
//  var style: AutocompleteToolbarStyle
//  var actionHandler: KeyboardActionHandler
//
//  @EnvironmentObject var appSettings: HamsterAppSettings
//  @EnvironmentObject var keyboardContext: KeyboardContext
//  @EnvironmentObject var rimeContext: RimeContext
//
//  var hamsterColor: ColorSchema {
//    rimeContext.currentColorSchema
//  }
//
//  var backgroundColor: Color {
//    return hamsterColor.backColor.bgrColor ?? .clear
//  }
//
//  @State private var totalHeight = CGFloat.zero
//  var horizontalSpacing: CGFloat = 2
//  var verticalSpacing: CGFloat = 0
//
//  private func generateContent(in geometry: GeometryProxy) -> some View {
//    var width = CGFloat.zero
//    var height = CGFloat.zero
//    let suggestions = rimeContext.suggestions
//
//    return ZStack(alignment: .topLeading) {
//      ForEach(suggestions) { suggestion in
//        VStack(alignment: .center, spacing: 0) {
//          HStack(alignment: .center, spacing: 0) {
//            CandidateView(
//              data: suggestion,
//              style: style,
//              padding: .init(top: 6, leading: 9, bottom: 6, trailing: 9),
//              hamsterColor: hamsterColor,
//              actionHandler: actionHandler
//            )
//          }
//        }
//        .id(suggestion.index)
//        .padding(.horizontal, horizontalSpacing)
//        .padding(.vertical, verticalSpacing)
//        .alignmentGuide(.leading, computeValue: { dimension in
//          // 判断是否应该换行(通过改变 height)
//          // 如果需要换行则 width 需要重新计算
//          if abs(width - dimension.width) > geometry.size.width {
//            width = 0
//            height -= dimension.height
//          }
//
//          let result = width
//          if suggestion == suggestions.last {
//            width = 0 // last item
//          } else {
//            width -= dimension.width
//          }
//          return result
//        })
//        .alignmentGuide(.top, computeValue: { _ in
//          let result = height
//          if suggestion == suggestions.last {
//            height = 0 // last item
//          }
//          return result
//        })
//      }
//    }
//    .background(viewHeightReader($totalHeight))
//  }
//
//  private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
//    return GeometryReader { geometry -> Color in
//      let rect = geometry.frame(in: .local)
//      DispatchQueue.main.async {
//        binding.wrappedValue = rect.size.height
//      }
//      return .clear
//    }
//  }
//
//  var body: some View {
//    HStack(alignment: .top, spacing: 0) {
//      // 纵向候选区
//      CandidateVStackView(
//        style: style,
//        color: hamsterColor,
//        suggestions: $rimeContext.suggestions,
//        actionHandler: actionHandler
//      )
//      .transition(.move(edge: .top))
//
//      // 候选栏纵向滑动测试版
////      ScrollViewReader { scrollProxy in
////        ScrollView(.vertical, showsIndicators: true) {
////          VStack {
////            GeometryReader { proxy in
////              self.generateContent(in: proxy)
////            }
////          }
////          .frame(height: totalHeight)
////          .padding(.top, 5)
////        }
////        .accessibilityAddTraits(.isButton)
////        .frame(minHeight: 0, maxHeight: .infinity)
////        .frame(minWidth: 0, maxWidth: .infinity)
////        .onChange(of: rimeEngine.userInputKey, perform: { _ in
////          scrollProxy.scrollTo(0)
////        })
////      }
//
//      VStack(alignment: .center, spacing: 0) {
//        // 收起按钮
//        CandidateBarArrowButton(
//          size: appSettings.candidateBarHeight,
//          hamsterColor: hamsterColor,
//          imageName: appSettings.candidateBarArrowButtonImageName,
//          showDivider: appSettings.showDivider,
//          action: {
//            withAnimation(.linear(duration: 0.1)) {
//              appSettings.keyboardStatus = .normal
//            }
//          }
//        )
//        Spacer()
//        // TODO: 这里可以增加删除按钮
//        // Image.keyboardBackspace
//      }
//    }
//    .background(backgroundColor)
//  }
//}
