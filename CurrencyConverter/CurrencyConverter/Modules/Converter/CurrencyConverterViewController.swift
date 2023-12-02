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
        view.configure(model: ConverterCellUIConfigModel(text: "currency_selection_from_label".localized(), currencyLabelColor: CustomColors.lightBlue, currency: "PLN", flag: "polish_flag"))
        view.backgroundColor = .white
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 2, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let currencySelectionTo: CurrencySelectionView = {
        let view = CurrencySelectionView()
        view.configure(model: ConverterCellUIConfigModel(text: "currency_selection_to_label".localized(), currencyLabelColor: .black, currency: "UAH", flag: "ukrainian_flag"))
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
        button.setImage(UIImage(named: Constants.Images.reverseIcon), for: .normal)
        button.layer.cornerRadius = 12
        button.backgroundColor = CustomColors.lightBlue
        return button
    }()
    
    private let currencyConverterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .black
        label.layer.cornerRadius = 6
        label.font = UIFont.systemFont(ofSize: 10)
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private let errorMessage = ErrorLabel()
    
    private let viewModel: CurrencyConverterViewModel
    private let coordinator: CurrencyConverterCalculatorDelegate?
    private let disposedBag = DisposeBag()
    
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
        addSubviews()
        setConstraints()
        setRx()
    }
    
    private func addSubviews() {
        view.addSubview(contentView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(currencySelectionFrom)
        stackView.addArrangedSubview(currencySelectionTo)
        contentView.addSubview(reverseButton)
        contentView.addSubview(currencyConverterLabel)
        contentView.addSubview(errorMessage)
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
        
        currencyConverterLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.height.equalTo(14)
            $0.width.equalTo(120)
        }
        
        errorMessage.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.bottom).offset(24)
            $0.leading.trailing.equalTo(15)
        }
    }
    
    private func setRx(for selectionView: CurrencySelectionView, selection: SelectionSource) {
        selectionView.rx.arrowButtonTapped
            .bind(onNext: { [weak self] in
                guard let viewModel = self?.viewModel else { return }
                self?.coordinator?.openSearch(viewModel: viewModel)
                self?.viewModel.selectionSource.accept(selection)
            })
            .disposed(by: disposedBag)
        
        selectionView.amountLabel.rx.text
            .orEmpty
            .map { $0 }
            .bind(onNext: { [weak self] value in
                self?.viewModel.selectionSource.accept(selection)
                self?.handleAmountInput(value, selection: selection, selectionView: selectionView)
            })
            .disposed(by: disposedBag)
    }
    
    private func handleAmountInput(_ value: String, selection: SelectionSource, selectionView: CurrencySelectionView) {
        if !value.isEmpty {
            updateAmountLabel(value, selectionView: selectionView)
            updateViewModelValues(value, selection: selection)
            if selection == .to {
                viewModel.getRateValues()
            } else {
                handleAmountValidation(value)
            }
        } else {
            resetAmountLabels()
        }
    }
    
    private func updateAmountLabel(_ value: String, selectionView: CurrencySelectionView) {
        selectionView.amountLabel.text = "\(value)"
    }
    
    private func updateViewModelValues(_ value: String, selection: SelectionSource) {
        if selection == .from {
            self.viewModel.currencyConverterFrom.accept(Double(value) ?? 0.0)
        } else {
            self.viewModel.currencyConverterTo.accept(Double(value) ?? 0.0)
        }
    }
    
    private func handleAmountValidation(_ value: String) {
        let doubleValue = Double(value) ?? 0.0
        if doubleValue <= Constants.currencyLimits[viewModel.selectedCurrencyFrom.value.currency ] ?? 28000.0 {
            handleValidAmount()
        } else {
            handleInvalidAmount(doubleValue)
        }
    }
    
    private func handleValidAmount() {
        errorMessage.isHidden = true
        viewModel.getRateValues()
        currencySelectionFrom.layer.borderWidth = 0
        currencySelectionFrom.amountLabel.textColor = CustomColors.lightBlue
    }
    
    private func handleInvalidAmount(_ doubleValue: Double) {
        currencySelectionFrom.layer.borderWidth = 2
        currencySelectionFrom.layer.borderColor = UIColor.red.cgColor
        currencySelectionFrom.amountLabel.textColor = .red
        errorMessage.isHidden = false
        let errorMessageString = String(format: "max_amount_sending_error_message".localized(), Int(doubleValue), self.viewModel.selectedCurrencyFrom.value.currency)
        errorMessage.configure(text: errorMessageString)
    }
    
    private func resetAmountLabels() {
        currencySelectionTo.amountLabel.text = ""
        currencySelectionFrom.amountLabel.placeholder = "0"
        currencySelectionTo.amountLabel.placeholder = "0"
    }
    
    private func updateAmountLabels(with response: FxRateResponse) {
        if viewModel.selectionSource.value == .from {
            currencySelectionTo.amountLabel.text = String(response.toAmount)
        } else {
            currencySelectionFrom.amountLabel.text = String(response.fromAmount)
        }
    }
    
    private func updateConverterLabel(with response: FxRateResponse) {
        let formattedResult = String(format: "%.5f", response.rate)
        let fromCurrency = viewModel.selectedCurrencyFrom.value.currency
        let toCurrency = viewModel.selectedCurrencyTo.value.currency
        currencyConverterLabel.text = "1 \(fromCurrency) = \(formattedResult)\(toCurrency)"
    }
    
    private func setRx() {
        setRx(for: currencySelectionFrom, selection: .from)
        setRx(for: currencySelectionTo, selection: .to)
        
        Observable.combineLatest(viewModel.selectedCurrencyFrom, viewModel.selectedCurrencyTo)
            .bind { [weak self] selectedCountryFrom, selectedCountryTo in
                self?.currencySelectionTo.configure(model: selectedCountryTo)
                self?.currencySelectionFrom.configure(model: selectedCountryFrom)
                self?.viewModel.getRateValues()
            }
            .disposed(by: disposedBag)
        
        viewModel.fxRatesConversionResult
            .observe(on: MainScheduler.instance)
            .compactMap { $0 }
            .bind { [weak self] result in
                self?.updateAmountLabels(with: result)
                self?.updateConverterLabel(with: result)
            }
            .disposed(by: disposedBag)
        
        reverseButton.rx.tap
            .subscribe {[weak self] _ in
                self?.viewModel.switchSelectedCountries()
            }
            .disposed(by: disposedBag)
        
    }
}
