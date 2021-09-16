//
//  ObjectMapper.swift
//  GuradianNewsApp
//
//  Created by Rajat Singla on 15/09/21.
//

import Foundation

struct ObjectMapper {
    static func parseJson<T: Codable>(data: Data?, type: T.Type) -> Result<T, GenericError>? {
        if let dataRec = data {
            do {
                let result = try JSONDecoder().decode(T.self, from: dataRec)
                return .success(result)
            } catch {
                return .failure(.decodingError)
            }
        } else {
            return .failure(.dataFailure)
        }
    }
}
