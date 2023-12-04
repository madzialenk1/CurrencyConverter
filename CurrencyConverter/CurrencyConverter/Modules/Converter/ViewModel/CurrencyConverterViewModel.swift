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
    let amountString = BehaviorRelay<String>(value: "")
    let fxRatesConversionResult = BehaviorRelay<FxRateResponse?>(value: nil)
    let validAmount = BehaviorRelay<Bool?>(value: nil)
    let errorMessage = BehaviorRelay<String?>(value: nil)
    let resetValues = PublishSubject<Void>()
    let currencyConverterLabel = BehaviorRelay<String>(value: "")
    let isInternetAvailable = BehaviorRelay<Bool?>(value: nil)
    
    private let networkService: NetworkServiceProtocol
    private let disposeBag = DisposeBag()
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
        getRateValues()
        checkInternetConnection()
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
            .subscribe(onNext: { [weak self] isAvailable in
                self?.isInternetAvailable.accept(isAvailable)
                if isAvailable == false {
                    self?.errorMessage.accept("no_internet_connection_error".localized())
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
        
        networkService.requestObject(from: .rates, parameters: parameters, responseType: FxRateResponse.self)
            .subscribe(onSuccess: {[weak self] fxRateResponse in
                self?.fxRatesConversionResult.accept(fxRateResponse)
            }, onFailure: { error in
                print("Error: \(error)")
            })
            .disposed(by: disposeBag)
    }
    
    func handleAmountInput(_ value: String, selection: SelectionSource) {
        if !value.isEmpty {
            updateAmountLabel(value)
            updateViewModelValues(value, selection: selection)
            handleAmountValidation(currencyConverterFrom.value)
        } else {
            currencyConverterTo.accept(0)
            currencyConverterFrom.accept(0)
            resetValues.onNext(())
        }
    }
    
    func updateAmountLabels(with response: FxRateResponse) {
        let condition = selectionSource.value == .from ? response.fromAmount : response.toAmount
        if condition >= Constants.currencyLimits[selectedCurrencyFrom.value.currency.rawValue] ?? 28000.0 {
            handleInvalidAmount(Constants.currencyLimits[selectedCurrencyFrom.value.currency.rawValue] ?? 0.0)
        }
    }
    
    private func updateViewModelValues(_ value: String, selection: SelectionSource) {
        if selection == .from {
            currencyConverterFrom.accept(Double(value) ?? 0.0)
        } else {
            currencyConverterTo.accept(Double(value) ?? 0.0)
        }
    }
    
    private func handleValidAmount() {
        getRateValues()
        validAmount.accept(true)
    }
    
    private func updateAmountLabel(_ value: String) {
        amountString.accept(value)
    }
    
    private func handleAmountValidation(_ value: Double) {
        let selectedCurrency = selectedCurrencyFrom.value.currency.rawValue
        if value <= Constants.currencyLimits[selectedCurrency] ?? 28000.0 {
            handleValidAmount()
        } else {
            handleInvalidAmount(Constants.currencyLimits[selectedCurrency] ?? 28000.0)
        }
    }
    
    private func handleInvalidAmount(_ doubleValue: Double) {
        validAmount.accept(false)
        errorMessage.accept(String(format: "max_amount_sending_error_message".localized(), Int(doubleValue), selectedCurrencyFrom.value.currency.rawValue))
    }
    
    func updateConverterLabel(with response: FxRateResponse) {
        let selection = selectionSource.value
        let formattedResult = String(format: "%.5f", selection == .from ? response.rate : 1/response.rate)
        let fromCurrency = selectedCurrencyFrom.value.currency
        let toCurrency = selectedCurrencyTo.value.currency
        currencyConverterLabel.accept("1 \(fromCurrency) ~ \(formattedResult) \(toCurrency)")
    }
}

enum SelectionSource {
    case from, to
}
