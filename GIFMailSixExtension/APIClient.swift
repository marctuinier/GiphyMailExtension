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

typealias GIFFetchCallback = (Result<[String], Error>) -> Void

struct GiphyResponse: Codable {
    let data: [GiphyGif]
}

struct GiphyGif: Codable {
    struct Images: Codable {
        struct Downsized: Codable {
            let url: String
        }
        let downsized: Downsized
    }
    let images: Images
}

class APIClient {
    func fetchGiphy(withQuery query: String, completion: @escaping GIFFetchCallback) {
        
        print("Starting Giphy fetch for query: \(query)")
        
        let apiKey = "q2DA8N3jlGIeDbWdGphUZgci4dX8WjRc" 
        let urlString = "https://api.giphy.com/v1/gifs/search?api_key=\(apiKey)&q=\(query)&limit=25&offset=0&rating=g&lang=en"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(.failure(APIError.invalidURL))
            return
        }
        
        print("Constructed URL: \(url)")
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error during data task: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(APIError.noData))
                return
            }
            
            print("Received data")
            
            do {
                let jsonDecoder = JSONDecoder()
                let response = try jsonDecoder.decode(GiphyResponse.self, from: data)
                
                print("Successfully decoded JSON data")
                
                let gifUrls = response.data.map { $0.images.downsized.url }
                
                print("Extracted \(gifUrls.count) GIF URLs")
                
                completion(.success(gifUrls))
            } catch let jsonError {
                print("JSON decoding error: \(jsonError)")
                completion(.failure(jsonError))
            }
        }
        
        print("Resuming data task")
        task.resume()
    }
}
