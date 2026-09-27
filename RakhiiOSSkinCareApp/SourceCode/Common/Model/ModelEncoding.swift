//
//  ModelEncoding.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 27/09/26.
//

import Foundation

// The API models are only Decodable. These extensions let us save them on the device
// (offline cache and favourites) using the same JSON keys as the API.

extension LocalizedContent: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(languageName, forKey: .languageName)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
    }
}

extension CareCategory: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(applicationId, forKey: .applicationId)
        try container.encodeIfPresent(categoryName, forKey: .categoryName)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(audioFile, forKey: .audioFile)
        try container.encodeIfPresent(languages, forKey: .languages)
    }
}

extension CareSubcategory: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(applicationId, forKey: .applicationId)
        try container.encodeIfPresent(categoryId, forKey: .categoryId)
        try container.encodeIfPresent(subcategoryName, forKey: .subcategoryName)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(languages, forKey: .languages)
    }
}
