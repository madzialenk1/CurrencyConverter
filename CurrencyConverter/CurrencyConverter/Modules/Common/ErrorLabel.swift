//
//  ErrorLabel.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 01/12/2023.
//

import Foundation
import UIKit
import SnapKit

class ErrorLabel: UIView {
    private let errorText: UILabel = {
        let label = UILabel()
        label.textColor = CustomColors.customRed
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let errorImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.Images.alertIcon)
        return imageView
    }()
    
    func configure(text: String) {
        addSubviews()
        setConstraints()
        errorText.text = text
    }
    
    private func addSubviews() {
        addSubview(errorImage)
        addSubview(errorText)
    }
    
    private func setConstraints() {
        errorImage.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.size.equalTo(16)
            $0.centerY.equalToSuperview()
        }
        
        errorText.snp.makeConstraints {
            $0.leading.equalTo(errorImage.snp.trailing).offset(3)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }
}
