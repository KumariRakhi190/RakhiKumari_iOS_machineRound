//
//  ImageLoader.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 25/09/26.
//

import UIKit

/// Loads remote images with URLSession and keeps them in an in-memory NSCache.
/// Responses are also stored in URLCache, so images survive memory warnings.
class ImageLoader {

    static let shared = ImageLoader()

    private let session: URLSession
    private let cache = NSCache<NSString, UIImage>()

    init(session: URLSession = .shared) {
        self.session = session
        cache.countLimit = 200
    }

    // Completion is always called on the main thread (nil if the image could not be loaded).
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }
        session.dataTask(with: url) { [weak self] data, response, _ in
            var image: UIImage?
            if let data, let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) {
                image = UIImage(data: data)
            }
            DispatchQueue.main.async {
                if let image {
                    self?.cache.setObject(image, forKey: urlString as NSString)
                }
                completion(image)
            }
        }.resume()
    }
}
