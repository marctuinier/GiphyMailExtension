//
//  APIClient.swift
//  GIFMailSixExtension
//
//  Created by Marc Tuinier on 9/16/23.
//

import Foundation

enum APIError: String, Error {
    case invalidURL = "Invalid URL"
    case noData = "No data received"
    case unexpectedJSONStructure = "Unexpected JSON structure"
}

typealias GIFFetchCallback = @Sendable (Result<[String], Error>) -> Void

struct GiphyResponse: Codable, Sendable {
    let data: [GiphyGif]
}

struct GiphyGif: Codable, Sendable {
    struct Images: Codable, Sendable {
        struct Downsized: Codable, Sendable {
            let url: String
        }
        let downsized: Downsized
    }
    let images: Images
}

final class APIClient: Sendable {
    // Giphy public beta API key — safe for client-side use
    private static let apiKey = "q2DA8N3jlGIeDbWdGphUZgci4dX8WjRc"

    func fetchGiphy(withQuery query: String, completion: @escaping GIFFetchCallback) {
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let urlString = "https://api.giphy.com/v1/gifs/search?api_key=\(Self.apiKey)&q=\(encodedQuery)&limit=25&offset=0&rating=g&lang=en"

        guard let url = URL(string: urlString) else {
            completion(.failure(APIError.invalidURL))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }

            do {
                let response = try JSONDecoder().decode(GiphyResponse.self, from: data)
                let gifUrls = response.data.map { $0.images.downsized.url }
                completion(.success(gifUrls))
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
