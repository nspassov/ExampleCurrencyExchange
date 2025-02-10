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
    
    @Published private(set) var sourceCurrency: ISO4217Code? = .usd
    @Published private(set) var sourceAmount: NSDecimalNumber = .zero
    @Published private(set) var destinationCurrency: ISO4217Code? = .zar
    @Published private(set) var destinationAmount: NSDecimalNumber? = .zero
    @Published private(set) var supportedCurrencies = ISO4217Code.allCases.sorted()
    
    private(set) var error: CommonError? {
        didSet {
            if let error = error, error.description != (oldValue?.description ?? "") {
                self.notify(error)
            }
        }
    }
    
    private var timer: AnyCancellable?
    
    func convert(sourceAmount: String,
                 sourceCurrency: String,
                 destinationCurrency: String) async {
        
        self.timer = nil
        
        guard let sourceAmount = NSDecimalNumber.from(string: sourceAmount, locale: .current) else {
            self.error = CommonError.custom("Invalid amount")
            return
        }
        self.sourceAmount = sourceAmount
        
        self.sourceCurrency = ISO4217Code(code: sourceCurrency)
        guard let sourceCurrency = self.sourceCurrency else {
            self.error = CommonError.custom("Invalid source currency")
            return
        }
        
        self.destinationCurrency = ISO4217Code(code: destinationCurrency)
        guard let destinationCurrency = self.destinationCurrency else {
            self.error = CommonError.custom("Invalid destination currency")
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
                self.error = CommonError.server(.apiResponse)
            }
        case .failure(let error):
            self.error = error
        }
    }
    
    private func convert() async {
        guard let sourceCurrency = sourceCurrency?.code,
              let destinationCurrency = destinationCurrency?.code else {
            debugLog("Missing parameters")
            return
        }
        await self.convert(sourceAmount: sourceAmount.toString(locale: .current),
                           sourceCurrency: sourceCurrency,
                           destinationCurrency: destinationCurrency)
    }
}
