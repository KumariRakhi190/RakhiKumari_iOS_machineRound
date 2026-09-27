//
//  LocalizedContent.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 25/09/26.
//

import Foundation

struct LocalizedContent: Decodable {
    let languageName: String?
    let name: String?
    let description: String?

    enum CodingKeys: String, CodingKey {
        case languageName = "language_name"
        case name
        case description
    }
}

