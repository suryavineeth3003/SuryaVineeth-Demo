//
//  SummaryModelTests.swift
//  SuryaVineeth-DemoTests
//
//  Created by Surya Vineeth on 23/12/25.
//

import XCTest
@testable import SuryaVineeth_Demo

final class SummaryModelTests: XCTestCase {
    func test_init_withEmptyHoldings_setsAllValuesToZero() {
        let sut = SummaryModel(holdings: [])
        
        XCTAssertEqual(sut.totalInvested, 0, accuracy: 0.000_001)
        XCTAssertEqual(sut.currentValue, 0, accuracy: 0.000_001)
        XCTAssertEqual(sut.totalProfitLoss, 0, accuracy: 0.000_001)
        XCTAssertEqual(sut.todayProfitLoss, 0, accuracy: 0.000_001)
    }
    
    func test_init_withSingleHolding_calculatesCorrectTotals() {
        let holding = Holding(
            symbol: "INFY",
            quantity: 10,
            ltp: 100,
            avgPrice: 80,
            close: 95
        )
        
        // totalInvested = 80 * 10 = 800
        // currentValue = 100 * 10 = 1000
        // totalProfitLoss = 200
        // todayProfitLoss = (95 - 100) * 10 = -50
        
        let sut = SummaryModel(holdings: [holding])
        
        XCTAssertEqual(sut.totalInvested, 800, accuracy: 0.000_001)
        XCTAssertEqual(sut.currentValue, 1000, accuracy: 0.000_001)
        XCTAssertEqual(sut.totalProfitLoss, 200, accuracy: 0.000_001)
        XCTAssertEqual(sut.todayProfitLoss, -50, accuracy: 0.000_001)
    }
    
    func test_init_withMultipleHoldings_aggregatesValuesCorrectly() {
        let holding1 = Holding(
            symbol: "INFY",
            quantity: 10,
            ltp: 100,
            avgPrice: 80,
            close: 95
        )
        // invested = 800, current = 1000, todayPL = -50
        
        let holding2 = Holding(
            symbol: "TCS",
            quantity: 5,
            ltp: 200,
            avgPrice: 150,
            close: 210
        )
        // invested = 750, current = 1000, todayPL = 50
        
        let sut = SummaryModel(holdings: [holding1, holding2])
        
        // totalInvested = 800 + 750 = 1550
        // currentValue = 1000 + 1000 = 2000
        // totalProfitLoss = 450
        // todayProfitLoss = -50 + 50 = 0
        
        XCTAssertEqual(sut.totalInvested, 1550, accuracy: 0.000_001)
        XCTAssertEqual(sut.currentValue, 2000, accuracy: 0.000_001)
        XCTAssertEqual(sut.totalProfitLoss, 450, accuracy: 0.000_001)
        XCTAssertEqual(sut.todayProfitLoss, 0, accuracy: 0.000_001)
    }
    
    func test_totalProfitLoss_isDerivedFromCurrentMinusInvested() {
        let holding = Holding(
            symbol: "ABC",
            quantity: 2,
            ltp: 120,
            avgPrice: 100,
            close: 115
        )
        
        let sut = SummaryModel(holdings: [holding])
        
        XCTAssertEqual(
            sut.totalProfitLoss,
            sut.currentValue - sut.totalInvested,
            accuracy: 0.000_001
        )
    }
    
    func test_todayProfitLoss_sumsIndividualTodayProfitLosses() {
        let h1 = Holding(
            symbol: "A",
            quantity: 10,
            ltp: 50,
            avgPrice: 40,
            close: 55
        ) // todayPL = (55-50)*10 = 50
        
        let h2 = Holding(
            symbol: "B",
            quantity: 5,
            ltp: 100,
            avgPrice: 90,
            close: 95
        ) // todayPL = (95-100)*5 = -25
        
        let sut = SummaryModel(holdings: [h1, h2])
        
        XCTAssertEqual(sut.todayProfitLoss, 25, accuracy: 0.000_001)
    }
    
    func test_totalProfitLoss_includesPercentage() {
        let summary = SummaryModel(
            totalInvested: 10_000,
            currentValue: 10_244,
            totalProfitLoss: 244,
            todayProfitLoss: 0
        )

        let formatter = CurrencyFormatterStub()
        let vm = SummaryViewModel(summary: summary, formatter: formatter)

        XCTAssertEqual(vm.totalProfitLossValue, "₹244.00 (2.44%)")
    }
}
