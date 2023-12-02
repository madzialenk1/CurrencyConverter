//
//  CountryTableViewCell.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 29/11/2023.
//

import UIKit
import SnapKit

class CountryTableViewCell: UITableViewCell {
    private let flagImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let countryNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let currencyLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addSubviews()
        setConstraints()
    }
    
    private func addSubviews() {
        addSubview(flagImageView)
        addSubview(countryNameLabel)
        addSubview(currencyLabel)
    }
    
    private func setConstraints() {
        flagImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(30)
        }
        
        countryNameLabel.snp.makeConstraints {
            $0.leading.equalTo(flagImageView.snp.trailing).offset(16)
            $0.top.equalToSuperview().offset(12)
        }
        
        currencyLabel.snp.makeConstraints {
            $0.leading.equalTo(flagImageView.snp.trailing).offset(16)
            $0.top.equalTo(countryNameLabel.snp.bottom).offset(4)
        }
    }
    
    func configure(with country: Country) {
        flagImageView.image = UIImage(named: country.flagIconName)
        countryNameLabel.text = country.name
        currencyLabel.text = country.currency
    }
}
