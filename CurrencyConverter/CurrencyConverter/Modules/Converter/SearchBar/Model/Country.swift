//
//  Country.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 29/11/2023.
//

import Foundation

struct Country: Equatable {
    let name: String
    let currency: Currency
    let flagIconName: String
}

extension Country {
    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.name == rhs.name &&
        lhs.currency == rhs.currency &&
        lhs.flagIconName == rhs.flagIconName
    }
}
