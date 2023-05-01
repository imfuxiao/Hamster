//
//  SheetView.swift
//  HamsterApp
//
//  Created by morse on 25/4/2023.
//

import SwiftUI

/// 自定义SheetView
struct SheetView<Content: View>: View {
  private let coordinateSpaceScrollViewName = "com.fuxiao.app.hamster.scrollview"

  typealias ContentViewBuilder = () -> Content

  @Environment(\.colorScheme) var colorScheme

  // 是否禁用全屏显示sheet
  var disableFullScreen = true

  // 半屏显示/全屏显示/下拉隐藏的阈值
  var thresholdValue: CGFloat = 100

  // Sheet是否显示
  @Binding
  var isShow: Bool

  @Binding
  var isShowMessage: Bool

  @Binding
  var showMessage: String

  @ViewBuilder
  var contentView: ContentViewBuilder

  @State
  private var geometryProxy: GeometryProxy?

  // 当前显示状态
  @State
  private var viewState = ViewState.half

  // 当前拖拽状态
  // 注意：在手势结束后状态会恢复初始状态
  @GestureState
  private var dragState = DragState.inactive

  // 距离当前位置的偏移量
  @State
  private var positionOffset: CGFloat = .zero

  @State
  private var scrollOffset: CGFloat = .zero

  @State
  private var initScrollOffset: CGFloat = .zero

  var dragGesture: some Gesture {
    DragGesture()
      .updating(self.$dragState) { value, state, _ in
        // 判断是否禁用全屏显示Sheet
        if disableFullScreen && value.translation.height < 0 {
          state = .inactive
          return
        }

        state = .dragging(translation: value.translation)
      }
      .onEnded { value in
        guard let geometryProxy = geometryProxy else { return }

        // 判断是否禁用全屏显示Sheet
        if disableFullScreen && value.translation.height < 0 {
          return
        }

        // 控制sheet页半开状态
        if self.viewState.isHalf {
          // 向上滑动超过阈值
          if value.translation.height < -thresholdValue {
            self.positionOffset = -geometryProxy.size.height / 2 + 50
            self.viewState = .full
          }

          // 向下滑动超过阈值
          if value.translation.height > thresholdValue {
            isShow = false
          }
        }
      }
  }

  var indicatorBackgroundColor: Color {
    Color.gray
  }

  var sheetBackgroundColor: Color {
    colorScheme == .dark ? Color.HamsterBackgroundColor : Color.white
  }

  var indicator: some View {
    RoundedRectangle(cornerRadius: 5)
      .fill(indicatorBackgroundColor)
      .frame(width: 50, height: 5)
  }

  var body: some View {
    GeometryReader { proxy in
      ZStack(alignment: .bottom) {
        BlackView().onTapGesture {
          withAnimation(.linear) {
            isShow = false
          }
        }

        VStack(alignment: .center, spacing: 0) {
          RoundedRectangle(cornerRadius: 15)
            .fill(sheetBackgroundColor)
            .overlay(
              VStack(spacing: 0) {
                indicator
                  .padding(.vertical, 10)
                ScrollView(.vertical, showsIndicators: true) {
                  // 通过 preference 方式拿到ScrollView的滚动值
                  GeometryReader { scrollViewProxy in
                    Color.clear.preference(
                      key: ScrollOffsetKey.self,
                      value: scrollViewProxy.frame(in: .named(coordinateSpaceScrollViewName)).minY
                    )
                  }
                  .frame(height: 0)

                  contentView()
                }
                .frame(width: proxy.size.width)
                // TODO: disable会将ContentView()所有事件都disable
//                .disabled(self.viewState == .half && self.dragState.translation.height == 0)
                .coordinateSpace(name: coordinateSpaceScrollViewName)
              }
            )
            .frame(width: proxy.size.width)
            .offset(
              y: proxy.size.height / 2 + positionOffset + self.dragState.translation.height
            )
            .transition(.move(edge: .bottom))
        }
        .shadow(radius: 10)
        .cornerRadius(15, antialiased: true)
        .hud(isShow: $isShowMessage, message: $showMessage)
        .gesture(dragGesture)
        .onPreferenceChange(ScrollOffsetKey.self) { value in
          if initScrollOffset == .zero {
            initScrollOffset = value
          }
          self.scrollOffset = value > 0 ? value : 0
          if self.scrollOffset > 120 {
            self.positionOffset = 0
            self.scrollOffset = 0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
              if self.viewState.isFull {
                self.viewState = .half
              } else {
                isShow = false
              }
            }
          }
        }
        .onAppear {
          geometryProxy = proxy
        }
        .ignoresSafeArea()
      }
    }
  }
}

struct ScrollOffsetKey: PreferenceKey {
  static var defaultValue: CGFloat = .zero

  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value += nextValue()
  }

  typealias Value = CGFloat
}

// SheetView显示状态
enum ViewState {
  // 全屏显示
  case full
  // 显示一半
  case half

  var isHalf: Bool {
    self == .half
  }

  var isFull: Bool {
    self == .full
  }
}

// 拖拽状态
enum DragState {
  // 未激活
  case inactive
  // 按下状态
  case pressing
  // 拖拽中
  case dragging(translation: CGSize)

  // 获取拖拽距离
  var translation: CGSize {
    if case .dragging(let translation) = self {
      return translation
    }
    return .zero
  }

  // 是否开始拖拽
  var isDragging: Bool {
    if case .inactive = self {
      return false
    }
    return true
  }
}

struct SheetView_Previews: PreviewProvider {
  static var previews: some View {
    SheetView(isShow: .constant(true), isShowMessage: .constant(false), showMessage: .constant("")) {
      Text("test")
    }
  }
}
