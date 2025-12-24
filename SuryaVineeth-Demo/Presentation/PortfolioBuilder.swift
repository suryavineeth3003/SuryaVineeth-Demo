//
//  PortfolioBuilder.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

import Foundation

struct PortfolioViewControllerBuilder {
    
    /// Constructs the HoldingViewControler by injecting the dependencies
    /// - Returns: instance of HoldingViewController
    static func createHoldingViewController() -> HoldingViewController {
        let endpoint = API.holdings.endpointUrl!
        
        let remote = HoldingsRemoteDatasource(url: endpoint)
        let local = HoldingsLocalDataSource()
        let repository = HoldingsRepository(remoteDataSource: remote, localDataSource: local)
        
        let fetchHoildingUsecase = FetchHoldingsUsecase(repository: repository)
        let viewModel = HoldingsViewModel(formatter: INRFormatter(), usecase: fetchHoildingUsecase)
        return HoldingViewController(viewModel: viewModel)
    }
}
