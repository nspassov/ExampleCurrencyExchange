//
//  CurrencyExchangeViewModel.swift
//  ExampleCurrencyExchange
//
//  Created by Nikolay Spassov on 6.02.25.
//

import Foundation
import Combine
import SPAExtensions
import SPAComponents

@MainActor
class CurrencyExchangeViewModel: ObservableObject, EventNotifying {
    
    @Published private(set) var sourceCurrency: ISO4217Code?
    @Published private(set) var sourceAmount: NSDecimalNumber?
    @Published private(set) var destinationCurrency: ISO4217Code?
    @Published private(set) var destinationAmount: NSDecimalNumber?
    @Published private(set) var supportedCurrencies = ISO4217Code.allCases
    
    private var timer: AnyCancellable?
    
    func convert(sourceAmount: String,
                 sourceCurrency: String,
                 destinationCurrency: String) async {
        
        self.timer = nil
        
        self.sourceAmount = NSDecimalNumber.from(string: sourceAmount, locale: .current)
        self.sourceCurrency = ISO4217Code(code: sourceCurrency)
        self.destinationCurrency = ISO4217Code(code: destinationCurrency)
        
        guard let sourceAmount = self.sourceAmount else {
            self.notify(CommonError.custom("Invalid amount \(sourceAmount)"))
            return
        }
        guard let sourceCurrency = self.sourceCurrency else {
            self.notify(CommonError.custom("Invalid source currency"))
            return
        }
        guard let destinationCurrency = self.destinationCurrency else {
            self.notify(CommonError.custom("Invalid destination currency"))
            return
        }
        
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
                
                self.timer = Timer.publish(every: 10, on: .main, in: .common)
                    .autoconnect()
                    .receive(on: DispatchQueue.main)
                    .sink(receiveValue: { [weak self] _ in
                        Task {
                            await self?.convert()
                        }
                    })
            }
            else {
                self.notify(CommonError.server(.apiResponse))
            }
        case .failure(let error):
            self.notify(error)
        }
    }
    
    private func convert() async {
        guard let sourceAmount = sourceAmount?.toString(locale: .current),
              let sourceCurrency = sourceCurrency?.code,
              let destinationCurrency = destinationCurrency?.code else {
            debugLog("Missing parameters")
            return
        }
        await self.convert(sourceAmount: sourceAmount,
                           sourceCurrency: sourceCurrency,
                           destinationCurrency: destinationCurrency)
    }
}
