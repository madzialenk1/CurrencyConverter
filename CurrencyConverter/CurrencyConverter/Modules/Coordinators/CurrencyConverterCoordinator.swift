//
//  CurrencyConverterCoordinator.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 28/11/2023.
//

import Foundation
import UIKit

class CurrencyConverterCoordinator {
    var navigationController: UINavigationController?
    
    func start() {
        let viewModel = CurrencyConverterViewModel()
        let viewController = CurrencyConverterViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
}
