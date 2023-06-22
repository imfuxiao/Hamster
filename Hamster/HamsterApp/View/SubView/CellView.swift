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
  case uploadManager
  case fileManager
  case feedback
  case inputKeyFunction
  case swipeGestureMapping
  case numberNineGridSetting
  case symbolSetting
  case about
  case none

  func isNone() -> Bool {
    if case .none = self {
      return true
    }
    return false
  }
}

struct CellViewModel: Identifiable, Equatable {
  static func == (lhs: CellViewModel, rhs: CellViewModel) -> Bool {
    lhs.id == rhs.id
  }

  let id = UUID()

  init(
    cellWidth: CGFloat,
    cellHeight: CGFloat,
    cellName: String,
    imageName: String,
    destinationType: DestinationType,
    toggleValue: Bool = false,
    toggleDidSet: @escaping (Bool) -> Void = { _ in }
  ) {
    self.cellWidth = cellWidth
    self.cellHeight = cellHeight
    self.cellName = cellName
    self.imageName = imageName
    self.destinationType = destinationType
    self.toggleValue = toggleValue
    self.toggleDidSet = toggleDidSet
  }

  var cellWidth: CGFloat
  var cellHeight: CGFloat
  var cellName: String
  var imageName: String
  var destinationType: DestinationType
  var toggleValue: Bool
  var toggleDidSet: (Bool) -> Void
}

struct CellView: View {
  init(cellViewModel: CellViewModel) {
    self.cellViewModel = cellViewModel
    self._toggleValue = State(initialValue: cellViewModel.toggleValue)
  }

  var cellViewModel: CellViewModel

  @EnvironmentObject var appSettings: HamsterAppSettings
  @State var toggleValue: Bool

  var imageView: some View {
    HStack {
      Image(systemName: cellViewModel.imageName)
        .font(.system(size: 18))
        .foregroundColor(Color.HamsterFontColor)

      Spacer()

      if cellViewModel.destinationType.isNone() {
        Toggle("", isOn: $toggleValue)
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

  @State var navigationLinkActive = false

  var body: some View {
    VStack(alignment: .leading) {
      if !cellViewModel.destinationType.isNone() {
        NavigationLink(destination: navigationLinkView, label: {
          VStack(alignment: .leading, spacing: 0) {
            imageView
              .padding(.bottom, 15)
            titleView
          }
        })
//        NavigationLink(destination: navigationLinkView,
//                       isActive: $navigationLinkActive) {}
//          .isDetailLink(false)
//        Button {
//          navigationLinkActive = true
//        } label: {
//          VStack(alignment: .leading, spacing: 0) {
//            imageView
//              .padding(.bottom, 15)
//            titleView
//          }
//        }
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
    .onChange(of: toggleValue, perform: {
      if toggleValue != $0 {
        return
      }
      cellViewModel.toggleDidSet($0)
    })
  }

  @ViewBuilder
  var navigationLinkView: some View {
    switch cellViewModel.destinationType {
    case .inputSchema:
      InputSchemaView()
    case .colorSchema:
      ColorSchemaView()
    case .uploadManager:
      UploadManagerView()
    case .fileManager:
      FileManagerView(appSettings: appSettings)
    case .feedback:
      FeedbackView()
    case .inputKeyFunction:
      InputEditorView()
    case .swipeGestureMapping:
      SwipeGestureActionView()
    case .numberNineGridSetting:
      NumberNineGridSettingView()
    case .symbolSetting:
      SymbolsSettingsView()
    default:
      EmptyView()
    }
  }
}

struct CellView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      CellView(
        cellViewModel: .init(
          cellWidth: 160,
          cellHeight: 100,
          cellName: "按键气泡",
          imageName: "keyboard",
          destinationType: .none
        )
      )
    }
    .environmentObject(RimeContext.shared)
  }
}
