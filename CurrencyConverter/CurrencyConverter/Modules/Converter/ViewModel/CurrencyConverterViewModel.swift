//
//  CurrencyConverterViewModel.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 28/11/2023.
//

import Foundation
import RxSwift
import RxCocoa
import RxReachability
import Reachability

class CurrencyConverterViewModel {    
    let filteredCountries = BehaviorSubject<[Country]>(value: [])
    
    let selectedCurrencyFrom = BehaviorRelay<Country>(value: Country(name: "Poland", currency: Currency.PLN, flagIconName: Constants.Images.polishFlag))
    let selectedCurrencyTo = BehaviorRelay<Country>(value: Country(name: "Ukraine", currency: Currency.UAH, flagIconName: Constants.Images.ukrainianFlag))
    let currencyConverterFrom = BehaviorRelay<Double>(value: 300)
    let currencyConverterTo = BehaviorRelay<Double>(value: 1)
    let selectionSource = BehaviorRelay<SelectionSource>(value: .from)
    let fxRatesConversionResult = BehaviorRelay<FxRateResponse?>(value: nil)
    
    private let networkService: NetworkService
    private let disposeBag = DisposeBag()
    
    init(networkService: NetworkService) {
        self.networkService = networkService
        getRateValues()
    }
    
    func filterCountries(by searchText: String) {
        if searchText.isEmpty {
            filteredCountries.onNext(Constants.countries)
        } else {
            let filtered = Constants.countries.filter { country in
                return country.name.lowercased().contains(searchText.lowercased())
            }
            filteredCountries.onNext(filtered)
        }
    }
    
    func switchSelectedCountries() {
        let tempValue = selectedCurrencyFrom.value
        selectedCurrencyFrom.accept(selectedCurrencyTo.value)
        selectedCurrencyTo.accept(tempValue)
    }
    
    private func checkInternetConnection() {
        ReachabilityManager.shared.isInternetAvailable
            .subscribe(onNext: { isAvailable in
                if !isAvailable {
                    print("no internet")
                }
            })
            .disposed(by: disposeBag)
    }
    
    
    func getRateValues() {
        checkInternetConnection()
        let selection = selectionSource.value
        let parameters: [String: Any] = [
            "from": selection == .to ? selectedCurrencyTo.value.currency : selectedCurrencyFrom.value.currency,
            "to": selection == .to ? selectedCurrencyFrom.value.currency : selectedCurrencyTo.value.currency,
            "amount": selection == .from ? currencyConverterFrom.value : currencyConverterTo.value
        ]
        
        networkService.requestData(from: .rates, parameters: parameters)
            .flatMap { data -> Observable<FxRateResponse> in
                do {
                    let decoder = JSONDecoder()
                    let fxRateResponse = try decoder.decode(FxRateResponse.self, from: data)
                    return Observable.just(fxRateResponse)
                } catch {
                    return Observable.error(error)
                }
            }
            .subscribe(onNext: {[weak self] fxRateResponse in
                self?.fxRatesConversionResult.accept(fxRateResponse)
            }, onError: { error in
                print("Error: \(error)")
            })
            .disposed(by: disposeBag)
    }
}

enum SelectionSource {
    case from, to
}
