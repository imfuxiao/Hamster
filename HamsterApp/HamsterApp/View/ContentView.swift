//
//  ContentView.swift
//  Hamster
//
//  Created by morse on 10/1/2023.
//

import Combine
import SwiftUI

public struct ContentView: View {
    var appSetings = HamsterAppSettings()

    public var body: some View {
        GeometryReader { proxy in
            NavigationView {
                ZStack {
                    Color.green.opacity(0.1).ignoresSafeArea()

                    ScrollView {
                        Section {
                            Button {} label: {
                                Text("部署")
                                    .frame(width: proxy.size.width - 40, height: 40)
                                    .background(Color.white)
                                    .foregroundColor(.primary)
                                    .cornerRadius(10)
                                    .shadow(radius: 3, x: 1, y: 1)
                            }
                            .buttonStyle(.plain)

                        } header: {
                            HStack {
                                Text("RIME")
                                    .font(.system(.body, design: .rounded))
                                    .fontWeight(.bold)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                        }

                        SettingView(cellWidth: proxy.size.width / 2 - 40, cellHeight: 100)

                        Spacer()

                        VStack {
                            VStack {
                                HStack {
                                    Text("power by rime".uppercased())
                                        .font(.system(.footnote, design: .rounded))
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .navigationTitle(
                        "Hamster输入法"
                    )
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .environmentObject(appSetings)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 13 mini")
    }
}
