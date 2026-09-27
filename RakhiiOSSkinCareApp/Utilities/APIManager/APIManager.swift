//
//  APIManager.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 24/09/26.
//

import Foundation

/// Abstraction injected into view models so they can be tested with a mock.
protocol NetworkClient {
    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T
}

class APIManager: NetworkClient {

    static let shared = APIManager()

    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        guard let url = endpoint.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Accept")

        debugPrint("\(endpoint.method.rawValue) \(url)")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw NetworkError.map(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        debugPrint("STATUS CODE FOR \(url) : \(httpResponse.statusCode)")

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badStatusCode(httpResponse.statusCode)
        }

        // The server sends `Content-Type: text/html` even though the body is JSON,
        // so the MIME type is intentionally not validated here.
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            debugPrint(error)
            throw NetworkError.decodingFailed
        }
    }
}
