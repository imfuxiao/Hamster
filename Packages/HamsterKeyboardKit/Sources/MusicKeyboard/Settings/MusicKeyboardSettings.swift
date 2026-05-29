import Foundation
import HamsterKit

struct MusicKeyboardSettings {
  static let shared = MusicKeyboardSettings()

  // MARK: - 钢琴音设置

  private let pianoEnabledKey = "music_keyboard_piano_enabled"
  private let pianoVolumeKey = "music_keyboard_piano_volume"
  private let pianoMoodKey = "music_keyboard_piano_mood"

  var isPianoEnabled: Bool {
    get {
      UserDefaults.hamster.object(forKey: pianoEnabledKey) as? Bool ?? true
    }
    set {
      UserDefaults.hamster.set(newValue, forKey: pianoEnabledKey)
    }
  }

  var pianoVolume: Float {
    get {
      let value = UserDefaults.hamster.object(forKey: pianoVolumeKey) as? Double ?? 0.8
      return Float(min(max(value, 0), 1))
    }
    set {
      UserDefaults.hamster.set(Double(newValue), forKey: pianoVolumeKey)
    }
  }

  var pianoMood: Int {
    get {
      UserDefaults.hamster.object(forKey: pianoMoodKey) as? Int ?? 0
    }
    set {
      UserDefaults.hamster.set(newValue, forKey: pianoMoodKey)
    }
  }

  // MARK: - AI 设置

  private let aiApiUrlKey = "music_keyboard_ai_api_url"
  private let aiApiKeyKey = "music_keyboard_ai_api_key"
  private let aiModelIdKey = "music_keyboard_ai_model_id"
  private let aiSystemPromptKey = "music_keyboard_ai_system_prompt"

  var aiApiUrl: String {
    get {
      UserDefaults.hamster.string(forKey: aiApiUrlKey) ?? "https://open.bigmodel.cn/api/paas/v4/chat/completions"
    }
    set {
      UserDefaults.hamster.set(newValue, forKey: aiApiUrlKey)
    }
  }

  var aiApiKey: String {
    get {
      UserDefaults.hamster.string(forKey: aiApiKeyKey) ?? ""
    }
    set {
      UserDefaults.hamster.set(newValue, forKey: aiApiKeyKey)
    }
  }

  var aiModelId: String {
    get {
      UserDefaults.hamster.string(forKey: aiModelIdKey) ?? "glm-4-flash"
    }
    set {
      UserDefaults.hamster.set(newValue, forKey: aiModelIdKey)
    }
  }

  var aiSystemPrompt: String {
    get {
      UserDefaults.hamster.string(forKey: aiSystemPromptKey) ?? "你是一个友好的助手，根据上下文生成 3 条简短的回复建议。"
    }
    set {
      UserDefaults.hamster.set(newValue, forKey: aiSystemPromptKey)
    }
  }

  // MARK: - GIF 设置

  private let gifApiUrlKey = "music_keyboard_gif_api_url"
  private let gifApiKeyKey = "music_keyboard_gif_api_key"

  var gifApiUrl: String {
    get {
      UserDefaults.hamster.string(forKey: gifApiUrlKey) ?? "https://tenor.googleapis.com/v2"
    }
    set {
      UserDefaults.hamster.set(newValue, forKey: gifApiUrlKey)
    }
  }

  var gifApiKey: String {
    get {
      UserDefaults.hamster.string(forKey: gifApiKeyKey) ?? ""
    }
    set {
      UserDefaults.hamster.set(newValue, forKey: gifApiKeyKey)
    }
  }
}
