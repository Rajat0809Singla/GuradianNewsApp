//
//  GenericError.swift
//  GuradianNewsApp
//
//  Created by Rajat Singla on 15/09/21.
//

import Foundation

public enum GenericError: Error {
    case noInternetError
    case domainError
    case decodingError
    case badUrl
    case business
    case dataFailure
    case badResponse(code: Int?, description: String?)
    case badAllErrorResponse(code: Int?, description: String?, errorCode: String?, errorMessage: String?, errorReason: String?)
}

enum StoryBoardName: String {
    case main = "Main"
}

enum ControllerID: String {
    case favroiteListViewController = "FavroiteListViewController"
}
