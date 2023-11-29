//
//  CurrencyConverterViewModel.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 28/11/2023.
//

import Foundation
import RxSwift
import RxCocoa

class CurrencyConverterViewModel {
    var countries: BehaviorRelay<[Country]> = BehaviorRelay(value: [
        Country(name: "United States", currency: "USD", flagIconName: "us_flag"),
        Country(name: "United Kingdom", currency: "GBP", flagIconName: "uk_flag"),
        Country(name: "France", currency: "EUR", flagIconName: "uk_flag"),
        Country(name: "Poland", currency: "PLN", flagIconName: "uk_flag"),
    ])
    
    private let filteredCountriesSubject = BehaviorSubject<[Country]>(value: [])
    
    var filteredCountries: Observable<[Country]> {
        return filteredCountriesSubject.asObservable()
    }
    
    let selectedCountryFrom = BehaviorRelay<String>(value: "USD")
    let selectedCountryTo = BehaviorRelay<String>(value: "PLN")
    let selectionSourceSubject = BehaviorSubject<SelectionSource>(value: .from)
    
    func filterCountries(by searchText: String) {
        if searchText.isEmpty {
            filteredCountriesSubject.onNext(countries.value)
        } else {
            let filtered = countries.value.filter { country in
                return country.name.lowercased().contains(searchText.lowercased())
            }
            filteredCountriesSubject.onNext(filtered)
        }
    }
    
    func switchSelectedCountries() {
        let tempValue = selectedCountryFrom.value
        selectedCountryFrom.accept(selectedCountryTo.value)
        selectedCountryTo.accept(tempValue)
    }
}

enum SelectionSource {
    case from, to
}
