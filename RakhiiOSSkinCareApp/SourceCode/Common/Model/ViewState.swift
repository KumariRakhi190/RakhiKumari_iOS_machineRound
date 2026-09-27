//
//  ViewState.swift
//  RakhiiOSSkinCareApp
//
//  Created by RakhiKumari on 25/09/26.
//

import Foundation

// UI state published by the view models of screens that call an API.
enum ViewState: Equatable {
    case idle
    case loading
    case loaded
    case empty(String)
    case error(String)
}
