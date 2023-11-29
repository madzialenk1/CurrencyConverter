//
//  CustomSearchBar.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 29/11/2023.
//

import UIKit

class CustomSearchBar: UIView {
    
    let searchTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .black
        textField.font = UIFont.systemFont(ofSize: 16)
        return textField
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 8
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.backgroundColor = .clear
        return view
    }()
    
    private let searchLabel: UILabel = {
        let label = UILabel()
        label.text = "Search"
        label.backgroundColor = .white
        label.textColor = UIColor.lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private let searchIconView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "search"))
        imageView.contentMode = .center
        return imageView
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    private func setupUI() {
        addSubview(borderView)
        addSubview(searchTextField)
        addSubview(searchLabel)
        addSubview(searchIconView)
        
        borderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        searchTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(searchIconView.snp.leading).offset(-8)
        }
        
        searchIconView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(8)
            $0.width.height.equalTo(24)
        }
        
        searchLabel.snp.makeConstraints {
            $0.leading.equalTo(borderView.snp.leading).offset(10)
            $0.top.equalTo(borderView.snp.top).offset(-7)
        }
    }
}
