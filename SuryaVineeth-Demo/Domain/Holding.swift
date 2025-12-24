//
//  Untitled.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

struct Holding {
    let symbol: String
    let quantity: Int
    let ltp: Double
    let avgPrice: Double
    let close: Double
    
    var totalInvested: Double {
        return avgPrice * Double(quantity)
    }
    
    var currentValue: Double {
        return ltp * Double(quantity)
    }
    
    var totalProfitLoss: Double {
        return currentValue - totalInvested
    }
    
    var todayProfitLoss: Double {
        return (close - ltp) * Double(quantity)
    }
}
