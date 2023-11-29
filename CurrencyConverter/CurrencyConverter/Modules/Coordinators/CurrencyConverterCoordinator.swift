//
//  CurrencyConverterCoordinator.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 28/11/2023.
//

import Foundation
import UIKit
import RxSwift

class CurrencyConverterCoordinator : CurrencyConverterCalculatorDelegate {
    var navigationController: UINavigationController?
    
    func start() {
        let viewModel = CurrencyConverterViewModel()
        let viewController = CurrencyConverterViewController(coordinator: self as CurrencyConverterCalculatorDelegate, viewModel: viewModel)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func openSearch(viewModel: CurrencyConverterViewModel) {
        let vc = SearchViewController(viewModel: viewModel)
        vc.modalPresentationStyle = .pageSheet
        navigationController?.topViewController?.present(vc, animated: true)
    }
}
