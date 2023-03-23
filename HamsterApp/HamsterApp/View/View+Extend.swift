//
//  View+Extend.swift
//  HamsterApp
//
//  Created by morse on 2023/3/23.
//

import SwiftUI

@available(iOS 14.0, *)
extension EnvironmentValues {
    var dismiss: () -> Void {
        { presentationMode.wrappedValue.dismiss() }
    }
}
