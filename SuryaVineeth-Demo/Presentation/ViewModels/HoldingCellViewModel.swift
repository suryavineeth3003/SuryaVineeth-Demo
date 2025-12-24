//
//  HoldingCellViewModel.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

import Foundation
import UIKit

struct HoldingCellViewModel {
    let symbol: String
    let quantity: String
    let ltp: String
    let pnlText: String
    let pnlColor: UIColor
    
   
    init(holding: Holding, formatter: CurrencyFormatter) {
        self.symbol = holding.symbol
        self.quantity = "\(holding.quantity)"
        self.ltp = formatter.format(holding.ltp)
        let totalPnl = holding.totalProfitLoss
        self.pnlText = formatter.format(totalPnl)
        self.pnlColor = totalPnl >= 0 ? .systemTeal : .systemRed
    }
}
