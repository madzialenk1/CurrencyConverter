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

protocol CurrencyConverterCalculatorDelegate: AnyObject {
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
    
    private let blurLayer: CALayer = {
        let layer = CALayer()
        layer.backgroundColor = UIColor.white.cgColor
        layer.opacity = 0.5
        return layer
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
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.layer.masksToBounds = true
        label.textAlignment = .center
        return label
    }()
    
    private let errorMessage = ErrorLabel()
    
    private let viewModel: CurrencyConverterViewModel
    private weak var coordinator: CurrencyConverterCalculatorDelegate?
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
            $0.centerX.equalToSuperview()
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
                self?.viewModel.handleAmountInput(value, selection: selection)
            })
            .disposed(by: disposedBag)
    }
    
    private func resetAmountLabels() {
        currencySelectionTo.amountLabel.text = ""
        currencySelectionFrom.amountLabel.text = ""
        currencySelectionFrom.amountLabel.placeholder = "0"
        currencySelectionTo.amountLabel.placeholder = "0"
    }
    
    private func setRx() {
        setRx(for: currencySelectionTo, selection: .to)
        setRx(for: currencySelectionFrom, selection: .from)
        
        Observable.combineLatest(viewModel.selectedCurrencyFrom, viewModel.selectedCurrencyTo)
            .bind { [weak self] selectedCountryFrom, selectedCountryTo in
                self?.currencySelectionTo.configure(model: selectedCountryTo)
                self?.currencySelectionFrom.configure(model: selectedCountryFrom)
                let selection = self?.viewModel.selectionSource.value
                self?.viewModel.handleAmountInput(selection == .from ? self?.currencySelectionFrom.amountLabel.text ?? "0" : self?.currencySelectionTo.amountLabel.text ?? "0", selection: selection ?? .from)
            }
            .disposed(by: disposedBag)
        
        viewModel.fxRatesConversionResult
            .observe(on: MainScheduler.instance)
            .compactMap { $0 }
            .bind { [weak self] result in
                if self?.viewModel.selectionSource.value == .from {
                    self?.currencySelectionTo.amountLabel.text = String(result.toAmount)
                    
                } else {
                    self?.currencySelectionFrom.amountLabel.text = String(result.toAmount)
                }
                self?.viewModel.updateAmountLabels(with: result)
                self?.viewModel.updateConverterLabel(with: result)
            }
            .disposed(by: disposedBag)
        
        reverseButton.rx.tap
            .subscribe {[weak self] _ in
                self?.viewModel.switchSelectedCountries()
            }
            .disposed(by: disposedBag)
        
        viewModel.validAmount
            .compactMap {$0}
            .bind { [weak self] isValid in
                self?.handleValidAmount(isValid: isValid)
            }
            .disposed(by: disposedBag)
        
        viewModel.errorMessage
            .compactMap {$0}
            .bind {[weak self] message in
                self?.errorMessage.isHidden = false
                self?.errorMessage.configure(text: message)
            }
            .disposed(by: disposedBag)
        
        viewModel.resetValues
            .bind {[weak self] _ in
                self?.resetAmountLabels()
            }
            .disposed(by: disposedBag)
        
        viewModel.currencyConverterLabel
            .bind(to: currencyConverterLabel.rx.text)
            .disposed(by: disposedBag)
        
        Observable.combineLatest(viewModel.amountString, viewModel.selectionSource)
            .bind(onNext: { [weak self] (text, selection) in
                if selection == .from {
                    self?.currencySelectionFrom.amountLabel.text = text
                } else {
                    self?.currencySelectionTo.amountLabel.text = text
                }
            })
            .disposed(by: disposedBag)
        
        // TODO: it detects the internet state weirdly on the simulator - to be fixed
        //        viewModel.isInternetAvailable
        //            .compactMap {$0}
        //            .bind { [weak self] isAvailable in
        //                self?.handleLayer(isAvailable: isAvailable)
        //            }
        //            .disposed(by: disposedBag)
    }
    
    private func handleValidAmount(isValid: Bool) {
        if isValid {
            errorMessage.isHidden = true
            currencySelectionFrom.layer.borderWidth = 0
            currencySelectionFrom.amountLabel.textColor = CustomColors.lightBlue
        } else {
            currencySelectionFrom.layer.borderWidth = 2
            currencySelectionFrom.layer.borderColor = CustomColors.customRed.cgColor
            currencySelectionFrom.amountLabel.textColor = CustomColors.customRed
            errorMessage.isHidden = false
        }
    }
    
    private func handleLayer(isAvailable: Bool) {
        if !isAvailable {
            view.layer.insertSublayer(blurLayer, at: 1)
            blurLayer.frame = view.bounds
            currencyConverterLabel.text = "---"
            currencyConverterLabel.backgroundColor = .gray
            currencySelectionTo.amountLabel.text = "-"
        } else {
            blurLayer.removeFromSuperlayer()
        }
    }
}
