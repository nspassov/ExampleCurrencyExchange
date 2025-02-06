//
//  CurrencyExchangeViewModel.swift
//  ExampleCurrencyExchange
//
//  Created by Nikolay Spassov on 6.02.25.
//

import SwiftUI

@MainActor
class CurrencyExchangeViewModel: ObservableObject {
    
    var sourceAmount: NSDecimalNumber = 100.25
    var sourceCurrency: ISO4217Code = .eur
    
    var destinationAmount: NSDecimalNumber = 0
    var destinationCurrency: ISO4217Code = .bgn
    
    func convert(sourceAmount: String,
                 sourceCurrency: String,
                 destinationCurrency: String) async -> String {
        
        guard let sourceAmount = NSDecimalNumber.from(string: sourceAmount),
              let sourceCurrency = ISO4217Code(code: sourceCurrency),
              let destinationCurrency = ISO4217Code(code: destinationCurrency) else {
            return "Input Error"
        }
        
        Task {
            let result = await APIClient().getCurrencyExchange(amount: sourceAmount.toString(),
                                                                     sourceCurrency: sourceCurrency.code,
                                                                     destinationCurrency: destinationCurrency.code)
            print(result)
            switch result {
            case .success(let value):
                return value.amount
            case .failure(let error):
                return error.description
            }
        }
        return "Error"
    }
    
    func getCurrencyCodes() -> [String] {
        return ISO4217Code.allCases.map { $0.description }
    }
}
