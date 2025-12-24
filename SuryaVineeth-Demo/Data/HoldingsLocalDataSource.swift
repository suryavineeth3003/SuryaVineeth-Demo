//
//  HoldingsLocalDataSource.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

import Foundation
final class HoldingsLocalDataSource: HoldingsLocalDataSourceProtocol {
    private var cachKey = "cached_holdings"
    private let defaults: UserDefaults
    
    
    /// Initializer
    /// - Parameters:
    ///   - defaults: userdefaults
    ///   - cacheKey: key to use
    init(defaults: UserDefaults = .standard, cacheKey: String = "") {
        self.defaults = defaults
        self.cachKey = cacheKey.isEmpty ? self.cachKey : cacheKey
    }
    
    
    /// Saves the holding in local cache
    /// - Parameter holdings: array of holdings
    func save(_ holdings: [HoldingDTO]) {
        guard let data = try? JSONEncoder().encode(holdings) else {
            return
        }
        defaults.set(data, forKey: cachKey)
    }
    
    /// Fetches the holdings from local cache
    /// - Returns: array of Holdings
    func fetchHoldings() -> [HoldingDTO] {
        guard let data = defaults.data(forKey: cachKey),
              let holdings = try? JSONDecoder().decode([HoldingDTO].self, from: data) else {
            return []
        }
        return holdings
    }
    
    /// Deletes the data from local cache
    func deleteHoldings() {
        defaults.removeObject(forKey: cachKey)
    }
    
    
}
