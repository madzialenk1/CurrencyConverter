//
//  Constants.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 28/11/2023.
//

import Foundation

struct Constants {
    static let baseURL = "https://my.transfergo.com/api"
    static let countries: [Country] = [
        Country(name: "Ukraine", currency: "UAH", flagIconName: "ukrainian_flag"),
        Country(name: "Great Britain", currency: "GBP", flagIconName: "uk_flag"),
        Country(name: "Germany", currency: "EUR", flagIconName: "german_flag"),
        Country(name: "Poland", currency: "PLN", flagIconName: "polish_flag"),
    ]
    
    static let currencyLimits: [String: Double] = [
        "PLN": 20000.0,
        "EUR": 5000.0,
        "GBP": 1000.0,
        "UAH": 50000.0
    ]
    
    struct Images {
        static let searchIcon = "search"
        static let polishFlag = "polish_flag"
        static let ukrainianFlag = "ukrainian_flag"
        static let ukFlag = "uk_flag"
        static let germanFlag = "german_flag"
        static let reverseIcon = "reverse"
        static let arrowDownIcon = "chevron-down"
        static let alertIcon = "alert-circle"
    }
}
