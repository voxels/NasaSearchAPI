//
//  SearchViewModel.swift
//  NasaSearchAPI
//
//  Created by Michael A Edgcumbe on 6/1/23.
//

import Foundation

public struct SearchViewModel {
    public var serverURL:URL = URL(string: "https://images-api.nasa.gov")!
    public var searchEndpoint:String = "search"
    public var query:String?
    
}
