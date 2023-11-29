//
//  CurrencyConverterViewController.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 28/11/2023.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

protocol CurrencyConverterCalculatorDelegate {
    func openSearch(viewModel: CurrencyConverterViewModel)
}

class CurrencyConverterViewController: UIViewController {
    
    private let currencySelectionFrom: CurrencySelectionView = {
        let view = CurrencySelectionView()
        view.isUserInteractionEnabled = true
        view.layer.cornerRadius = 16
        view.configure(model: ConverterCellUIConfigModel(text: "Sending from", currencyLabelColor: CustomColors.lightBlue, currency: "PLN"))
        return view
    }()
    
    private let currencySelectionTo: CurrencySelectionView = {
        let view = CurrencySelectionView()
        view.isUserInteractionEnabled = true
        view.configure(model: ConverterCellUIConfigModel(text: "Sending to", currencyLabelColor: .black, currency: "EUR"))
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.isUserInteractionEnabled = true
        stackView.backgroundColor = CustomColors.veryLightGrey
        stackView.layer.cornerRadius = 16
        return stackView
    }()
    
    private let contentView = UIView()
    
    private let reverseButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Reverse"), for: .normal)
        button.layer.cornerRadius = 12
        button.backgroundColor = CustomColors.lightBlue
        return button
    }()
    
    var coordinator: CurrencyConverterCalculatorDelegate?
    private let disposedBag = DisposeBag()
    private let viewModel: CurrencyConverterViewModel
    
    init(coordinator: CurrencyConverterCalculatorDelegate, viewModel: CurrencyConverterViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setUI()
        setConstraints()
        setRx()
    }
    
    private func setUI() {
        view.addSubview(contentView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(currencySelectionTo)
        stackView.addArrangedSubview(currencySelectionFrom)
        contentView.addSubview(reverseButton)
    }
    
    private func setConstraints() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(184)
        }
        
        reverseButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
            $0.leading.equalToSuperview().offset(44)
        }
    }
    
    private func setRx(for selectionView: CurrencySelectionView, selection: SelectionSource) {
        selectionView.rx.arrowButtonTapped
            .bind(onNext: { [weak self] in
                guard let viewModel = self?.viewModel else { return }
                self?.coordinator?.openSearch(viewModel: viewModel)
                self?.viewModel.selectionSourceSubject.onNext(selection)
            })
            .disposed(by: disposedBag)
    }
    // wykorzystaj do erroru
    private func updateAppearanceForSelectedView(for selectionView: CurrencySelectionView) {
        selectionView.layer.borderWidth = 2
        selectionView.layer.borderColor = UIColor.black.cgColor
        selectionView.backgroundColor = .white
        
        let otherSelectionView = (selectionView == currencySelectionTo) ? currencySelectionFrom : currencySelectionTo
        otherSelectionView.layer.borderWidth = 0
        otherSelectionView.layer.borderColor = nil
        otherSelectionView.backgroundColor = CustomColors.veryLightGrey
    }
    
    private func setRx() {
        setRx(for: currencySelectionFrom, selection: .from)
        setRx(for: currencySelectionTo, selection: .to)
        
        Observable.combineLatest(viewModel.selectedCountryFrom, viewModel.selectedCountryTo, viewModel.selectionSourceSubject)
            .bind { [weak self] selectedCountryFrom, selectedCountryTo, selectedSubject in
                self?.currencySelectionFrom.currencyLabel.text = selectedCountryFrom
                
                self?.currencySelectionTo.currencyLabel.text = selectedCountryTo
                
            }
            .disposed(by: disposedBag)
        
        reverseButton.rx.tap
            .subscribe {[weak self] _ in
                self?.viewModel.switchSelectedCountries()
            }
            .disposed(by: disposedBag)
        
    }
}
