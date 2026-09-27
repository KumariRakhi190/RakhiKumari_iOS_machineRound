//
//  APIEndpoints.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 24/09/26.
//

import Foundation

/// Single place that knows the base URL, paths and query items of every API.
/// Screens never build URL strings themselves.
enum APIEndpoint: Equatable {

    case getCategory(applicationId: String)
    case getSubcategory(applicationId: String, categoryId: String)

    private static let scheme = "https"
    private static let host = "mobilehubs.website"
    private static let basePath = "/appmanagement123/api"

    var path: String {
        switch self {
        case .getCategory:
            return "\(Self.basePath)/getcategory"
        case .getSubcategory:
            return "\(Self.basePath)/getsubcategory"
        }
    }

    var method: MethodType {
        return .get
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .getCategory(let applicationId):
            return [URLQueryItem(name: "applicationid", value: applicationId)]
        case .getSubcategory(let applicationId, let categoryId):
            return [
                URLQueryItem(name: "applicationid", value: applicationId),
                URLQueryItem(name: "categoryid", value: categoryId)
            ]
        }
    }

    var url: URL? {
        var components = URLComponents()
        components.scheme = Self.scheme
        components.host = Self.host
        components.path = path
        components.queryItems = queryItems
        return components.url
    }
}
