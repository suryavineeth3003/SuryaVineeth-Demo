//
//  PositionsViewController.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 22/12/25.
//

import UIKit

class PositionsViewController: UIViewController {
    private let comingSoonLabel: UILabel = {
        let label = UILabel()
        label.text = "Coming Soon"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubview(comingSoonLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            comingSoonLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            comingSoonLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor)
        ])
    }

}
