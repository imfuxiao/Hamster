import Foundation
import HamsterKit

struct MusicKeyboardSettings {
  static let shared = MusicKeyboardSettings()

  private let pianoEnabledKey = "music_keyboard_piano_enabled"
  private let pianoVolumeKey = "music_keyboard_piano_volume"

  var isPianoEnabled: Bool {
    UserDefaults.hamster.object(forKey: pianoEnabledKey) as? Bool ?? true
  }

  var pianoVolume: Float {
    let value = UserDefaults.hamster.object(forKey: pianoVolumeKey) as? Double ?? 0.8
    return Float(min(max(value, 0), 1))
  }
}
