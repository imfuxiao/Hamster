//
//  CellView.swift
//  HamsterApp
//
//  Created by morse on 6/3/2023.
//

import SwiftUI

struct CellView<SubView: View>: View {
  typealias SubViewBuilder = () -> SubView

  init(
    width: CGFloat,
    height: CGFloat,
    imageName: String,
    featureName: String,
    toggle: Binding<Bool>
  ) where SubView == AnyView {
    self.init(
      width: width,
      height: height,
      imageName: imageName,
      featureName: featureName,
      showSubView: false,
      toggle: toggle,
      navgationDestinationBuilder: nil
    )
  }

  init(
    width: CGFloat,
    height: CGFloat,
    imageName: String,
    featureName: String,
    @ViewBuilder navgationDestinationBuilder: @escaping SubViewBuilder
  ) {
    self.init(
      width: width,
      height: height,
      imageName: imageName,
      featureName: featureName,
      showSubView: true,
      toggle: .constant(false),
      navgationDestinationBuilder: navgationDestinationBuilder
    )
  }

  private init(
    width: CGFloat,
    height: CGFloat,
    imageName: String,
    featureName: String,
    showSubView: Bool,
    toggle: Binding<Bool>,
    navgationDestinationBuilder: SubViewBuilder?
  ) {
    self.width = width
    self.height = height
    self.imageName = imageName
    self.featureName = featureName
    self.showSubView = showSubView
    self._toggleValue = toggle
    self.navgationDestinationBuilder = navgationDestinationBuilder
  }

  var width: CGFloat
  var height: CGFloat
  var imageName: String
  var featureName: String

  var showSubView: Bool
  var navgationDestinationBuilder: SubViewBuilder?

  @Binding
  var toggleValue: Bool

  @EnvironmentObject
  var rimeEngine: RimeEngine

  var imageView: some View {
    HStack {
      Image(systemName: imageName)
        .font(.system(size: 18))
        .foregroundColor(Color.HamsterFontColor)

      Spacer()

      if !showSubView {
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
      Text(featureName)
        .font(.system(size: 16, weight: .bold, design: .rounded))
        .lineLimit(2)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.5)
        .foregroundColor(Color.HamsterFontColor)

      if showSubView {
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
      imageView
        .padding(.bottom, 15)
      if showSubView {
        NavigationLink {
          if let builder = navgationDestinationBuilder {
            builder()
          }
        } label: {
          titleView
        }
      } else {
        titleView
      }
    }
    .frame(width: width, height: height)
    .background(Color.HamsterCellColor)
    .cornerRadius(15)
    .hamsterShadow()
    .navigationBarBackButtonHidden(true)
  }
}

struct CellView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      CellView(
        width: 180, height: 100, imageName: "keyboard", featureName: "方案选择",
        navgationDestinationBuilder: { InputSchemaView(schemas: sampleSchemas) }
      )

      CellView(
        width: 180, height: 100, imageName: "keyboard", featureName: "按键气泡",
        toggle: .constant(false)
      )
    }
    .environmentObject(HamsterAppSettings())
    .environmentObject(RimeEngine.shared)
  }
}

struct CellView2<SubView: View>: View {
  typealias SubViewBuilder = () -> SubView
  
  init(
    width: CGFloat,
    height: CGFloat,
    imageName: String,
    featureName: String,
    toggle: Binding<Bool>
  ) where SubView == AnyView {
    self.init(
      width: width,
      height: height,
      imageName: imageName,
      featureName: featureName,
      showSubView: false,
      toggle: toggle,
      navgationDestinationBuilder: nil
    )
  }
  
  init(
    width: CGFloat,
    height: CGFloat,
    imageName: String,
    featureName: String,
    @ViewBuilder navgationDestinationBuilder: @escaping SubViewBuilder
  ) {
    self.init(
      width: width,
      height: height,
      imageName: imageName,
      featureName: featureName,
      showSubView: true,
      toggle: .constant(false),
      navgationDestinationBuilder: navgationDestinationBuilder
    )
  }
  
  private init(
    width: CGFloat,
    height: CGFloat,
    imageName: String,
    featureName: String,
    showSubView: Bool,
    toggle: Binding<Bool>,
    navgationDestinationBuilder: SubViewBuilder?
  ) {
    self.width = width
    self.height = height
    self.imageName = imageName
    self.featureName = featureName
    self.showSubView = showSubView
    self._toggleValue = toggle
    self.navgationDestinationBuilder = navgationDestinationBuilder
  }
  
  var width: CGFloat
  var height: CGFloat
  var imageName: String
  var featureName: String
  
  var showSubView: Bool
  var navgationDestinationBuilder: SubViewBuilder?
  
  @Binding
  var toggleValue: Bool
  
  @EnvironmentObject
  var rimeEngine: RimeEngine
  
  var imageView: some View {
    HStack {
      Image(systemName: imageName)
        .font(.system(size: 18))
        .foregroundColor(Color.HamsterFontColor)
      
      Spacer()
      
      if !showSubView {
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
      Text(featureName)
        .font(.system(size: 16, weight: .bold, design: .rounded))
        .lineLimit(2)
        .multilineTextAlignment(.leading)
        .minimumScaleFactor(0.5)
        .foregroundColor(Color.HamsterFontColor)
      
      if showSubView {
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
      imageView
        .padding(.bottom, 15)
      if showSubView {
        NavigationLink {
          if let builder = navgationDestinationBuilder {
            builder()
          }
        } label: {
          titleView
        }
      } else {
        titleView
      }
    }
    .frame(width: width, height: height)
    .background(Color.HamsterCellColor)
    .cornerRadius(15)
    .hamsterShadow()
    .navigationBarBackButtonHidden(true)
  }
}
