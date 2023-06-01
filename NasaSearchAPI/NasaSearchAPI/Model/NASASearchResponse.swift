//
//  NASASearchResponse.swift
//  NasaSearchAPI
//
//  Created by Michael A Edgcumbe on 6/1/23.
//

import Foundation

public struct NASASearchResponse : Decodable, Hashable {
    let collection:NASASearchCollection
}

public struct NASASearchCollection : Decodable, Hashable {
    let href:String
    let items:[NASASearchCollectionItem]
    let links:[NASASearchCollectionLink]
    let metadata:NASASearchCollectionMetadata
    let version:String
}

public struct NASASearchCollectionLink : Decodable, Hashable {
    let href:String
    let prompt:String
    let rel:String
}

public struct NASASearchCollectionMetadata : Decodable, Hashable {
    let totalHits:Int
}

public struct NASASearchCollectionItem : Decodable, Hashable {
    let data:[NASASearchCollectionItemData]
    let href:String
    let links:[NASASearchCollectionItemLink]
}

public struct NASASearchCollectionItemData : Decodable, Hashable {
    let center:String
    let dateCreated:String
    let description:String
    let keywords:[String]
    let mediaType:String
    let nasaId:String
    let title:String
}

public struct NASASearchCollectionItemLink : Decodable, Hashable {
    let href:String
    let rel:String
    let render:String
}
