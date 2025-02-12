//
//  CurrencyExchange.swift
//  ExampleCurrencyExchange
//
//  Created by Nikolay Spassov on 6.02.25.
//

import Foundation
import SPAExtensions

extension APIClient {
    
    enum ExchangeAmount {
        case source(String)
        case destination(String)
    }
    
    func getCurrencyExchange(amount: ExchangeAmount,
                             sourceCurrency: String,
                             destinationCurrency: String) async -> Result<MoneyAmount, CommonError> {
        
        let urlString = {
            switch amount {
            case .source(let a):
                return "http://api.evp.lt/currency/commercial/exchange/\(a)-\(sourceCurrency)/\(destinationCurrency)/latest"
            case .destination(let a):
                return "http://api.evp.lt/currency/commercial/exchange/\(sourceCurrency)/\(a)-\(destinationCurrency)/latest"
            }
        }()
        
        let request = URLRequest(url: URL(string: urlString)!)
        
        let result = await urlSession.perform(request, parseResponse: { data in
            return try JSONDecoder().decode(MoneyAmount.self, from: data)
        }) { errorData in
            return try JSONDecoder().decode(CommonError.self, from: errorData)
        }
        
        switch result {
        case .success(let data):
            return .success(data)
        case .failure(let error):
            return .failure(error)
        }
    }
}

struct MoneyAmount: Decodable, CustomStringConvertible {
    let amount: String
    let currency: String
    
    private enum CodingKeys: String, CodingKey {
        case amount = "amount"
        case currency = "currency"
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        amount = try c.decode(String.self, forKey: .amount)
        currency = try c.decode(String.self, forKey: .currency)
    }
    
    var description: String {
        return amount ++ currency
    }
}
