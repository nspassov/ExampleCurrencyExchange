//
//  CurrencyExchangeView.swift
//  ExampleCurrencyExchange
//
//  Created by Nikolay Spassov on 6.02.25.
//

import SwiftUI
import SPAComponents

struct CurrencyExchangeView: View {
    
    @ObservedObject var viewModel: CurrencyExchangeViewModel
    
    @State private var amount: String = ""
    @State private var sourceCurrency: String = "USD"
    @State private var destinationCurrency: String = "ZAR"
    @State private var readOnlyAmount: String = ""
    
    @FocusState private var focusedField: FocusedField?
    private enum FocusedField {
        case amountField
    }
    
    @State private var swapped: Bool = false {
        didSet {
            self.convert()
        }
    }
    @Namespace private var namespace
    
    init(viewModel: CurrencyExchangeViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Currency Exchange")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            HStack {
                Spacer()
                Text(swapped ? "I need" : "I have")
                    .font(.title2)
                    .padding()
                TextField(viewModel.sourceAmount.toString(locale: .current),
                          text: $amount)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(PlainTextFieldStyle())
                    .multilineTextAlignment(.trailing)
                    .font(.title)
                    .onChange(of: amount, perform: { newValue in
                        convert()
                    })
                    .focused($focusedField, equals: .amountField)
                    .task {
                        self.focusedField = .amountField
                    }
//                    .padding()
                    .matchedGeometryEffect(
                        id: swapped ? "second" : "first",
                        in: namespace,
                        properties: .position,
                        anchor: .trailing,
                        isSource: false
                    )
                    .matchedGeometryEffect(
                        id: "first",
                        in: namespace,
                        properties: .position,
                        anchor: .trailing,
                        isSource: true
                    )
                
                Picker("Source Currency", selection: $sourceCurrency) {
                    ForEach(viewModel.supportedCurrencies
                        .filter { $0.code != destinationCurrency }
                        .map { $0.code },
                            id: \.self) { code in
                        if let currency = ISO4217Code(code: code) {
                            Text(currency.description)
                        }
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .font(.title2)
                .fixedSize(horizontal: true, vertical: false)
                .padding()
                .onChange(of: sourceCurrency, perform: { newValue in
                    convert()
                })
            }
            
            Button {
                withAnimation {
                    swapped.toggle()
                }
            } label: {
                Image(systemName: "arrow.trianglehead.swap")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
            }

            
            HStack {
                Spacer()
                Text(swapped ? "to get" : "I get")
                    .font(.title2)
                    .padding()
                TextField(swapped ? viewModel.sourceAmount.toString(locale: .current) : viewModel.destinationAmount.toString(locale: .current),
                          text: $readOnlyAmount)
                    .textFieldStyle(PlainTextFieldStyle())
                    .multilineTextAlignment(.trailing)
                    .font(.title)
                    .disabled(true)
                    .matchedGeometryEffect(
                        id: swapped ? "first" : "second",
                        in: namespace,
                        properties: .position,
                        anchor: .trailing,
                        isSource: false
                    )
                    .matchedGeometryEffect(
                        id: "second",
                        in: namespace,
                        properties: .position,
                        anchor: .trailing,
                        isSource: true
                    )
                
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
                .fixedSize(horizontal: true, vertical: false)
                .padding()
                .onChange(of: destinationCurrency, perform: { newValue in
                    convert()
                })
            }
            
            Spacer()
        }
        .fixedSize(horizontal: true, vertical: false)
        .overlay {
            ProgressIndicatorViewSUI(shouldShow: $viewModel.isLoading)
                .opacity(viewModel.isLoading ? 1 : 0)
        }
    }
    
    func convert() {
        Task {
            if !swapped {
                await viewModel.convert(sourceAmount: amount,
                                        sourceCurrency: sourceCurrency,
                                        destinationCurrency: destinationCurrency)
            }
            else {
                await viewModel.convert(destinationAmount: amount,
                                        sourceCurrency: sourceCurrency,
                                        destinationCurrency: destinationCurrency)
            }
        }
    }
}

#Preview {
    CurrencyExchangeView(viewModel: CurrencyExchangeViewModel())
}
