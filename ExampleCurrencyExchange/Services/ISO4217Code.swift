//
//  ISO4217Code.swift
//  ExampleCurrencyExchange
//
//  Created by Nikolay Spassov on 6.02.25.
//

import Foundation

enum ISO4217Code: String, CustomStringConvertible, CaseIterable, Comparable {
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
    
    static func < (lhs: ISO4217Code, rhs: ISO4217Code) -> Bool {
        return lhs.code < rhs.code
    }
    
    var description: String {
        return "\(flag)\u{00A0}\(code)"
    }
    
    var code: String {
        return self.rawValue.uppercased()
    }
    
    init?(code: String) {
        self.init(rawValue: code.lowercased())
    }
    
    var flag: String {
        return Self.flags[self] ?? ""
    }
    
    private static let flags = [ Self.usd: "🇺🇸",
                                 Self.eur: "🇪🇺",
                                 Self.bgn: "🇧🇬",
                                 Self.pln: "🇵🇱",
                                 Self.sek: "🇸🇪",
                                 Self.try: "🇹🇷",
                                 Self.rub: "🇷🇺",
                                 Self.ars: "🇦🇷",
                                 Self.zar: "🇿🇦",
                                 Self.zwl: "🇿🇼",
                                 Self.aud: "🇦🇺",
                                 Self.jpy: "🇯🇵" ]
}
