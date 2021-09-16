//
//  NewsListResponseModel.swift
//  GuradianNewsApp
//
//  Created by Rajat Singla on 15/09/21.
//

import Foundation

struct NewsListResponseModel: Codable {
    var response: NewsListModel
}

struct NewsListModel: Codable {
    var total, startIndex, pageSize, currentPage, pages: Int?
    var results: [NewsModel]?
    var status: String?
    
}

struct NewsModel: Codable {
    var webPublicationDate, webTitle, webUrl, apiUrl: String?
    var fields: NewsFields?
}


struct  NewsFields: Codable {
    var thumbnail, body: String?
}
