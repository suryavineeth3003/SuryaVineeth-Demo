//
//  DomainProtocols.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

protocol FetchHoldingsUsecaseProtocol {
    func execute() async throws -> [Holding]
}

protocol HoldingsRepositoryProtocol {
    func fetchHoldings() async throws -> [Holding]
}
