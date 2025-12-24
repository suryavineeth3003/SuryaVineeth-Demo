//
//  SummaryRow.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

import UIKit

class SummaryRow: UIView {

    private let titleLbl =  UILabel()
    private let valueLbl = UILabel()
    
    init(title: String) {
        super.init(frame: .zero)
        setupUI(title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(title: String) {
        titleLbl.text = title
        titleLbl.font = .systemFont(ofSize: 14)
        titleLbl.textColor = .darkGray
        
        valueLbl.font = .systemFont(ofSize: 14)
        valueLbl.textAlignment = .right
        valueLbl.textColor = .darkGray
        
        let stack = UIStackView(arrangedSubviews: [titleLbl, valueLbl])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.distribution = .fill
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setValue(_ value: String, color: UIColor = .darkGray) {
        valueLbl.text = value
        valueLbl.textColor = color
    }
    
}
