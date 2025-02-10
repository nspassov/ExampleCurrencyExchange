//
//  CurrencyExchangeView.swift
//  ExampleCurrencyExchange
//
//  Created by Nikolay Spassov on 6.02.25.
//

import SwiftUI

struct CurrencyExchangeView: View {
    
    @ObservedObject var viewModel: CurrencyExchangeViewModel = CurrencyExchangeViewModel()
    
    @State private var amount: String = ""
    @State private var sourceCurrency: String = "USD"
    @State private var destinationCurrency: String = "ZAR"
    @State private var convertedAmount: String?
    
    private enum FocusedField {
        case sourceAmount
    }
    
    @FocusState private var focusedField: FocusedField?
    
    init() {
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Currency Exchange")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField(NSDecimalNumber.zero.toString(locale: .current), text: $amount)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: amount, { oldValue, newValue in
                    convert()
                })
                .focused($focusedField, equals: .sourceAmount)
                .task {
                    self.focusedField = .sourceAmount
                }
                .padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("From")
                        .font(.headline)
                    Picker("Source Currency", selection: $sourceCurrency) {
                        ForEach(viewModel.supportedCurrencies.map { $0.code }, id: \.self) { code in
                            if let currency = ISO4217Code(code: code) {
                                Text(currency.description)
                            }
                        }
                    }
                    .onChange(of: sourceCurrency, { oldValue, newValue in
                        convert()
                    })
                    .pickerStyle(MenuPickerStyle())
                }
                .padding()
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("To")
                        .font(.headline)
                    Picker("Destination Currency", selection: $destinationCurrency) {
                        ForEach(viewModel.supportedCurrencies.map { $0.code }, id: \.self) { code in
                            if let currency = ISO4217Code(code: code) {
                                Text(currency.description)
                            }
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .onChange(of: destinationCurrency, { oldValue, newValue in
                        convert()
                    })
                }
                .padding()
            }
            
            Text(viewModel.destinationAmount?.toString() ?? "0")
                .font(.title3)
                .padding()
            
            Spacer()
        }
        .padding()
    }
    
    func convert() {
        Task {
            await viewModel.convert(sourceAmount: amount,
                                    sourceCurrency: sourceCurrency,
                                    destinationCurrency: destinationCurrency)
        }
    }
}

#Preview {
    CurrencyExchangeView()
}
