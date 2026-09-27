//
//  OfflineCache.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 27/09/26.
//

import Foundation

/// Saves the last loaded API data as JSON files in the Caches folder,
/// so the lists can still be shown when there is no internet.
class OfflineCache {

    static let shared = OfflineCache()

    private let directory: URL

    init(directory: URL? = nil) {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
        self.directory = directory ?? cachesDirectory.appendingPathComponent("OfflineCache")
        try? FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)
    }

    func save<T: Encodable>(_ value: T, forKey key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        try? data.write(to: fileURL(forKey: key), options: .atomic)
    }

    func load<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = try? Data(contentsOf: fileURL(forKey: key)) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    private func fileURL(forKey key: String) -> URL {
        return directory.appendingPathComponent("\(key).json")
    }
}
