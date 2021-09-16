//
//  Reachability.swift
//  GuradianNewsApp
//
//  Created by Rajat Singla on 15/09/21.
//

import Foundation
import SystemConfiguration

public enum HTTPMethod: String {
    
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}

public struct Request {
    
    let method: HTTPMethod
    let url: String
    let body: [String: Any]
    
    public init(method: HTTPMethod, url: String, body: [String: Any] = [:]) {
        self.method = method
        self.url = url
        self.body = body
    }
}

final class RequestBuilder {
    
    func buildRequest(_ request: Request) throws -> URLRequest {
        
        guard let url = URL(string: request.url) else {
            throw NetworkError.badUrl
        }

        guard let body = try? JSONSerialization.data(withJSONObject: request.body, options: []) else {
            throw NetworkError.decodingError
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")

        if request.body.count > 0 {
            urlRequest.httpBody = body
        }
        
        return urlRequest
    }
}

public class Reachability {

    public class func isConnectedToNetwork(_ network: Network = Network.all) -> Bool {

        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }

        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }

        // Only Working for WIFI
        if network == .wifi {
            let isReachableWifi = flags == .reachable
            let needsConnectionWifi = flags == .connectionRequired
            
            return isReachableWifi && !needsConnectionWifi
        }

        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)

        return ret

    }
}

public enum Network {
    case wifi
    case cellular
    case all
}
