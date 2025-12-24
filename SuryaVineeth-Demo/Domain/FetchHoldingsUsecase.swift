//
//  FetchHoldingsUsecase.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

import Foundation

final class FetchHoldingsUsecase: FetchHoldingsUsecaseProtocol {

    private let repository: HoldingsRepositoryProtocol
    
    init(repository: HoldingsRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Holding] {
        try await repository.fetchHoldings()
    }
    
}
