//
//  FXRatesResponse.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 30/11/2023.
//

import Foundation

struct FxRateResponse: Decodable, Equatable {
    let from: String
    let to: String
    let rate: Double
    let fromAmount: Double
    let toAmount: Double
    
    static func == (lhs: FxRateResponse, rhs: FxRateResponse) -> Bool {
        return lhs.from == rhs.from &&
        lhs.to == rhs.to &&
        lhs.rate == rhs.rate &&
        lhs.fromAmount == rhs.fromAmount &&
        lhs.toAmount == rhs.toAmount
    }
}
