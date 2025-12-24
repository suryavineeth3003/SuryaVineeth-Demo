//
//  Formatters.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

import Foundation


protocol CurrencyFormatter {
    func format(_ value: Double) -> String
}


final class INRFormatter: CurrencyFormatter {
    private let formatter: NumberFormatter
    
    init() {
        self.formatter = NumberFormatter()
        self.formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.currencySymbol = "₹"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
    }
    
    func format(_ value: Double) -> String {
        formatter.string(from: NSNumber(value: value)) ?? "₹0.00"
    }
    
}
