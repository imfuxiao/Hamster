//
//  View+Extend.swift
//  HamsterApp
//
//  Created by morse on 2023/3/23.
//

import SwiftUI

extension View {
  // 统一阴影样式
  func hamsterShadow() -> some View {
    shadow(color: Color.HamsterShadowColor, radius: 1)
  }

  // 统一子页面Title字体样式
  func subViewTitleFont() -> some View {
    font(.system(size: 26, weight: .black))
  }

  /// 统一function类似样式
  func functionCell() -> some View {
    modifier(FunctionCellModifier())
  }

  /// 统一icon样式
  func iconStyle() -> some View {
    modifier(IconModifier())
  }

  /// 隐藏List行分隔线，支持 iOS14
  func hideListRowSeparator() -> some View {
    return self.modifier(ListRowSeperatorModifier())
  }

  func roundedCorner(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners))
  }
}

struct ListBackgroundModifier: ViewModifier {
  func body(content: Content) -> some View {
    if #available(iOS 16.0, *) {
      content
        .scrollContentBackground(.hidden)
    } else {
      content
    }
  }
}

struct IconModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.system(size: 24))
      .foregroundColor(Color.gray)
      .frame(width: 25, height: 25)
  }
}

struct FunctionCellModifier: ViewModifier {
  func body(content: Content) -> some View {
    content
      .padding([.all], 15)
      .background(Color.HamsterCellColor)
      .foregroundColor(Color.HamsterFontColor)
      .cornerRadius(8)
      .hamsterShadow()
//      .padding(.horizontal)
  }
}

@available(iOS 14.0, *)
extension EnvironmentValues {
  var dismiss: () -> Void {
    { presentationMode.wrappedValue.dismiss() }
  }
}

struct ListRowSeperatorModifier: ViewModifier {
  func body(content: Content) -> some View {
    if #available(iOS 15.0, *) {
      content.listRowSeparator(.hidden)
    } else {
      content.onAppear {
        UITableView.appearance().separatorStyle = .none
      }
      .onDisappear {
        UITableView.appearance().separatorStyle = .singleLine
      }
    }
  }
}

struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}
