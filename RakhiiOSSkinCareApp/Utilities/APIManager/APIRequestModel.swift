//
//  APIRequestModel.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 24/09/26.
//

import Foundation

enum MethodType: String {
    case post = "POST"
    case get = "GET"
    case put = "PUT"
    case delete = "DELETE"
}

/// Common envelope returned by the mobilehubs APIs:
/// `{ "status": true, "message": "...", "data": [ ... ] }`
struct APIResponse<T: Decodable>: Decodable {
    let status: Bool
    let message: String?
    let data: [T]

    enum CodingKeys: String, CodingKey {
        case status, message, data
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        status = try container.decodeIfPresent(Bool.self, forKey: .status) ?? false
        message = try container.decodeIfPresent(String.self, forKey: .message)
        // `data` can be missing or null when nothing is found; treat it as empty.
        data = try container.decodeIfPresent([T].self, forKey: .data) ?? []
    }
}
