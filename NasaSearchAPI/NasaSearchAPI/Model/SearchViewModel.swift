//
//  SearchViewModel.swift
//  NasaSearchAPI
//
//  Created by Michael A Edgcumbe on 6/1/23.
//

import Foundation

public protocol SearchViewModelDelegate : AnyObject{
    func modelDidUpdate(with response:[String:Any])
}

public class SearchViewModel {
    public var currentQuery:String?
    public weak var delegate:SearchViewModelDelegate?
    internal let network = Network()
    internal let serverURL:URL = URL(string: "https://images-api.nasa.gov")!
    internal let searchEndpointAddress:String = "search"
}

extension SearchViewModel {
    public func search(for query:String, page:Int = 1) async throws {
        currentQuery = query
        let queryItem = URLQueryItem(name: "q", value: query)
        let pageQueryItem = URLQueryItem(name: "page", value: "\(page)")
        let rawResponse = try await network.fetch(endpoint: searchEndpointAddress, from: serverURL, with:[queryItem,pageQueryItem])
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.modelDidUpdate(with: rawResponse)
        }
    }
}
