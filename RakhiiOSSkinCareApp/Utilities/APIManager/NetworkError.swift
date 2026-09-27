//
//  NetworkError.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 25/09/26.
//

import Foundation

enum NetworkError: Error, Equatable {
    case invalidURL
    case noInternet
    case timeout
    case invalidResponse
    case badStatusCode(Int)
    case decodingFailed
    case serverError(String)
    case unknown(String)

    /// Message shown to the user on the error state.
    var userMessage: String {
        switch self {
        case .invalidURL:
            return "Something went wrong while preparing the request."
        case .noInternet:
            return "No internet connection. Please check your connection and try again."
        case .timeout:
            return "The request timed out. Please try again."
        case .invalidResponse:
            return "The server sent an invalid response. Please try again."
        case .badStatusCode(let code):
            return "The server returned an error (code \(code)). Please try again later."
        case .decodingFailed:
            return "We couldn't read the data from the server. Please try again later."
        case .serverError(let message):
            return message.isEmpty ? "The server couldn't complete the request." : message
        case .unknown(let message):
            return message
        }
    }

    /// Maps any error thrown by URLSession / decoding into a `NetworkError`.
    static func map(_ error: Error) -> NetworkError {
        if let networkError = error as? NetworkError {
            return networkError
        }
        if error is DecodingError {
            return .decodingFailed
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed, .internationalRoamingOff:
                return .noInternet
            case .timedOut:
                return .timeout
            case .badURL, .unsupportedURL:
                return .invalidURL
            default:
                return .unknown(urlError.localizedDescription)
            }
        }
        return .unknown(error.localizedDescription)
    }
}
