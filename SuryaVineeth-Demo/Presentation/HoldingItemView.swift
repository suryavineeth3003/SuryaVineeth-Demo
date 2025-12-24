//
//  HoldingItemView.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

import UIKit

class HoldingItemView: UIView {
    private let keyLbl = UILabel()
    private let valueLbl = UILabel()
    
    init(key: String) {
        super.init(frame: .zero)
        self.setupUI(key)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI(_ key: String) {
        keyLbl.text = key
        keyLbl.font = .systemFont(ofSize: 11, weight: .regular)
        keyLbl.textColor = .systemGray2
        
        valueLbl.font = .systemFont(ofSize: 14, weight: .regular)
        valueLbl.textColor = .label
        valueLbl.textAlignment = .right
        
        let stackView = UIStackView(arrangedSubviews: [keyLbl, valueLbl])
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func setValue(_ text: String, color: UIColor = .label) {
        self.valueLbl.text = text
        self.valueLbl.textColor = color
    }

}
