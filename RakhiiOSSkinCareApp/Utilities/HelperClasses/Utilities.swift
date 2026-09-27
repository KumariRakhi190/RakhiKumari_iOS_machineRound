//
//  Utilities.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 24/09/26.
//

import Foundation

class Utilities {
    
    static func convertToStringDict(_ dict: [String: Any?]) -> [String: String] {
        var newDict = [String: String]()
        for (key, value) in dict {
            if let value {
                newDict[key] = "\(value)"
            }
        }
        return newDict
    }
    
    
}
