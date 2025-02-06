//
//  ISO4217Code.swift
//  ExampleCurrencyExchange
//
//  Created by Nikolay Spassov on 6.02.25.
//

import Foundation
import SPAExtensions

enum ISO4217Code: String, CustomStringConvertible, CaseIterable {
    case usd
    case eur
    case bgn
    case pln
    case sek
    
    var description: String {
        return country ++ code
    }
    
    var code: String {
        return self.rawValue.uppercased()
    }
    
    init?(code: String) {
        self.init(rawValue: code.lowercased())
    }
    
    var country: String {
        switch self {
        case .usd:
            return "🇺🇸"
        case .eur:
            return "🇪🇺"
        case .bgn:
            return "🇧🇬"
        case .pln:
            return "🇵🇱"
        case .sek:
            return "🇸🇪"
        }
    }
}
