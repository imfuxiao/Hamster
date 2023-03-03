//
//  InputSet.swift
//  HamsterKeyboard
//
//  Created by morse on 4/3/2023.
//

import Foundation
import KeyboardKit

struct GridInputSet: InputSet {
    var rows: KeyboardKit.InputSetRows

    init(rows: KeyboardKit.InputSetRows) {
        self.rows = rows
    }
}

extension GridInputSet {
    static let numberGrid: GridInputSet = .init(rows: [
        .init(chars: "+123"),
        .init(chars: "-456*"),
        .init(chars: "789/"),
        .init(chars: ",0."),
    ])
}
