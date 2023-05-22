//
//  RowView.swift
//  HamsterApp
//
//  Created by morse on 5/3/2023.
//

import SwiftUI

struct SettingView: View {
  let cells: [CellViewModel]
  let cellDestinationRoute: CellDestinationRoute

  init(cells: [CellViewModel], cellDestinationRoute: CellDestinationRoute) {
    self.cells = cells
    self.cellDestinationRoute = cellDestinationRoute
  }

  var body: some View {
    SectionView("设置") {
      LazyVGrid(
        columns: [
          GridItem(.adaptive(minimum: 160)),
        ],
        alignment: .center,
        spacing: 20
      ) {
        ForEach(cells) {
          CellView(cellDestinationRoute: cellDestinationRoute, cellViewModel: $0)
        }
      }
      .padding(.horizontal)
    }
  }
}

struct RowView_Previews: PreviewProvider {
  static var cellDestinationRoute = CellDestinationRoute()

  static var previews: some View {
    VStack {
      SettingView(
        cells: createCells(
          cellWidth: 180,
          cellHeight: 100,
          appSettings: ObservedObject(wrappedValue: HamsterAppSettings())
        ),
        cellDestinationRoute: Self.cellDestinationRoute
      )
    }
    .background(Color.green.opacity(0.1))
  }
}
