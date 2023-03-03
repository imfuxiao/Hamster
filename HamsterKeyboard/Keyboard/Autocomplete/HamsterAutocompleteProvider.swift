import Combine
import Foundation
import KeyboardKit

class HamsterAutocompleteProvider: AutocompleteProvider {
    private var rimeEngine: RimeEngine
  
    init(engine: RimeEngine) {
        rimeEngine = engine
    }
  
    var locale: Locale = .current
  
    var canIgnoreWords: Bool { false }
    var canLearnWords: Bool { false }
    var ignoredWords: [String] = []
    var learnedWords: [String] = []
  
    func hasIgnoredWord(_ word: String) -> Bool { false }
    func hasLearnedWord(_ word: String) -> Bool { false }
    func ignoreWord(_ word: String) {}
    func learnWord(_ word: String) {}
    func removeIgnoredWord(_ word: String) {}
    func unlearnWord(_ word: String) {}
  
    func autocompleteSuggestions(for text: String, completion: AutocompleteCompletion) {
        // TODO: 这里可以根据text添加词库
        completion(.success(rimeEngine.suggestions))
    }
}

extension RimeEngine {
    var suggestions: [AutocompleteSuggestion] {
        if !status().isComposing {
            return []
        }
    
        let candidates = context().getCandidates()
        if candidates.isEmpty {
            if userInputKey.isEmpty {
                return []
            }
            let suggestion = AutocompleteSuggestion(
                text: .space,
                title: userInputKey,
                isAutocomplete: false,
                subtitle: .space
            )
            return [suggestion]
        }
    
        var result: [AutocompleteSuggestion] = []
        for i in 0 ..< candidates.count {
            var suggestion = AutocompleteSuggestion(
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

extension AutocompleteSuggestion {
    var comment: String? {
        get {
            if let comment = additionalInfo["comment"] {
                return comment as? String
            }
            return nil
        }
        set {
            additionalInfo["comment"] = newValue
        }
    }
}
