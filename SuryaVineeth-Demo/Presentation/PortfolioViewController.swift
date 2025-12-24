//
//  ViewController.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 22/12/25.
//

import UIKit

class PortfolioViewController: UIViewController {
    
    private var currentChild: UIViewController?
    private let holdingVC: HoldingViewController = PortfolioViewControllerBuilder.createHoldingViewController()
    private let positionsVC = PositionsViewController()
    
    private let segmentControl: UISegmentedControl = {
        let segControl = UISegmentedControl(items: PortfolioTab.allCases.map{$0.title})
        segControl.selectedSegmentIndex = 1
        segControl.translatesAutoresizingMaskIntoConstraints = false
        segControl.backgroundColor = .systemBackground
        segControl.selectedSegmentTintColor = .clear
        
        
        segControl.setDividerImage(UIImage(), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        segControl.setBackgroundImage(UIImage(), for: .normal, barMetrics: .default)
        segControl.setBackgroundImage(UIImage(), for: .selected, barMetrics: .default)
        segControl.setBackgroundImage(UIImage(), for: .highlighted, barMetrics: .default)
        
        segControl.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: UIColor.secondaryLabel
        ], for: .normal)
        
        segControl.setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 12, weight: .semibold),
            .foregroundColor: UIColor.label
        ], for: .selected)
        
        return segControl
    }()
    
    private let segmentIndicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray3
        return view
    }()
    
    private let dividerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray3
        return view
    }()
    
    private var indicatorConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        title = "Portfolio"
        navigationItem.largeTitleDisplayMode = .never
        self.configureNavigationBar()
        self.setupUI()
        self.setupActions()
        self.loadView(.holdings)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.updateIndicator()
    }
    
    //MARK: Private methods
    
    private func setupUI() {
        view.addSubview(segmentControl)
        view.addSubview(segmentIndicator)
        view.addSubview(dividerView)
        
        // setup constraint
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            segmentControl.heightAnchor.constraint(equalToConstant: 44),
            
            segmentIndicator.topAnchor.constraint(equalTo: segmentControl.bottomAnchor),
            segmentIndicator.heightAnchor.constraint(equalToConstant: 2),
            segmentIndicator.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            
            dividerView.topAnchor.constraint(equalTo: segmentIndicator.bottomAnchor, constant: 5),
            dividerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dividerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            dividerView.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        indicatorConstraint = segmentIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        indicatorConstraint?.isActive = true
    }
    
    private func updateIndicator() {
        let segmentWidth = view.bounds.width / CGFloat(segmentControl.numberOfSegments)
        let offsetX = segmentWidth * CGFloat(segmentControl.selectedSegmentIndex)
        indicatorConstraint?.constant = offsetX
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut]) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupActions() {
        segmentControl.addTarget(self, action: #selector(onSegmentTapped), for: .valueChanged)
    }
    
    @objc private func onSegmentTapped() {
        let selectedTab = PortfolioTab.allCases[segmentControl.selectedSegmentIndex]
        self.loadView( selectedTab)
        updateIndicator()
    }
    
    private func loadView(_ tab: PortfolioTab) {
        let selectedView: UIViewController = tab == .holdings ? holdingVC : positionsVC
        
        // remove current child
        if let current = currentChild {
            current.willMove(toParent: nil)
            current.view.removeFromSuperview()
            current.removeFromParent()
        }
        
        // add new controller for selected tab
        addChild(selectedView)
        view.addSubview(selectedView.view)
        selectedView.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            selectedView.view.topAnchor.constraint(equalTo: dividerView.bottomAnchor),
            selectedView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            selectedView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            selectedView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        selectedView.didMove(toParent: self)
        currentChild = selectedView
    }
        
    @objc private func didTapProfile() {
        self.displayAlert(message: AlertMessage.profileClick.text)
    }
    
    @objc private func didTapSort() {
        self.displayAlert(message: AlertMessage.sortClick.text)
    }
    
    @objc private func didTapSearch() {
        self.displayAlert(message: AlertMessage.SearchClick.text)
    }
    
    private func configureNavigationBar() {
        // Title
        navigationItem.title = NavigationTitle.portfolio.title
        
        // Left icon (profile)
        let profileItem = makeNavButton(systemName: "person", action: #selector(didTapProfile))
        navigationItem.leftBarButtonItem = profileItem
        
        let sortItem = makeNavButton(systemName: "arrow.up.arrow.down", action: #selector(didTapSort))
        
        let searchItem = makeNavButton(systemName: "magnifyingglass", action: #selector(didTapSearch))
        
        navigationItem.rightBarButtonItems = [searchItem, sortItem]
    }
    
    private func makeNavButton(systemName: String, action: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .custom)
        
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: systemName)
            config.baseForegroundColor = .white
            config.background.backgroundColor = .clear
            config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            
            button.configuration = config
            
            // Remove any highlight background effect
            button.configurationUpdateHandler = { btn in
                var cfg = btn.configuration
                cfg?.background.backgroundColor = .clear
                btn.configuration = cfg
            }
        } else {
            // iOS 14 and below fallback
            button.setImage(UIImage(systemName: systemName), for: .normal)
            button.tintColor = .white
            button.backgroundColor = .clear
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            button.adjustsImageWhenHighlighted = false
        }
        
        button.addTarget(self, action: action, for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
}


