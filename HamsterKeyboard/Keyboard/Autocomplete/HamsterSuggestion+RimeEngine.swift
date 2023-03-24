//
//  RimeEngine+Suggestion.swift
//  Hamster
//
//  Created by morse on 18/3/2023.
//

import Foundation

let maxCandidateCount = 50

extension RimeEngine {
  var suggestions: [HamsterSuggestion] {
    if !status().isComposing {
      return []
    }

    let candidates = self.candidateListWithIndex(index: 0, andCount: maxCandidateCount)
    if candidates.isEmpty {
      return []
    }

    var result: [HamsterSuggestion] = []
    for i in 0 ..< candidates.count {
      var suggestion = HamsterSuggestion(
        text: candidates[i].text
      )
      suggestion.comment = candidates[i].comment
      if i == 0 {
        suggestion.isAutocomplete = true
      }
      result.append(suggestion)
    }
    return result
  }
}
