//
//  NewsListDataModel.swift
//  GuradianNewsApp
//
//  Created by Rajat Singla on 15/09/21.
//

import Foundation

class NewsListViewModel: NSObject {
    private let dataProvider = NewsDataProvider()
    private var currentRootResponse: NewsListResponseModel?
    var currentPage = 0
    
    // MARK: fetch city data from API or from Core Data if no internet
    public func fetchNewsData(refresh: Bool = false, completion: @escaping (NetworkError?) -> Void) {
        if refresh {
            currentPage = 0
            self.currentRootResponse = nil
        }
        dataProvider.getNewsData((currentPage + 1)) { [weak self] (response , error)  in
            guard let self = self else { return }
            if let data = response {
                if self.currentRootResponse == nil {
                    self.currentRootResponse = data
                } else {
                    self.currentRootResponse?.response.results?.append(contentsOf: data.response.results!)
                }
                
                completion(nil)
            } else {
                completion(error)
            }
          }
    }
    
    // MARK: Helper Methods
    func getNumberOfCells() -> Int {
        return currentRootResponse?.response.results?.count ?? 0
    }
    
    func getDataForCell(index: Int) -> NewsModel? {
       return currentRootResponse?.response.results?[index]
    }
    
    func fetchNextPage(completion: @escaping (NetworkError?) -> Void) {
        currentPage += 1
        fetchNewsData(completion: completion)
    }
    
    func isAllNewsAreLoaded() -> Bool {
        return (currentRootResponse?.response.total ?? 0 > currentRootResponse?.response.results?.count ?? 0)
    }
}
