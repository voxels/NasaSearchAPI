//
//  Network.swift
//  NasaSearchAPI
//
//  Created by Michael A Edgcumbe on 6/1/23.
//

import Foundation

public enum NetworkError : Error {
    case ServerAddressError
    case ServerAddressComponentsError
    case NetworkSessionError
    case ServerRequestError
    case JSONArrayResponseError
    case UnexpectedResponseError
    
}

public class Network {
    
    internal var session:URLSession?
    
    public func fetch(endpoint:String, from server:URL, with queryItems:[URLQueryItem]? = nil) async throws -> [String:Any] {
        guard var components = URLComponents(url: server, resolvingAgainstBaseURL: false) else {
            throw NetworkError.ServerAddressError
        }
        
        components.path = endpoint
        components.queryItems = queryItems
        
        if session == nil {
            let configuration = URLSessionConfiguration.default
            session = URLSession(configuration: configuration)
        }
        
        guard let session = session else {
            throw NetworkError.NetworkSessionError
        }
        
        guard let url = components.url else {
            throw NetworkError.ServerAddressComponentsError
        }
        
        let request = URLRequest(url: url)
        let response = try await session.data(for: request)
        
        let data = response.0
        
        let json = try JSONSerialization.jsonObject(with: data)
        
        if let json = json as? [String:Any] {
            return json
        } else if let json = json as? [[String:Any]] {
            throw NetworkError.JSONArrayResponseError
        } else {
            throw NetworkError.UnexpectedResponseError
        }
    }
}
