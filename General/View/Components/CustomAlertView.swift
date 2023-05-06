//
//  CustomAlertView.swift
//  Hamster
//
//  Created by morse on 18/5/2023.
//

import SwiftUI

struct CustomAlertView<Content: View>: View {
  @Environment(\.colorScheme) var colorScheme

  let title: String
  let description: String?

  var cancelAction: (() -> Void)?
  var cancelActionTitle: String?

  var primaryAction: (() -> Void)?
  var primaryActionTitle: String?

  var customContent: Content?

  init(
    title: String,
    description: String?,
    cancelAction: (() -> Void)? = nil,
    cancelActionTitle: String? = nil,
    primaryAction: (() -> Void)? = nil,
    primaryActionTitle: String? = nil,
    customContent: Content? = EmptyView()
  ) {
    self.title = title
    self.description = description
    self.cancelAction = cancelAction
    self.cancelActionTitle = cancelActionTitle
    self.primaryAction = primaryAction
    self.primaryActionTitle = primaryActionTitle
    self.customContent = customContent
  }

  var body: some View {
    HStack {
      VStack(spacing: 0) {
        Text(title)
          .font(.system(size: 16, weight: .semibold, design: .default))
          .padding(.top)
          .padding(.bottom, 8)

        if let description = description {
          Text(description)
            .font(.system(size: 12, weight: .light, design: .default))
            .multilineTextAlignment(.center)
            .padding([.bottom, .trailing, .leading])
        }

        customContent

        Divider()

        HStack {
          if let primaryAction, let primaryActionTitle {
            Button { primaryAction() } label: {
              Text("**\(primaryActionTitle)**")
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                .foregroundColor(.red)
            }
          }

          if cancelActionTitle != nil && primaryActionTitle != nil {
            Divider()
          }

          if let cancelAction, let cancelActionTitle {
            Button { cancelAction() } label: {
              Text(cancelActionTitle)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
            }
          }

        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50, alignment: .center)
      }
      .frame(minWidth: 0, maxWidth: 400, alignment: .center)
      .background(Color.HamsterBackgroundColor)
      .cornerRadius(10)
      .padding([.trailing, .leading], 50)
    }
    .zIndex(1)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    .background(
      colorScheme == .dark
        ? Color(red: 0, green: 0, blue: 0, opacity: 0.4)
        : Color(red: 1, green: 1, blue: 1, opacity: 0.4)
    )
  }
}

extension View {
  func customAlert(showAlert: Binding<Bool>, title: String, message: String? = nil) -> some View {
    ZStack(alignment: .center) {
      self

      if showAlert.wrappedValue {
        CustomAlertView(
          title: title,
          description: message,
          cancelAction: {
            // Cancel action here
            withAnimation {
              showAlert.wrappedValue.toggle()
            }
          },
          cancelActionTitle: "关闭"
        )
      }
    }
  }

  func customAlert(
    showAlert: Binding<Bool>,
    title: String,
    message: String? = nil,
    primaryTitle: String? = "确定",
    primaryAction: (() -> Void)? = nil
  ) -> some View {
    ZStack(alignment: .center) {
      self

      if showAlert.wrappedValue {
        CustomAlertView(
          title: title,
          description: message,
          primaryAction: {
            // Cancel action here
            withAnimation {
              primaryAction?()
              showAlert.wrappedValue.toggle()
            }
          },
          primaryActionTitle: primaryTitle
        )
      }
    }
  }

  func customAlert(
    showAlert: Binding<Bool>,
    title: String,
    message: String? = nil,
    primaryTitle: String? = "确定",
    primaryAction: (() -> Void)? = nil,
    cancelTitle: String? = "取消",
    cancelAction: (() -> Void)? = nil
  ) -> some View {
    ZStack(alignment: .center) {
      self

      if showAlert.wrappedValue {
        Color.clear.overlay(
          CustomAlertView(
            title: title,
            description: message,
            cancelAction: {
              withAnimation {
                cancelAction?()
                showAlert.wrappedValue.toggle()
              }
            },
            cancelActionTitle: cancelTitle,
            primaryAction: {
              withAnimation {
                primaryAction?()
                showAlert.wrappedValue.toggle()
              }
            },
            primaryActionTitle: primaryTitle
          )
        )
      }
    }
  }
}

struct CustomAlertView_Previews: PreviewProvider {
  struct CustomAlertViewDemo: View {
    @State private var showAlert1 = false
    @State private var showAlert2 = false
    @State private var showAlert3 = false
    @State private var showAlert4 = false

    var body: some View {
      VStack {
        Button("Show alert1") {
          withAnimation {
            showAlert1.toggle()
          }
        }
        .customAlert(showAlert: $showAlert1, title: "标题1")

        Button("Show alert2") {
          withAnimation {
            showAlert2.toggle()
          }
        }
        .customAlert(showAlert: $showAlert2, title: "标题2", message: "标题描述")

        Button("Show alert3") {
          withAnimation {
            showAlert3.toggle()
          }
        }
        .customAlert(showAlert: $showAlert3, title: "primary", message: "primary标题描述", primaryTitle: "确定") {
          DispatchQueue.main.asyncAfter(deadline: .now() + 5) {}
        }

        Button("Show alert4") {
          withAnimation {
            showAlert4.toggle()
          }
        }
        .customAlert(showAlert: $showAlert4, title: "primary", message: "primary标题描述", primaryTitle: "是", primaryAction: {}, cancelTitle: "否", cancelAction: {})
      }
//        if showAlert {
//          CustomAlertView(
//            title: "Alert title",
//            description: "Description here",
//            cancelAction: {
//              // Cancel action here
//              withAnimation {
//                showAlert.toggle()
//              }
//            },
//            cancelActionTitle: "Cancel",
//            primaryAction: {
//              // Primary action here
//              withAnimation {
//                showAlert.toggle()
//              }
//            },
//            primaryActionTitle: "Action",
//            customContent:
//            Text("Custom content here")
//              .padding([.trailing, .leading, .bottom])
//          )
//        }
    }
  }

  static var previews: some View {
    CustomAlertViewDemo()
  }
}
