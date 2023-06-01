//
//  ImageDetailViewModel.swift
//  NasaSearchAPI
//
//  Created by Michael A Edgcumbe on 6/1/23.
//

import Foundation

public struct ImageDetailViewModel {
    public var item:NASASearchCollectionItem
    
    public static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}
