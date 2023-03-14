enum CharacterSlideSensitivity: Codable, Identifiable {
  case low, medium, high
  case custom(points: Int)
}

extension CharacterSlideSensitivity {
  var id: Int {
    points
  }

  var points: Int {
    switch self {
    case .low: return 30
    case .medium: return 20
    case .high: return 10
    case .custom(let points): return points
    }
  }
}
