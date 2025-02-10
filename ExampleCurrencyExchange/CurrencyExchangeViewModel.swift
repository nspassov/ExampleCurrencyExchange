//
//  CurrencyExchangeViewModel.swift
//  ExampleCurrencyExchange
//
//  Created by Nikolay Spassov on 6.02.25.
//

import Foundation
import SPAExtensions
import SPAComponents

@MainActor
class CurrencyExchangeViewModel: ObservableObject, EventNotifying {
    
    @Published private(set) var sourceCurrency: ISO4217Code?
    @Published private(set) var sourceAmount: NSDecimalNumber?
    @Published private(set) var destinationCurrency: ISO4217Code?
    @Published private(set) var destinationAmount: NSDecimalNumber?
    
    func convert(sourceAmount: String,
                 sourceCurrency: String,
                 destinationCurrency: String) async {
        
        guard let sourceAmount = NSDecimalNumber.from(string: sourceAmount),
              let sourceCurrency = ISO4217Code(code: sourceCurrency),
              let destinationCurrency = ISO4217Code(code: destinationCurrency) else {
            self.notify(CommonError.client(.invalidInput))
            return
        }
        
        Task {
            let result = await APIClient().getCurrencyExchange(amount: sourceAmount.toString(locale: .posix),
                                                               sourceCurrency: sourceCurrency.code,
                                                               destinationCurrency: destinationCurrency.code)
            switch result {
            case .success(let value):
                debugLog(value)
                if let amount = NSDecimalNumber.from(string: value.amount, locale: .posix),
                   let currency = ISO4217Code(code: value.currency) {
                    self.destinationAmount = amount
                    self.destinationCurrency = currency
                }
                else {
                    self.notify(CommonError.server(.apiResponse))
                }
            case .failure(let error):
                self.notify(error)
            }
        }
    }
    
    func getCurrencyCodes() -> [String] {
        return ISO4217Code.allCases.map { $0.description }
    }
}
