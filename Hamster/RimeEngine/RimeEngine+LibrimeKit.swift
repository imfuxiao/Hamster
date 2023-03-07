//
//  RimeEngine+LibrimeKit.swift
//  HamsterApp
//
//  Created by morse on 7/3/2023.
//

import Foundation
import LibrimeKit

extension IRimeContext {
    func getCandidates() -> [Candidate] {
        candidates.map {
            Candidate(text: $0.text, comment: $0.comment)
        }
    }
}
