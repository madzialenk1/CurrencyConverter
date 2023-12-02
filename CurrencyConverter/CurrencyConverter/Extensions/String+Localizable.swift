//
//  String+Localizable.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 02/12/2023.
//

import Foundation

extension String {
    func localized() -> String {
        return NSLocalizedString( self,tableName: "Localizable", bundle: .main, value: self, comment: self)
    }
}
