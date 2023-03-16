//
//  HamsterSuggestion+RimeEngine.swift
//  HamsterKeyboard
//
//  Created by morse on 15/3/2023.
//

import Foundation

extension RimeEngine {
  var suggestions: [HamsterSuggestion] {
    if !status().isComposing {
      return []
    }

    let candidates = context().getCandidates()
    if candidates.isEmpty {
      if userInputKey.isEmpty {
        return []
      }
      let suggestion = HamsterSuggestion(
        text: .space,
        title: userInputKey,
        isAutocomplete: false,
        subtitle: .space
      )
      return [suggestion]
    }

    var result: [HamsterSuggestion] = []
    for i in 0 ..< candidates.count {
      var suggestion = HamsterSuggestion(
        text: candidates[i].text,
        title: .space,
        isAutocomplete: false,
        subtitle: candidates[i].text
      )
      suggestion.comment = candidates[i].comment
      if i == 0 {
        suggestion.title = userInputKey
        suggestion.isAutocomplete = true
      }
      result.append(suggestion)
    }
    return result
  }
}
