//
//  AIService.swift
//
//
//  Created by Cascade on 2026/5/29.
//

import Foundation

/// AI 服务
class AIService {
  static let shared = AIService()

  private init() {}

  /// 生成 AI 回复建议
  /// - Parameters:
  ///   - context: 上下文文本
  ///   - completion: 完成回调，返回建议列表或错误
  func generateSuggestions(context: String, completion: @escaping (Result<[String], Error>) -> Void) {
    let settings = MusicKeyboardSettings.shared

    // 检查 API Key
    guard !settings.aiApiKey.isEmpty else {
      let error = NSError(domain: "AIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "请先在设置中配置 API Key"])
      completion(.failure(error))
      return
    }

    // 构建请求
    guard let url = URL(string: settings.aiApiUrl) else {
      let error = NSError(domain: "AIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "无效的 API URL"])
      completion(.failure(error))
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(settings.aiApiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // 构建请求体
    let requestBody: [String: Any] = [
      "model": settings.aiModelId,
      "messages": [
        [
          "role": "system",
          "content": settings.aiSystemPrompt
        ],
        [
          "role": "user",
          "content": "上下文：\(context)\n\n请生成 3 条简短的回复建议，每条建议用换行符分隔。"
        ]
      ],
      "temperature": 0.7,
      "max_tokens": 200
    ]

    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    } catch {
      completion(.failure(error))
      return
    }

    // 发送请求
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        let error = NSError(domain: "AIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "无效的响应"])
        completion(.failure(error))
        return
      }

      guard httpResponse.statusCode == 200 else {
        let error = NSError(domain: "AIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API 请求失败，状态码：\(httpResponse.statusCode)"])
        completion(.failure(error))
        return
      }

      guard let data = data else {
        let error = NSError(domain: "AIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "无响应数据"])
        completion(.failure(error))
        return
      }

      do {
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {

          // 解析建议
          let suggestions = content.components(separatedBy: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

          // 限制为 3 条
          let limitedSuggestions = Array(suggestions.prefix(3))
          completion(.success(limitedSuggestions))
        } else {
          let error = NSError(domain: "AIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "解析响应失败"])
          completion(.failure(error))
        }
      } catch {
        completion(.failure(error))
      }
    }

    task.resume()
  }

  /// 生成 GIF 搜索关键词
  /// - Parameters:
  ///   - context: 上下文文本
  ///   - completion: 完成回调，返回关键词列表或错误
  func generateGifKeywords(context: String, completion: @escaping (Result<[String], Error>) -> Void) {
    let settings = MusicKeyboardSettings.shared

    // 检查 API Key
    guard !settings.aiApiKey.isEmpty else {
      let error = NSError(domain: "AIService", code: 401, userInfo: [NSLocalizedDescriptionKey: "请先在设置中配置 API Key"])
      completion(.failure(error))
      return
    }

    // 构建请求
    guard let url = URL(string: settings.aiApiUrl) else {
      let error = NSError(domain: "AIService", code: 400, userInfo: [NSLocalizedDescriptionKey: "无效的 API URL"])
      completion(.failure(error))
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("Bearer \(settings.aiApiKey)", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // 构建请求体
    let requestBody: [String: Any] = [
      "model": settings.aiModelId,
      "messages": [
        [
          "role": "system",
          "content": "你是一个 GIF 搜索助手，根据上下文生成 3-5 个简短的 GIF 搜索关键词，每个关键词用逗号分隔。"
        ],
        [
          "role": "user",
          "content": "上下文：\(context)\n\n请生成适合的 GIF 搜索关键词。"
        ]
      ],
      "temperature": 0.7,
      "max_tokens": 100
    ]

    do {
      request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
    } catch {
      completion(.failure(error))
      return
    }

    // 发送请求
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        let error = NSError(domain: "AIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "无效的响应"])
        completion(.failure(error))
        return
      }

      guard httpResponse.statusCode == 200 else {
        let error = NSError(domain: "AIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API 请求失败，状态码：\(httpResponse.statusCode)"])
        completion(.failure(error))
        return
      }

      guard let data = data else {
        let error = NSError(domain: "AIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "无响应数据"])
        completion(.failure(error))
        return
      }

      do {
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let choices = json["choices"] as? [[String: Any]],
           let firstChoice = choices.first,
           let message = firstChoice["message"] as? [String: Any],
           let content = message["content"] as? String {

          // 解析关键词
          let keywords = content.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

          // 限制为 5 个
          let limitedKeywords = Array(keywords.prefix(5))
          completion(.success(limitedKeywords))
        } else {
          let error = NSError(domain: "AIService", code: 500, userInfo: [NSLocalizedDescriptionKey: "解析响应失败"])
          completion(.failure(error))
        }
      } catch {
        completion(.failure(error))
      }
    }

    task.resume()
  }
}
