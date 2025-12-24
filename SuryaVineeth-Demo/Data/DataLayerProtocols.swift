//
//  DataLayerProtocols.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

import Foundation


protocol HoldingsRemoteDataSourceProtocol {
    func fetchHoldings() async throws -> [HoldingDTO]
}


protocol HoldingsLocalDataSourceProtocol {
    func save(_ holdings: [HoldingDTO])
    func fetchHoldings() -> [HoldingDTO]
    func deleteHoldings()
}
