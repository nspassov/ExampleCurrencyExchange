//
//  ISO4217Code.swift
//  ExampleCurrencyExchange
//
//  Created by Nikolay Spassov on 6.02.25.
//

import Foundation

enum ISO4217Code: String, CustomStringConvertible, CaseIterable {
    case usd
    case eur
    case bgn
    case pln
    case sek
    case `try`
    case rub
    case ars
    case zar
    case zwl
    case aud
    case jpy
    
    var description: String {
        return code
    }
    
    var code: String {
        return self.rawValue.uppercased()
    }
    
    init?(code: String) {
        self.init(rawValue: code.lowercased())
    }
    
    static let flags: [String] = [ "🇺🇸", "🇪🇺", "🇧🇬", "🇵🇱", "🇸🇪", "🇹🇷", "🇷🇺", "🇦🇷", "🇿🇦", "🇿🇼", "🇦🇺", "🇯🇵" ]
}
