//
//  SearchViewModel.swift
//  NasaSearchAPI
//
//  Created by Michael A Edgcumbe on 6/1/23.
//

import Foundation

public enum SearchViewModelError : Error {
    case DecodingError
}

public protocol SearchViewModelDelegate : AnyObject{
    func modelDidUpdateQuery()
    func modelDidUpdate(with response:NASASearchResponse)
}

final class SearchViewModel {
    public var currentQuery:String = ""
    public static let lastQueryDefaultsKey = "com.noisederived.nasasearchapi.lastQuery"
    public weak var delegate:SearchViewModelDelegate?
    public var allCollections:[NASASearchCollection] = [NASASearchCollection]()
    internal let network = Network()
    internal let serverURL:URL = URL(string: "https://images-api.nasa.gov")!
    internal let searchEndpointAddress:String = "search"
    internal var lastPage:Int = 1
    
    static let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    public init(currentQuery: String = "", delegate: SearchViewModelDelegate? = nil, allCollections: [NASASearchCollection] = [NASASearchCollection]()) {
        self.currentQuery = currentQuery
        self.delegate = delegate
        self.allCollections = allCollections
    }
}

extension SearchViewModel {
    public func search(for query:String, page:Int = 1) async throws {
        if query != currentQuery {
            lastPage = 1
            allCollections.removeAll()
            currentQuery = query
            let defaults = UserDefaults.standard
            defaults.set(query, forKey: SearchViewModel.lastQueryDefaultsKey)
            defaults.synchronize()
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.modelDidUpdateQuery()
            }
        }
        let queryItem = URLQueryItem(name: "q", value: query)
        let pageQueryItem = URLQueryItem(name: "page", value: "\(page)")
        let mediaQueryItem = URLQueryItem(name:"media_type", value: "image")
        let rawResponse = try await network.fetch(endpoint: searchEndpointAddress, from: serverURL, with:[queryItem,pageQueryItem, mediaQueryItem])
        let decodedResponse = try decode(responseData: rawResponse)
        
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.modelDidUpdate(with: decodedResponse)
        }
    }
    
    public func add(collection:NASASearchCollection) {
        let pageLinks = allCollections.compactMap { collection in
            return collection.href
        }
        
        if !pageLinks.contains(collection.href) {
            allCollections.append(collection)
            allCollections = allCollections.sorted(by: { firstCollection, checkCollection in
                return firstCollection.href < checkCollection.href
            })
            
            if let lastCollection = allCollections.last, let url = URL(string: lastCollection.href) {
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
                let queryItems = components?.queryItems
                if let queryItems = queryItems {
                    for item in queryItems {
                        if item.name == "page", let page = item.value, let pageInt = Int(page) {
                            lastPage = min(pageInt, 100)
                        }
                    }
                }
            }
        }
    }
}

extension SearchViewModel {
    private func decode(responseData:Data) throws -> NASASearchResponse {
        return try SearchViewModel.jsonDecoder.decode(NASASearchResponse.self, from: responseData)
    }
}
