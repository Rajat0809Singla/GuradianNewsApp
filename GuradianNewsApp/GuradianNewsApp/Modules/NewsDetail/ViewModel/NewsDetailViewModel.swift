//
//  NewsDetailViewModel.swift
//  GuradianNewsApp
//
//  Created by Rajat Singla on 16/09/21.
//

import Foundation

class NewsDetailViewModel: NSObject {
    var newsModel: NewsModel?
    
    func getWebTitile() -> String {
        return newsModel?.webTitle ?? ""
    }

    func getWebUrl() -> String {
        return newsModel?.webUrl ?? ""
    }
    
    func getBody() -> NSAttributedString? {
        return newsModel?.fields?.body?.htmlToAttributedString
    }
    
    func getNewsDate() -> String {
        return newsModel?.webPublicationDate?.getDateStringForFormat(format: "E, d MMM yyyy h:mm:ss a") ?? ""
    }
    
    func getThumbnailUrl() -> String {
        return newsModel?.fields?.thumbnail ?? ""
    }
}
