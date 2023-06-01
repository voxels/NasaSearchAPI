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
    internal let debug:Bool = false
    
    public func fetch(endpoint:String, from server:URL, with queryItems:[URLQueryItem]? = nil) async throws -> Data {
        guard var components = URLComponents(url: server, resolvingAgainstBaseURL: false) else {
            throw NetworkError.ServerAddressError
        }
        
        components.path = "/\(endpoint)"
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
        
        if debug {
            print(json)
        }
        
        if let _ = json as? [String:Any] {
            return data
        } else if let _ = json as? [[String:Any]] {
            print("Error for response \(response.1)")
            throw NetworkError.JSONArrayResponseError
        } else {
            print("Error for response \(response.1)")
            throw NetworkError.UnexpectedResponseError
        }
    }
}
