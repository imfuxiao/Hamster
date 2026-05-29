import AVFoundation
import Foundation

final class PianoAudioPlayer {
  static let shared = PianoAudioPlayer()

  private var playerPool: [String: [AVAudioPlayer]] = [:]
  private var playerIndexes: [String: Int] = [:]
  private let poolSize = 2

  private init() {
    configureAudioSession()
  }

  func playText(_ text: String) {
    guard MusicKeyboardSettings.shared.isPianoEnabled else { return }
    guard let noteName = PianoMapping.noteName(for: text) else { return }
    play(noteName)
  }

  private func configureAudioSession() {
    try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
    try? AVAudioSession.sharedInstance().setActive(true)
  }

  private func players(for noteName: String) -> [AVAudioPlayer] {
    if let players = playerPool[noteName] {
      return players
    }
    guard let url = Bundle.hamsterKeyboard.url(forResource: noteName, withExtension: "mp3", subdirectory: "Audio") else { return [] }
    var players: [AVAudioPlayer] = []
    for _ in 0 ..< poolSize {
      if let player = try? AVAudioPlayer(contentsOf: url) {
        player.volume = MusicKeyboardSettings.shared.pianoVolume
        player.prepareToPlay()
        players.append(player)
      }
    }
    playerPool[noteName] = players
    playerIndexes[noteName] = 0
    return players
  }

  private func play(_ noteName: String) {
    let players = players(for: noteName)
    guard !players.isEmpty else { return }
    let currentIndex = playerIndexes[noteName] ?? 0
    let player = players[currentIndex]
    player.volume = MusicKeyboardSettings.shared.pianoVolume
    if player.isPlaying {
      player.currentTime = 0
    }
    player.play()
    playerIndexes[noteName] = (currentIndex + 1) % players.count
  }
}