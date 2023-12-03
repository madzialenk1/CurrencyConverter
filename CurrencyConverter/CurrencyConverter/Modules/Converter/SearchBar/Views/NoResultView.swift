//
//  NoResultView.swift
//  CurrencyConverter
//
//  Created by Magda Pękacka on 02/12/2023.
//

import Foundation
import UIKit
import SnapKit

class NoResultView: UIView {
    private let label: UILabel = {
        let label = UILabel()
        label.text = "no_result_view".localized()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        addSubview(label)
        setConstraints()
    }
    
    private func setConstraints() {
        label.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
