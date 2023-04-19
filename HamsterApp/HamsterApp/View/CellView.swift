//
//  CellView.swift
//  HamsterApp
//
//  Created by morse on 6/3/2023.
//

import SwiftUI

enum DestinationType {
  case inputSchema
  case colorSchema
  case fileManager
  case fileEditor
  case feedback
  case inputKeyFuction
  case upAndDownSlideInputSymbol
  case about
  case none

  func isNone() -> Bool {
    if case .none = self {
      return true
    }
    return false
  }
}

protocol CellDestination {
  associatedtype DestinationType
  associatedtype View: SwiftUI.View

  @ViewBuilder
  func view(type: DestinationType) -> View
}

struct CellDestinationRoute: CellDestination {
  @ViewBuilder
  func view(type: DestinationType) -> some View {
    switch type {
    case .inputSchema:
      InputSchemaView()
    case .colorSchema:
      ColorSchemaView()
    case .fileManager:
      FileManagerView()
    case .fileEditor:
      EditorView()
    case .feedback:
      FeedbackView()
    case .inputKeyFuction:
      InputEditorView()
    case .upAndDownSlideInputSymbol:
      UpAndDownSlideInputSymbolView()
    case .about:
      AboutView()
    default:
      EmptyView()
    }
  }
}

struct CellViewModel: Identifiable, Equatable {
  static func == (lhs: CellViewModel, rhs: CellViewModel) -> Bool {
    lhs.id == rhs.id
  }

  let id = UUID()

//  var appSettings: HamsterAppSettings
  var cellWidth: CGFloat
  var cellHeight: CGFloat
  var cellName: String
  var imageName: String
  var destinationType: DestinationType
  var toggleValue: Bool = false
  var toggleDidSet: (_ value: Bool) -> Void = { _ in }
}

struct CellView: View {
  let cellDestinationRoute: CellDestinationRoute
  var cellViewModel: CellViewModel
  @State var toggleState: Bool

  init(cellDestinationRoute: CellDestinationRoute, cellViewModel: CellViewModel) {
    self.cellDestinationRoute = cellDestinationRoute
    self.cellViewModel = cellViewModel
    self._toggleState = State(initialValue: cellViewModel.toggleValue)
  }

  var imageView: some View {
    HStack {
      Image(systemName: cellViewModel.imageName)
        .font(.system(size: 18))
        .foregroundColor(Color.HamsterFontColor)

      Spacer()

      if cellViewModel.destinationType.isNone() {
        Toggle("", isOn: $toggleState)
          .fixedSize()
          .frame(width: 0, height: 0)
          .scaleEffect(0.7)
          .padding(.trailing)
      }
    }
    .padding(.horizontal)
  }

  var titleView: some View {
    HStack(spacing: 0) {
      Text(cellViewModel.cellName)
        .font(.system(size: 16, weight: .bold, design: .rounded))
        .lineLimit(2)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.5)
        .foregroundColor(Color.HamsterFontColor)

      if !cellViewModel.destinationType.isNone() {
        Image(systemName: "chevron.right")
          .font(.system(size: 12))
          .padding(.leading, 5)
          .foregroundColor(Color.HamsterFontColor)
      }
    }
    .padding(.horizontal)
    .foregroundColor(.primary)
  }

  var body: some View {
    VStack(alignment: .leading) {
      if !cellViewModel.destinationType.isNone() {
        NavigationLink {
          cellDestinationRoute.view(type: cellViewModel.destinationType)
        } label: {
          VStack(alignment: .leading, spacing: 0) {
            imageView
              .padding(.bottom, 15)
            titleView
          }
        }
      } else {
        imageView
          .padding(.bottom, 15)
        titleView
      }
    }
    .frame(width: cellViewModel.cellWidth, height: cellViewModel.cellHeight)
    .background(Color.HamsterCellColor)
    .cornerRadius(15)
    .hamsterShadow()
    .navigationBarBackButtonHidden(true)
    .onChange(of: toggleState, perform: {
      cellViewModel.toggleDidSet($0)
    })
  }
}

/// cell创建
func createCells(cellWidth: CGFloat, cellHeight: CGFloat, appSettings: HamsterAppSettings) -> [CellViewModel] {
  [
    CellViewModel(
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      cellName: "输入方案",
      imageName: "keyboard",
      destinationType: .inputSchema
    ),
    CellViewModel(
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      cellName: "配色选择",
      imageName: "paintpalette",
      destinationType: .colorSchema
    ),
    CellViewModel(
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      cellName: "键盘反馈",
      imageName: "hand.tap",
      destinationType: .feedback
    ),
    CellViewModel(
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      cellName: "输入方案上传",
      imageName: "network",
      destinationType: .fileManager
    ),
    CellViewModel(
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      cellName: "文件编辑",
      imageName: "creditcard",
      destinationType: .fileEditor
    ),
    CellViewModel(
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      cellName: "按键气泡",
      imageName: "bubble.middle.bottom",
      destinationType: .none,
      toggleValue: appSettings.showKeyPressBubble,
      toggleDidSet: { value in
        appSettings.showKeyPressBubble = value
      }
    ),
    CellViewModel(
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      cellName: "键盘收起键",
      imageName: "chevron.down.circle",
      destinationType: .none,
      toggleValue: appSettings.showKeyboardDismissButton,
      toggleDidSet: { value in
        appSettings.showKeyboardDismissButton = value
      }
    ),
//    CellViewModel(
//      cellWidth: cellWidth,
//      cellHeight: cellHeight,
//      cellName: "繁体中文",
//      imageName: "character",
//      destinationType: .none,
//      toggleValue: appSettings.switchTraditionalChinese,
//      toggleDidSet: { value in
//        appSettings.switchTraditionalChinese = value
//      }
//    ),
    CellViewModel(
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      cellName: "空格滑动",
      imageName: "lasso",
      destinationType: .none,
      toggleValue: appSettings.slideBySpaceButton,
      toggleDidSet: { value in
        appSettings.slideBySpaceButton = value
      }
    ),
    CellViewModel(
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      cellName: "数字九宫格",
      imageName: "number.square",
      destinationType: .none,
      toggleValue: appSettings.enableNumberNineGrid,
      toggleDidSet: { value in
        appSettings.enableNumberNineGrid = value
      }
    ),
    CellViewModel(
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      cellName: "输入功能调整",
      imageName: "gear",
      destinationType: .inputKeyFuction
    ),
    CellViewModel(
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      cellName: "上下滑动输入数字符号",
      imageName: "arrow.up.arrow.down",
      destinationType: .upAndDownSlideInputSymbol
    ),
    CellViewModel(
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      cellName: "关于",
      imageName: "info.circle",
      destinationType: .about
    ),
  ]
}

struct CellView_Previews: PreviewProvider {
  static let cellDestinationRoute = CellDestinationRoute()
  static var previews: some View {
    VStack {
      CellView(
        cellDestinationRoute: cellDestinationRoute,
        cellViewModel:
        .init(
          cellWidth: 160,
          cellHeight: 100,
          cellName: "按键气泡",
          imageName: "keyboard",
          destinationType: .none
        )
      )
    }
    .environmentObject(HamsterAppSettings())
    .environmentObject(RimeEngine())
  }
}
