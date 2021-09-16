//
//  UIImageView+Extension.swift
//  GuradianNewsApp
//
//  Created by Rajat Singla on 15/09/21.
//

import Foundation
import UIKit

public extension UIImageView {

    static var imageQueue: DispatchQueue {
        DispatchQueue(label: "com.Guradian.Imagequeue", qos: .background, attributes: .concurrent)
    }
    
    static func loadImage(from urlString: String?, complition: @escaping (UIImage?) -> Void) {
        let encodedUrlString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        guard let urlString = encodedUrlString,
            let imageURL = URL(string: urlString) else {
                complition(nil)
                return
        }
        
        let cache =  URLCache.shared
        let request = URLRequest(url: imageURL)
        
        imageQueue.sync {
            if let data = cache.cachedResponse(for: request)?.data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    complition(image)
                }
            } else {
                URLSession.shared.dataTask(with: request, completionHandler: { (data, response, _) in
                    if let data = data, let response = response, ((response as? HTTPURLResponse)?.statusCode ?? 500) < 300, let image = UIImage(data: data) {
                        let cachedData = CachedURLResponse(response: response, data: data)
                        cache.storeCachedResponse(cachedData, for: request)
                        DispatchQueue.main.async {
                            complition(image)
                        }
                    } else {
                        complition(nil)
                    }
                }).resume()
            }
        }
    }
}
