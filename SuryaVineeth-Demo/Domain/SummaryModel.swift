//
//  SummaryModel.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

struct SummaryModel {
    let totalInvested: Double
    let currentValue: Double
    let totalProfitLoss: Double
    let todayProfitLoss: Double
    
    var totalProfitLossPercentage: Double {
        guard totalInvested > 0 else { return 0 }
        return (totalProfitLoss / totalInvested) * 100
    }
    
    init(holdings: [Holding]) {
        totalInvested = holdings.reduce(0) { $0 + $1.totalInvested }
        currentValue = holdings.reduce(0) { $0 + $1.currentValue }
        totalProfitLoss = currentValue - totalInvested
        todayProfitLoss = holdings.reduce(0) { $0 + $1.todayProfitLoss }
    }
    
#if DEBUG
    init(
        totalInvested: Double,
        currentValue: Double,
        totalProfitLoss: Double,
        todayProfitLoss: Double
    ) {
        self.totalInvested = totalInvested
        self.currentValue = currentValue
        self.totalProfitLoss = totalProfitLoss
        self.todayProfitLoss = todayProfitLoss
    }
#endif
}
