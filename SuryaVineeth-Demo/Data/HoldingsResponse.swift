//
//  HoldingsResponse.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

import Foundation

struct HoldingsResponse: Codable {
    let data: HoldingsData
}

struct HoldingsData: Codable {
    let userHolding: [HoldingDTO]
}

struct HoldingDTO: Codable, Equatable {
    let symbol: String
    let quantity: Int
    let ltp: Double
    let avgPrice: Double
    let close: Double

}
