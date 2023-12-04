//
//  CurrencyConverterTests.swift
//  CurrencyConverterTests
//
//  Created by Magda Pękacka on 28/11/2023.
//

import XCTest
import RxSwift
import RxTest

@testable import CurrencyConverter

class CurrencyConverterViewModelTests: XCTestCase {
    var viewModel: CurrencyConverterViewModel!
    var disposeBag: DisposeBag!
    
    override func setUp() {
        super.setUp()
        disposeBag = DisposeBag()
        viewModel = CurrencyConverterViewModel(networkService: MockNetworkService())
    }
    
    override func tearDown() {
        disposeBag = nil
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    
    func testFilterCountriesWhenSearchTextIsEmpty() {
        let expectedCountries = Constants.countries
        
        var observedCountries: [Country] = []
        _ = viewModel.filteredCountries
            .subscribe(onNext: { countries in
                observedCountries = countries
            })
            .disposed(by: disposeBag)
        
        viewModel.filterCountries(by: "")
        
        XCTAssertEqual(observedCountries, expectedCountries)
    }
    
    func testFilterCountriesWhenSearchTextIsNotEmpty() {
        let searchText = "Pol"
        
        var observedCountries: [Country] = []
        _ = viewModel.filteredCountries
            .subscribe(onNext: { countries in
                observedCountries = countries
            })
            .disposed(by: disposeBag)
        
        viewModel.filterCountries(by: searchText)
        
        XCTAssertEqual(observedCountries.count, 1)
        XCTAssertEqual(observedCountries.first?.name, "Poland")
    }
    
    func testFilterCountriesWhenSearchTextIsNotValid() {
        let searchText = "blabla"
        
        var observedCountries: [Country] = []
        _ = viewModel.filteredCountries
            .subscribe(onNext: { countries in
                observedCountries = countries
            })
            .disposed(by: disposeBag)
        
        viewModel.filterCountries(by: searchText)
        
        XCTAssertEqual(observedCountries.count, 0)
    }
    
    func testSwitchSelectedCountries() {
        let initialSelectedCurrencyFrom = viewModel.selectedCurrencyFrom.value
        let initialSelectedCurrencyTo = viewModel.selectedCurrencyTo.value
        viewModel.switchSelectedCountries()
        
        XCTAssertEqual(viewModel.selectedCurrencyFrom.value, initialSelectedCurrencyTo)
        XCTAssertEqual(viewModel.selectedCurrencyTo.value, initialSelectedCurrencyFrom)
    }
    
    func testSuccessfulRequest() {
        viewModel.getRateValues()
        let expectedResult = FxRateResponse(from: "PLN", to: "UAH", rate: 1.2345, fromAmount: 100.0, toAmount: 123.45)
        
        viewModel.fxRatesConversionResult
            .subscribe { response in
                XCTAssertEqual(response, expectedResult)
            }
            .disposed(by: disposeBag)
    }
}

