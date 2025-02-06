//
//  CurrencyExchangeView.swift
//  ExampleCurrencyExchange
//
//  Created by Nikolay Spassov on 6.02.25.
//

import SwiftUI

struct CurrencyExchangeView: View {
    
    @ObservedObject var viewModel: CurrencyExchangeViewModel = CurrencyExchangeViewModel()
    
    private let currencies = ISO4217Code.allCases.map { $0.code }
    @State private var amount: String = ""
    @State private var sourceCurrency: String = "EUR"
    @State private var destinationCurrency: String = "BGN"
    @State private var convertedAmount: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Currency Exchange")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Enter amount", text: $amount)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("From")
                        .font(.headline)
                    Picker("Source Currency", selection: $sourceCurrency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding()
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("To")
                        .font(.headline)
                    Picker("Destination Currency", selection: $destinationCurrency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding()
            }
            
            Button(action: convert) {
                Text("Convert")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            
            Text("Converted Amount: \(convertedAmount)")
                .font(.title3)
                .padding()
            
            Spacer()
        }
        .padding()
    }
    
    func convert() {
        Task {
            self.convertedAmount = await viewModel.convert(sourceAmount: amount,
                                                           sourceCurrency: sourceCurrency,
                                                           destinationCurrency: destinationCurrency)
        }
    }
}

#Preview {
    CurrencyExchangeView()
}
