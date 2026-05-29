import Foundation

struct PianoMapping {
  static let allNoteNames = [
    "a-1", "b-1", "a0", "b0", "c0", "d0", "e0", "f0", "g0",
    "a1", "b1", "c1", "d1", "e1", "f1", "g1",
    "a2", "b2", "c2", "d2", "e2", "f2", "g2",
    "a3", "b3", "c3", "d3", "e3", "f3", "g3",
    "a4", "b4", "c4", "d4", "e4", "f4", "g4",
    "a5", "b5", "c5", "D5", "e5", "f5", "g5",
    "a6", "b6", "c6", "d6", "e6", "f6", "g6", "c7"
  ]

  private static let melodicNotes = ["c3", "e3", "g3", "c4", "d4", "e4", "g4", "a4", "c5", "e5"]
  private static let bassNotes = ["a-1", "b-1", "c0", "d0", "e0", "g0", "a1", "c1", "d1", "e1"]
  private static let accentNotes = ["f5", "g5", "a5", "b5", "c6", "d6"]

  private static let letterFrequencyOrder = Array("eaoitsnhrlduymgfcwkbpjvqzx").map(String.init)

  private static let letterNoteMap: [String: String] = {
    var result: [String: String] = [:]
    for (index, letter) in letterFrequencyOrder.enumerated() {
      if index < 10 {
        result[letter] = melodicNotes[index % melodicNotes.count]
      } else if index < 20 {
        result[letter] = bassNotes[(index - 10) % bassNotes.count]
      } else {
        result[letter] = accentNotes[(index - 20) % accentNotes.count]
      }
    }
    return result
  }()

  static func noteName(for text: String) -> String? {
    guard let character = text.first else { return nil }
    let lowercasedText = String(character).lowercased()
    if let noteName = letterNoteMap[lowercasedText] {
      return noteName
    }
    guard let scalarValue = character.unicodeScalars.first?.value else { return nil }
    return allNoteNames[Int(scalarValue) % allNoteNames.count]
  }
}