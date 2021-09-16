//
//  NetworkManager.swift
//  GuradianNewsApp
//
//  Created by Rajat Singla on 15/09/21.
//

import Foundation

public extension Data {
    var dictionary: [String: Any]? {
        return (try? JSONSerialization.jsonObject(with: self, options: .mutableContainers)).flatMap { $0 as? [String: Any] }
    }
}

public extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: [])).flatMap { $0 as? [String: Any] }
    }
}

public enum NetworkError: Error {
    case noInternetError
    case domainError
    case decodingError
    case badUrl
    case business
    case badResponse(code: Int?, description: String?)
    case badAllErrorResponse(code: Int?, description: String?, errorCode: String?, errorMessage: String?, errorReason: String?)
}

public class NetworkManager {
    let urlSession = URLSession(configuration: .ephemeral)
    
    public func loadRequest<T: Codable>(request: URLRequest, completion: @escaping (Result<T, NetworkError>, Data?) -> Void) {

        if !Reachability.isConnectedToNetwork() {
            DispatchQueue.main.async {
                completion(.failure(.noInternetError), nil)
            }
            return
        }
        
        urlSession.dataTask(with: request) { (data, response, error) in
            
            if let error = error as NSError?, error.domain == NSURLErrorDomain {
                DispatchQueue.main.async {
                    completion(.failure(.domainError), nil)
                }
                return
            } else {
                if let response = response, let data = data, !response.isSuccess {
                    do {
                        let result = try JSONDecoder().decode(ErrorResponse.self, from: data)
                        let error = NetworkError.badAllErrorResponse(code: response.httpStatusCode, description: result.message, errorCode: result.errorCode, errorMessage: result.errorMessage, errorReason: result.errorReason)
                        DispatchQueue.main.async {
                            completion(.failure(error), nil)
                        }
                        return
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(.decodingError), nil)
                        }
                        return
                    }
                }
                
                if let data = data {
                    do {
                        let result = try JSONDecoder().decode(T.self, from: data)
                        DispatchQueue.main.async {
                            completion(.success(result), data)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(.failure(.decodingError), nil)
                        }
                    }
                }
            }
        }.resume()
    }
}

extension HTTPURLResponse {

    var isValidResponse: Bool {
        return (200...299).contains(self.statusCode)
    }
}

extension URLResponse {
    
    var isSuccess: Bool {
        return httpStatusCode >= 200 && httpStatusCode < 300
    }

    var httpStatusCode: Int {
        guard let statusCode = (self as? HTTPURLResponse)?.statusCode else {
            return 0
        }
        return statusCode
    }
}

struct ErrorResponse: Codable {
    let status, message, errorCode, errorMessage, errorReason: String?
}
