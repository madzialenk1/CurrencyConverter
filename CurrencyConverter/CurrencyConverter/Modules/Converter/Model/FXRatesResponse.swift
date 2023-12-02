//
//  FXRatesResponse.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 30/11/2023.
//

import Foundation

struct FxRateResponse: Decodable {
    let from: String
    let to: String
    let rate: Double
    let fromAmount: Double
    let toAmount: Double
}
