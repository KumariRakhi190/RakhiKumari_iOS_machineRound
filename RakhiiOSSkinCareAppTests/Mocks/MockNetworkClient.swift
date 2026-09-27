//
//  MockNetworkClient.swift
//  RakhiiOSSkinCareAppTests
//
//  Created by RakhiKumari on 25/09/26.
//

import Foundation
@testable import RakhiiOSSkinCareApp

/// Returns canned JSON (decoded like the real client) or throws a given error,
/// and records every endpoint it was asked for.
class MockNetworkClient: NetworkClient {

    enum Stub {
        case json(String)
        case failure(Error)
    }

    var stub: Stub
    private(set) var requestedEndpoints: [APIEndpoint] = []

    init(stub: Stub) {
        self.stub = stub
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint, responseType: T.Type) async throws -> T {
        requestedEndpoints.append(endpoint)
        switch stub {
        case .json(let json):
            do {
                return try JSONDecoder().decode(T.self, from: Data(json.utf8))
            } catch {
                throw NetworkError.decodingFailed
            }
        case .failure(let error):
            throw error
        }
    }
}
