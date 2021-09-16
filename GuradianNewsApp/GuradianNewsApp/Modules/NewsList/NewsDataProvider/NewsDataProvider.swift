//
//  NewsDataProvider.swift
//  GuradianNewsApp
//
//  Created by Rajat Singla on 15/09/21.
//

import Foundation
import CoreData

enum CoreDataOperationStatus {
    case success
    case failure
    case noResult
    case noAction
}

class NewsDataProvider: NSObject {
    private let newsDataEntity = "NewsList"
    
    // MARKS :- get news info from API and if no internet then fetch from Core Data
    func getNewsData(_ page: Int, completion: @escaping (NewsListResponseModel?, NetworkError?) -> Void) {
        fetchNewsDataOnlineFor(page) { [weak self] (result, data) in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let finalData):
                if finalData.response.status == "ok" {
                    self.updateDefaultNewsDataOfflineFor(page: page, finalData) { (isSuccess) in
                        print("entry save to core data")
                    }
                }
                DispatchQueue.main.async {
                    completion(finalData, nil)
                }

            case .failure(let error):
                switch error {
                case .noInternetError:
                    self.fetchNewsDataOfflineFor(page) { (status, data) in
                        switch status {
                        case .failure, .noAction, .noResult:
                            DispatchQueue.main.async {
                                completion(nil, .noInternetError)
                            }
                        case .success:
                            DispatchQueue.main.async {
                                completion(data, .noInternetError)
                            }
                        }
                    }
                default:
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    print("API Failure")
                }
            }
        }
    }
    
    // MARKS : - get news list from Network Layer
    private func fetchNewsDataOnlineFor(_ page: Int, completion: @escaping (Result<NewsListResponseModel, NetworkError>, Data?) -> Void) {
        let networkManager = NetworkManager()
        guard let newsListUrl = URL(string: "https://content.guardianapis.com/search?q=Afganistan&api-key=e583cc09-cd6b-4beb-9c1b-32f80020c622&order-by=newest&show-fields=thumbnail,body&page=\(page)") else {
            return
        }
        print("API URL: \(newsListUrl.absoluteString)")

        var urlRequest = URLRequest(url: newsListUrl)
        urlRequest.httpMethod = HTTPMethod.get.rawValue
        networkManager.loadRequest(request: urlRequest, completion: completion)
    }
    
    // MARKS : - Get news list from Core Data
    private func fetchNewsDataOfflineFor(_ page: Int, completion: @escaping (CoreDataOperationStatus, NewsListResponseModel?) -> Void) {
        let coreDataManager = CoreDataManager()
        coreDataManager.managedObjectMainQueueContext.perform {
            let request: NSFetchRequest<NewsList> = NSFetchRequest(entityName: self.newsDataEntity)
            do {
                let dataResult = try coreDataManager.managedObjectMainQueueContext.fetch(request)
                let response = NewsListModel(startIndex: 0, pageSize: dataResult.count, currentPage: page, results: self.getNewsListFromCoreData(newsList: dataResult), status: "Fail")
                let responseModel = NewsListResponseModel(response: response)
                completion(.success, responseModel)
            } catch {
                completion(.failure, nil)
            }
        }
    }
    
    private func getNewsListFromCoreData(newsList: [NewsList]) -> [NewsModel] {
        var currentNews = [NewsModel]()
        let decoder = JSONDecoder()
        for news in newsList {
            var fetchedNews = NewsModel()
            fetchedNews.webUrl = news.webUrl
            fetchedNews.webPublicationDate = news.webPublicationDate?.toString()
            fetchedNews.webTitle = news.webTitle
            fetchedNews.fields = try? decoder.decode(NewsFields.self, from: news.fields!)
            currentNews.append(fetchedNews)
        }
        return currentNews
    }
    
    // MARKS : - Upadte/ insert existing news data
    private func updateDefaultNewsDataOfflineFor(page: Int, _ data: NewsListResponseModel?, completion: @escaping (CoreDataOperationStatus) -> Void) {
        let coreDataManager = CoreDataManager()
        coreDataManager.managedObjectPrivateQueueContext.perform {
            let request: NSFetchRequest<NewsList> = NSFetchRequest(entityName: self.newsDataEntity)
            let predicate = NSPredicate(format: "page == %i", page)
            request.predicate = predicate
            var existingNews: [NewsList]?
            do {
                existingNews = try coreDataManager.managedObjectPrivateQueueContext.fetch(request)
            } catch {
                completion(.noResult)
                print("default news fetch error")
                return
            }
            let encoder = JSONEncoder()
            if existingNews == nil || existingNews?.count == 0 {
                guard let newsList = data?.response.results else {
                    completion(.noResult)
                    return
                }
                for news in newsList {
                    let entity = NSEntityDescription.insertNewObject(forEntityName: self.newsDataEntity, into: coreDataManager.managedObjectPrivateQueueContext) as? NewsList
                    entity?.webTitle = news.webTitle
                    entity?.webUrl = news.webUrl
                    entity?.webPublicationDate = news.webPublicationDate?.getDate()
                    let fieldsData = try? encoder.encode(news.fields)
                    entity?.fields = fieldsData
                    entity?.page = Int32(page)
                }
                completion(.success)
            } else {
                for (index, oldNews) in existingNews!.enumerated() {
                    let updatedNews = data?.response.results?[index]
                    oldNews.webTitle = updatedNews?.webTitle
                    oldNews.webUrl = updatedNews?.webUrl
                    oldNews.webPublicationDate = updatedNews?.webPublicationDate?.getDate()
                    let fieldsData = try? encoder.encode(updatedNews?.fields)
                    oldNews.fields = fieldsData
                    oldNews.page = Int32(page)
                }
                completion(.success)
            }
            print("entry save to core data executed")
            coreDataManager.saveContext()
        }
    }
    
}
