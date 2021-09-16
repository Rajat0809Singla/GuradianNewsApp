//
//  String+Extension.swift
//  GuradianNewsApp
//
//  Created by Rajat Singla on 15/09/21.
//

import Foundation

extension String {

    func getDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: self)
        return date
    }
    
    var htmlToAttributedString: NSAttributedString? {
        let htmlCSSString = "<style>" +
            "html *" +
            "{" +
            "font-size: \(12)pt !important;" +
            "color: #\(000000) !important;" +
            //            "font-family: \(family ?? "Helvetica"), Helvetica !important;" +
        "}</style> \(self)"
        guard let data = htmlCSSString.data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    
    func getDateStringForFormat(format: String) -> String {
        guard  let date = getDate() else {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter.string(from: date)
    }

}
