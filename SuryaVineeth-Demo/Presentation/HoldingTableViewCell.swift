//
//  HoldingTableViewCell.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

import UIKit

class HoldingTableViewCell: UITableViewCell {
    
    static let identifier: String = "HoldingTableViewCell"
    
    private let symbolLabel = UILabel()
    private let ltpView = HoldingItemView(key: HoldingItemKeyType.ltp.title)
    
    private let quantityView = HoldingItemView(key: HoldingItemKeyType.quantity.title)
    private let pnlView = HoldingItemView(key: HoldingItemKeyType.pnl.title)
    
    private let topRowstackView = UIStackView()
    private let bottomRowstackView = UIStackView()
    private let containerStack = UIStackView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    private func setupUI() {
        symbolLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        symbolLabel.textColor = .label
        
        
        topRowstackView.axis = .horizontal
        topRowstackView.alignment = .center
        topRowstackView.translatesAutoresizingMaskIntoConstraints = false
        topRowstackView.addArrangedSubview(symbolLabel)
        topRowstackView.addArrangedSubview(UIView())
        topRowstackView.addArrangedSubview(ltpView)
        
        bottomRowstackView.axis = .horizontal
        bottomRowstackView.alignment = .center
        bottomRowstackView.translatesAutoresizingMaskIntoConstraints = false
        bottomRowstackView.addArrangedSubview(quantityView)
        bottomRowstackView.addArrangedSubview(UIView())
        bottomRowstackView.addArrangedSubview(pnlView)
        
        containerStack.axis = .vertical
        containerStack.spacing = 30
        containerStack.translatesAutoresizingMaskIntoConstraints = false
        containerStack.addArrangedSubview(topRowstackView)
        containerStack.addArrangedSubview(bottomRowstackView)
        
        contentView.addSubview(containerStack)
        

        NSLayoutConstraint.activate([
            containerStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            containerStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            containerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            containerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10)
        ])
    }
    
    func configure(with vm: HoldingCellViewModel) {
        symbolLabel.text = vm.symbol
        ltpView.setValue(vm.ltp, color: .label)
        quantityView.setValue(vm.quantity, color: .label)
        pnlView.setValue(vm.pnlText, color: vm.pnlColor)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
