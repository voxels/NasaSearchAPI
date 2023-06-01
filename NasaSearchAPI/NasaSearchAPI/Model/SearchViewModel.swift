//
//  SearchViewModel.swift
//  NasaSearchAPI
//
//  Created by Michael A Edgcumbe on 6/1/23.
//

import Foundation

public struct SearchViewModel {
    public var query:String?
    internal let network = Network()
    internal let serverURL:URL = URL(string: "https://images-api.nasa.gov")!
    internal let searchEndpointAddress:String = "search"

}

extension SearchViewModel {
    public func search(for query:String) {
        
    }
}
