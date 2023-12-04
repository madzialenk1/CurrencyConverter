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
        label.textAlignment = .left
        label.textColor = CustomColors.customRed
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let errorImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: Constants.Images.alertIcon)
        return imageView
    }()
    
    init() {
        super.init(frame: .zero)
        addSubviews()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String) {
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
        }
        
        errorText.snp.makeConstraints {
            $0.leading.equalTo(errorImage.snp.trailing).offset(3)
            $0.trailing.equalToSuperview()
        }
    }
}

