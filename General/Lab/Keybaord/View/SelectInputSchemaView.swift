//
//  SelectInputSchemaView.swift
//  Hamster
//
//  Created by morse on 12/5/2023.
//

import SwiftUI

/// 切换输入方案视图
struct SelectInputSchemaView: View {
  let appearance: HamsterKeyboardAppearance
  var keyboardSize: CGSize
  var schemas: [Schema]

  var backgroundColor: Color {
    guard let colorSchema = appearance.hamsterColorSchema else { return Color.clear }
    return colorSchema.backColor
  }

  @EnvironmentObject var appSettings: HamsterAppSettings
  @EnvironmentObject var rimeContext: RimeContext

  var body: some View {
//    HStack(alignment: .top, spacing: 0) {
    CollectionView(
      collection: schemas,
      scrollDirection: .vertical,
      contentSize: .crossAxisFilled(mainAxisLength: 60),
      itemSpacing: .init(mainAxisSpacing: 0, crossAxisSpacing: 0),
      rawCustomize: { collectionView in
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentOffset.x = .zero
      },
      contentForData: {
        InputSchemaCell(
          schema: $0,
          isSelect: appSettings.rimeInputSchema == $0.schemaId,
          showDivider: true,
          userCheckbox: false,
          action: {
            let inputSchema = appSettings.rimeInputSchema
            appSettings.rimeInputSchema = $0.schemaId
            appSettings.lastUseRimeInputSchema = inputSchema
            let handled = Rime.shared.setSchema($0.schemaId)
            Logger.shared.log.debug("switch input schema: rimeInputSchema = \(appSettings.rimeInputSchema), lastUseRimeInputSchema = \(appSettings.lastUseRimeInputSchema), handled: \(handled)")
            rimeContext.reset()
            appSettings.keyboardStatus = .normal
          }
        )
        .padding(.leading, 5)
      }
    )
    .frame(width: keyboardSize.width - appSettings.candidateBarHeight, height: keyboardSize.height + appSettings.candidateBarHeight)
    .padding(.horizontal)
    .padding(.top)

//      // 收起按钮
//      CandidateBarArrowButton(
//        size: appSettings.candidateBarHeight,
//        hamsterColor: hamsterColor,
//        imageName: appSettings.candidateBarArrowButtonImageName,
//        showDivider: appSettings.showDivider,
//        action: {
//          appSettings.keyboardStatus = .normal
//        }
//      )
//    }
//    .frame(width: keyboardSize.width)
//    .frame(height: keyboardSize.height + appSettings.candidateBarHeight)
//    .background(backgroundColor)
  }
}
