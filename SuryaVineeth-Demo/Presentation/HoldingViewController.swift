//
//  HoldingViewController.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 22/12/25.
//

import UIKit

class HoldingViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .singleLine
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let summaryView = SummaryView()
    
    private let viewModel: HoldingsViewModel
    
    private var summaryHeightConstraint: NSLayoutConstraint!
    
    private let errorView = FullScreenErrorView()
    
    private let headerSpinner = UIActivityIndicatorView(style: .medium)
    
    init(viewModel: HoldingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setupUI()
        self.setupBindings()
        self.showTableLoader()
        viewModel.loadHoldings()
    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    //MARK: Private methods
    
    private func setupUI() {
        self.setupTableView()
        self.setupSummaryView()
        self.setupErrorView()
    }
    
    private func setupSummaryView() {
        summaryView.translatesAutoresizingMaskIntoConstraints = false
        summaryView.backgroundColor = .systemGray6
        view.addSubview(summaryView)
        
        summaryHeightConstraint = summaryView.heightAnchor.constraint(equalToConstant: summaryView.footerHeight + 40)
        summaryHeightConstraint.isActive = true
        
        // setup constraint
        NSLayoutConstraint.activate([
            summaryView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            summaryView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            summaryView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.bringSubviewToFront(summaryView)
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        
        tableView.register(HoldingTableViewCell.self, forCellReuseIdentifier: HoldingTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.separatorInset = .zero
        
        // setup constraint
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupBindings() {
        summaryView.onToggle = { [weak self] in
            self?.viewModel.toggleSummary()
        }
        
        viewModel.onSummaryUpdated = { [weak self] summaryVM in
            guard let self else {return}
            self.summaryView.applyData(summaryVM)
            self.view.layoutIfNeeded()
            self.summaryView.setExpanded(summaryVM.isExpanded)
            let newHeight = self.summaryView.desiredHeight(isExpanded: summaryVM.isExpanded) + 40
            self.summaryHeightConstraint.constant = newHeight
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
                self.tableView.contentInset.bottom = newHeight
                self.tableView.verticalScrollIndicatorInsets.bottom = newHeight
            }
            self.view.bringSubviewToFront(self.summaryView)
        }
        
        viewModel.onHoldingsUpdated = { [weak self] in
            self?.hideTableLoader()
            self?.hideErrorView()
            self?.tableView.reloadData()
        }
        
        viewModel.onError = { [weak self] error in
            self?.hideTableLoader()
            self?.showErrorView(message: error)
        }
        
    }
    
    private func showErrorView(message: String) {
        tableView.isHidden = true
        summaryView.isHidden = true

        errorView.configure(
            image: UIImage(systemName: "wifi.exclamationmark"),
            title: AlertMessage.failedToFetchHolding.text,
            message: message,
            actionTitle: AlertMessage.alertActionTitle.text
        )
        errorView.isHidden = false
    }
    
    private func hideErrorView() {
        errorView.isHidden = true
        tableView.isHidden = false
        summaryView.isHidden = false
    }
    
    private func updateTableBottomInset(height: CGFloat) {
        view.layoutIfNeeded()
        tableView.contentInset.bottom = height
        tableView.verticalScrollIndicatorInsets.bottom = height
    }
    
    private func setupErrorView() {
        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            errorView.topAnchor.constraint(equalTo: view.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        errorView.isHidden = true

        errorView.onAction = { [weak self] in
            self?.hideErrorView()
            self?.showTableLoader()
            self?.viewModel.loadHoldings()
        }
    }
    private func showTableLoader() {
        headerSpinner.startAnimating()
        headerSpinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        tableView.tableHeaderView = headerSpinner
    }

    private func hideTableLoader() {
        headerSpinner.stopAnimating()
        tableView.tableHeaderView = nil
    }
}

extension HoldingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfHoldings()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HoldingTableViewCell.identifier, for: indexPath) as? HoldingTableViewCell else {
            return UITableViewCell()
        }
        let cellVM = viewModel.cellViewModel(for: indexPath.row)
        cell.configure(with: cellVM)
        cell.selectionStyle = .none
        return cell
    }
}
