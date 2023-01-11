enum CharacterSlideSensitivity: Codable, Identifiable {
  case low, medium, high, custom(points: Int)
}

extension CharacterSlideSensitivity {
  var id: Int {
    points
  }
  
  var points: Int {
    switch self {
    case .low: return 10
    case .medium: return 5
    case .high: return 2
    case .custom(let points): return points
    }
  }
}
