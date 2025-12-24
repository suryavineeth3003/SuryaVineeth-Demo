//
//  SummaryViewModel.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

import Foundation
import UIKit

struct SummaryViewModel {
    let currentValue: String
    let totalInvestedValue: String
    let todayProfitLossValue: String
    let totalProfitLossValue: String
    let isExpanded: Bool
    let todayProfitLossTextColor: UIColor
    let totalProfitLossTextColor: UIColor
    
    init(
        summary: SummaryModel,
        formatter: CurrencyFormatter,
        isExpanded:Bool = false
    ) {
        self.currentValue = formatter.format(summary.currentValue)
        self.totalInvestedValue = formatter.format(summary.totalInvested)
        self.todayProfitLossValue = formatter.format(summary.todayProfitLoss)
        let totalPL = summary.totalProfitLoss
        let percentage = summary.totalProfitLossPercentage
        self.totalProfitLossValue = String(
            format: "%@ (%.2f%%)",
            formatter.format(totalPL),
            percentage
        )
        self.isExpanded = isExpanded
        
        self.todayProfitLossTextColor = summary.todayProfitLoss >= 0 ? .systemTeal : .red
        self.totalProfitLossTextColor = summary.totalProfitLoss >= 0 ? .systemTeal : .red
    }
}
