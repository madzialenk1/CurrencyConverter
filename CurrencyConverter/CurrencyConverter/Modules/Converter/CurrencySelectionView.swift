//
//  CurrencySelectionView.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 29/11/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class CurrencySelectionView: UIControl {
    
    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = CustomColors.lightGrey
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let flagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.layer.cornerRadius = 12
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let currencyLabel: UILabel = {
        let label = UILabel()
        label.text = "PLN"
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        return label
    }()
    
    fileprivate let arrowButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "chevron-down"), for: .normal)
        return button
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "10000"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = CustomColors.lightBlue
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(flagImageView)
        addSubview(arrowButton)
        addSubview(amountLabel)
        addSubview(currencyLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(12)
        }
        
        flagImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(12)
            $0.width.height.equalTo(24)
        }
        
        currencyLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(flagImageView.snp.trailing).offset(8)
        }
        
        arrowButton.snp.makeConstraints {
            $0.centerY.equalTo(flagImageView)
            $0.size.equalTo(24)
            $0.leading.equalTo(currencyLabel.snp.trailing).offset(8)
        }
        
        amountLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-12)
        }
    }
    
    func configure(model: ConverterCellUIConfigModel) {
        amountLabel.textColor = model.currencyLabelColor
        titleLabel.text = model.text
        currencyLabel.text = model.currency
    }
}

extension Reactive where Base: CurrencySelectionView {
    var arrowButtonTapped: ControlEvent<Void> {
        return base.arrowButton.rx.tap
    }
}
