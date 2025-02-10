//
//  ExampleCurrencyExchangeApp.swift
//  ExampleCurrencyExchange
//
//  Created by Nikolay Spassov on 6.02.25.
//

import SwiftUI

@main
struct ExampleCurrencyExchangeApp: App {
    var body: some Scene {
        WindowGroup {
            CurrencyExchangeView(viewModel: CurrencyExchangeViewModel())
        }
    }
}
