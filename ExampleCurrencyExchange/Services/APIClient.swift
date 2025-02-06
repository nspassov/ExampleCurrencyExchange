//
//  APIClient.swift
//  ExampleCurrencyExchange
//
//  Created by Nikolay Spassov on 6.02.25.
//

import Foundation
import SPAExtensions

class APIClient {
    let urlSession: URLSession = URLSession.shared
}


extension CommonError: @retroactive Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case error = "error"
        case errorDescription = "error_description"
    }
    
    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        _ = try c.decode(String.self, forKey: .error)
        let errorDescription = try c.decode(String.self, forKey: .errorDescription)
        
        self = .custom(errorDescription)
    }
}
