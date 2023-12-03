//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 02/12/2023.
//

import Foundation

enum Currency: String {
    case EUR
    case PLN
    case UAH
    case GBP
    
    var fullName: String {
        switch self {
        case .EUR:
            return "Euro"
        case .PLN:
            return "Polish Zloty"
        case .UAH:
            return "Ukrainian Hryvnia"
        case .GBP:
            return "British Pound"
        }
    }
}
