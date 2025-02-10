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
    @State private var destinationAmount: String = ""
    
    @FocusState private var focusedField: FocusedField?
    private enum FocusedField {
        case sourceAmount
    }
    
    init(viewModel: CurrencyExchangeViewModel) {
        self.sourceCurrency = viewModel.sourceCurrency?.code ?? ""
        self.destinationCurrency = viewModel.destinationCurrency?.code ?? ""
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Currency Exchange")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            HStack {
                Spacer()
                TextField(viewModel.sourceAmount.toString(locale: .current), text: $amount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(PlainTextFieldStyle())
                    .multilineTextAlignment(.trailing)
                    .font(.title)
                    .onChange(of: amount, { oldValue, newValue in
                        convert()
                    })
                    .focused($focusedField, equals: .sourceAmount)
                    .task {
                        self.focusedField = .sourceAmount
                    }
                    .padding()
                
                Picker("Source Currency", selection: $sourceCurrency) {
                    ForEach(viewModel.supportedCurrencies
                        .filter { $0 != viewModel.destinationCurrency }
                        .map { $0.code },
                            id: \.self) { code in
                        if let currency = ISO4217Code(code: code) {
                            Text(currency.description)
                        }
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .font(.title2)
                .onChange(of: sourceCurrency, { oldValue, newValue in
                    convert()
                })
            }
            
            HStack {
                Spacer()
                Text(viewModel.destinationAmount?.toString() ?? "")
                    .multilineTextAlignment(.trailing)
                    .font(.title)
                    .padding()
                
                Picker("Destination Currency", selection: $destinationCurrency) {
                    ForEach(viewModel.supportedCurrencies
                        .filter { $0 != viewModel.sourceCurrency }
                        .map { $0.code },
                            id: \.self) { code in
                        if let currency = ISO4217Code(code: code) {
                            Text(currency.description)
                        }
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .font(.title2)
                .onChange(of: destinationCurrency, { oldValue, newValue in
                    convert()
                })
            }
            
            Spacer()
        }
    }
    
    func convert() {
        Task {
            await viewModel.convert(sourceAmount: amount,
                                    sourceCurrency: sourceCurrency,
                                    destinationCurrency: destinationCurrency)
        }
    }
}

//struct AnimatableNumberModifier: AnimatableModifier {
//    var number: NSDecimalNumber
//    
//    nonisolated var animatableData: NSDecimalNumber {
//        get { number }
//        set { number = newValue }
//    }
//    
//    func body(content: Content) -> some View {
//        content
//            .overlay(
//                Text("\(number.toString())")
//            )
//    }
//}
//
//extension View {
//    func animatingOverlay(for number: NSDecimalNumber) -> some View {
//        modifier(AnimatableNumberModifier(number: number))
//    }
//}

#Preview {
    CurrencyExchangeView(viewModel: CurrencyExchangeViewModel())
}
