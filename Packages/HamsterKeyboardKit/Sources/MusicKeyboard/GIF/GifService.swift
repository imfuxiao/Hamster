//
//  GifService.swift
//
//
//  Created by Cascade on 2026/5/29.
//

import Foundation

/// GIF 数据模型
struct GifResult: Codable {
  let id: String
  let url: String
  let previewUrl: String?
  let title: String?

  enum CodingKeys: String, CodingKey {
    case id
    case url
    case previewUrl = "preview_url"
    case title
  }
}

/// Tenor API 响应模型
struct TenorResponse: Codable {
  let results: [TenorResult]

  struct TenorResult: Codable {
    let id: String
    let media: [TenorMedia]
    let title: String?

    struct TenorMedia: Codable {
      let tinygif: TenorGif?
      let gif: TenorGif?

      struct TenorGif: Codable {
        let url: String
        let preview: String?
      }
    }
  }
}

/// GIF 服务
class GifService {
  static let shared = GifService()

  private init() {}

  /// 搜索 GIF
  /// - Parameters:
  ///   - query: 搜索关键词
  ///   - completion: 完成回调，返回 GIF 列表或错误
  func searchGifs(query: String, completion: @escaping (Result<[GifResult], Error>) -> Void) {
    let settings = MusicKeyboardSettings.shared

    // 检查 API Key
    guard !settings.gifApiKey.isEmpty else {
      let error = NSError(domain: "GifService", code: 401, userInfo: [NSLocalizedDescriptionKey: "请先在设置中配置 GIF API Key"])
      completion(.failure(error))
      return
    }

    // 构建请求 URL
    guard var components = URLComponents(string: settings.gifApiUrl + "/search") else {
      let error = NSError(domain: "GifService", code: 400, userInfo: [NSLocalizedDescriptionKey: "无效的 API URL"])
      completion(.failure(error))
      return
    }

    components.queryItems = [
      URLQueryItem(name: "q", value: query),
      URLQueryItem(name: "key", value: settings.gifApiKey),
      URLQueryItem(name: "limit", value: "10"),
      URLQueryItem(name: "media_filter", value: "gif,tinygif")
    ]

    guard let url = components.url else {
      let error = NSError(domain: "GifService", code: 400, userInfo: [NSLocalizedDescriptionKey: "无法构建请求 URL"])
      completion(.failure(error))
      return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // 发送请求
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
      if let error = error {
        completion(.failure(error))
        return
      }

      guard let httpResponse = response as? HTTPURLResponse else {
        let error = NSError(domain: "GifService", code: 500, userInfo: [NSLocalizedDescriptionKey: "无效的响应"])
        completion(.failure(error))
        return
      }

      guard httpResponse.statusCode == 200 else {
        let error = NSError(domain: "GifService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API 请求失败，状态码：\(httpResponse.statusCode)"])
        completion(.failure(error))
        return
      }

      guard let data = data else {
        let error = NSError(domain: "GifService", code: 500, userInfo: [NSLocalizedDescriptionKey: "无响应数据"])
        completion(.failure(error))
        return
      }

      do {
        let response = try JSONDecoder().decode(TenorResponse.self, from: data)
        let gifResults = response.results.compactMap { result -> GifResult? in
          // 优先使用 tinygif，否则使用 gif
          let media = result.media.first
          let gifData = media?.tinygif ?? media?.gif

          guard let url = gifData?.url else { return nil }

          return GifResult(
            id: result.id,
            url: url,
            previewUrl: gifData?.preview,
            title: result.title
          )
        }
        completion(.success(gifResults))
      } catch {
        completion(.failure(error))
      }
    }

    task.resume()
  }
}
