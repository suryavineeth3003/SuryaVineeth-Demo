//
//  SummaryView.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 22/12/25.
//

import UIKit

class SummaryView: UIView {
    
    private let headerStackView = UIStackView()
    
    private let investedRow = SummaryRow(title: SummaryRowType.investedValue.title)
    private let currentValueRow = SummaryRow(title: SummaryRowType.currentValue.title)
    private let todayProfitLossRow = SummaryRow(title: SummaryRowType.todayPL.title)
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray2
        view.alpha = 0.0
        return view
    }()
    private var headerContainer = UIView()
    private var headerViewHeightConstraint: NSLayoutConstraint!
    private let shadowView = UIView()
    private let containerView = UIView()

    private let footerView = UIView()
    private let totalProfitLossLbl: UILabel = {
        let label = UILabel()
        label.text = SummaryRowType.totalPL.title
        label.font = .systemFont(ofSize: 14)
        label.textColor = .darkGray
        return label
    }()
    
    private let totlProftLossValueLbl: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .right
        label.textColor = .gray
        return label
    }()
    
    
    private let arrowImage: UIImageView = {
        let image = UIImageView(image: UIImage(systemName: "chevron.up"))
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .darkGray
        return image
    }()
    
    var footerHeight: CGFloat { 40 }

    func desiredHeight(isExpanded: Bool) -> CGFloat {
        let header = isExpanded ? expandedHeaderHeight() : 0
        return footerHeight + header
    }
    
    var onToggle: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyTopRoundedCorners()
        self.applyShadow()
    }
    
    func applyData(_ model: SummaryViewModel) {
        totlProftLossValueLbl.text = model.totalProfitLossValue
        totlProftLossValueLbl.textColor = model.totalProfitLossTextColor
        
        investedRow.setValue(model.totalInvestedValue)
        currentValueRow.setValue(model.currentValue)
        todayProfitLossRow.setValue(model.todayProfitLossValue, color: model.todayProfitLossTextColor)
    }
    
    func setExpanded(_ isexpanded: Bool) {
        if isexpanded {
            headerStackView.isHidden = false
        }
        
        layoutIfNeeded()
        headerViewHeightConstraint.constant = isexpanded ? expandedHeaderHeight() : 0
        separatorView.alpha = isexpanded ? 1 : 0
        
        UIView.animate(withDuration: 0.3, animations: {
            self.arrowImage.transform =
            isexpanded ? CGAffineTransform(rotationAngle: .pi) : .identity
            self.layoutIfNeeded()
        }, completion: { _ in
            if !isexpanded {
                self.headerStackView.isHidden = true
            }
        })
    }
    
    // MARK: Private methods
    
    @objc private func onFooterTapped() {
        onToggle?()
    }
    
    private func applyConstraints() {
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerContainer.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            headerContainer.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerContainer.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            footerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            //headerContainer.bottomAnchor.constraint(equalTo: footerView.topAnchor)
            ])
    }
    
    private func applyTopRoundedCorners() {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        containerView.layer.mask = mask
    }
    
    private func applyShadow() {
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowOpacity = 0.25
        shadowView.layer.shadowOffset = CGSize(width: 0, height: -2)
        shadowView.layer.shadowRadius = 2
        shadowView.layer.masksToBounds = false
        
        let topShadowHeight: CGFloat = 2
        let shadowRect = shadowView.bounds.insetBy(dx: 0, dy: -topShadowHeight)
        let shadowPath = UIBezierPath(
            roundedRect: shadowRect,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        shadowView.layer.shadowPath = shadowPath.cgPath
    }
    
    private func setupUI() {
        backgroundColor = .systemGray6

        shadowView.backgroundColor = .systemGray6
        shadowView.layer.cornerRadius = 16
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(shadowView)
        
        containerView.backgroundColor = .systemGray6
        containerView.isOpaque = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: topAnchor),
            shadowView.leadingAnchor.constraint(equalTo: leadingAnchor),
            shadowView.trailingAnchor.constraint(equalTo: trailingAnchor),
            shadowView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: shadowView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor),
        ])
        
        setupHeaderView()
        setupFooterview()
        applyConstraints()
        applyShadow()
    }
    
    private func setupHeaderView() {
        headerContainer.translatesAutoresizingMaskIntoConstraints = false
        headerContainer.clipsToBounds = true
        
        containerView.addSubview(headerContainer)
        
        headerStackView.axis = .vertical
        headerStackView.spacing = 30
        headerStackView.isHidden = true
        headerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        headerStackView.addArrangedSubview(currentValueRow)
        headerStackView.addArrangedSubview(investedRow)
        headerStackView.addArrangedSubview(todayProfitLossRow)
        
        headerContainer.addSubview(headerStackView)
        
        
        NSLayoutConstraint.activate([
            headerStackView.topAnchor.constraint(equalTo: headerContainer.topAnchor),
            headerStackView.leadingAnchor.constraint(equalTo: headerContainer.leadingAnchor, constant: 16),
            headerStackView.trailingAnchor.constraint(equalTo: headerContainer.trailingAnchor, constant: -16),
        ])
        
        headerViewHeightConstraint = headerContainer.heightAnchor.constraint(equalToConstant: 0)
        headerViewHeightConstraint.isActive = true
        headerContainer.clipsToBounds = true
    }
    
    private func setupFooterview() {
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.isUserInteractionEnabled = true
        containerView.addSubview(footerView)
        
        let leftStack = UIStackView(arrangedSubviews: [totalProfitLossLbl, arrowImage])
        leftStack.axis = .horizontal
        leftStack.alignment = .center
        leftStack.spacing = 8
        leftStack.translatesAutoresizingMaskIntoConstraints = false
        
        let footerStack = UIStackView(arrangedSubviews: [leftStack, UIView(), totlProftLossValueLbl])
        footerStack.axis = .horizontal
        footerStack.alignment = .center
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        
        footerView.addSubview(footerStack)
        
        footerView.addSubview(separatorView)

        NSLayoutConstraint.activate([
            separatorView.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 10),
            footerStack.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 10),
            footerStack.bottomAnchor.constraint(equalTo: footerView.bottomAnchor),
            footerStack.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 16),
            footerStack.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -16),
            
            footerView.heightAnchor.constraint(equalToConstant: footerHeight)
        ])
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onFooterTapped))
        footerView.addGestureRecognizer(tapGesture)
    }
    
    private func expandedHeaderHeight() -> CGFloat {
        let width = max(0, containerView.bounds.width - 32)
           let size = CGSize(width: width, height: UIView.layoutFittingCompressedSize.height)

           return headerStackView.systemLayoutSizeFitting(
               size,
               withHorizontalFittingPriority: .required,
               verticalFittingPriority: .fittingSizeLevel
           ).height
    }

}
