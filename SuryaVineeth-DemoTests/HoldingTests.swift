//
//  HoldingTests.swift
//  SuryaVineeth-DemoTests
//
//  Created by Surya Vineeth on 23/12/25.
//

import XCTest
@testable import SuryaVineeth_Demo

final class HoldingTests: XCTestCase {
    
    func test_totalInvested_isAvgPriceTimesQuantity() {
        let sut = Holding(symbol: "INFY", quantity: 10, ltp: 78, avgPrice: 1200.0, close: 54)
        
        XCTAssertEqual(sut.totalInvested, 12000.0, accuracy: 0.000_001)
    }
    
    func test_currentValue_isLtpTimesQuantity() {
        let sut = Holding(symbol: "INFY", quantity: 10, ltp: 78, avgPrice: 1200.0, close: 54)
        
        XCTAssertEqual(sut.currentValue, 780.0, accuracy: 0.000_001)
    }
    
    func test_totalProfitLoss_isCurrentValueMinusTotalInvested() {
        let sut = Holding(symbol: "INFY", quantity: 10, ltp: 78, avgPrice: 1200.0, close: 54)
        
        // currentValue = 78*10 = 780
        // totalInvested = 1200*10 = 12000
        // totalProfitLoss = 780 - 12000 = -11220
        XCTAssertEqual(sut.totalProfitLoss, -11220.0, accuracy: 0.000_001)
    }
    
    func test_todayProfitLoss_isCloseMinusLtp_timesQuantity() {
        let sut = Holding(symbol: "INFY", quantity: 10, ltp: 78, avgPrice: 1200.0, close: 54)
        
        // (close - ltp) * qty = (54 - 78) * 10 = -240
        XCTAssertEqual(sut.todayProfitLoss, -240.0, accuracy: 0.000_001)
    }
    
    func test_profitLoss_values_whenQuantityIsZero_areZero() {
        let sut = Holding(symbol: "INFY", quantity: 0, ltp: 78, avgPrice: 1200.0, close: 54)
        
        XCTAssertEqual(sut.totalInvested, 0.0, accuracy: 0.000_001)
        XCTAssertEqual(sut.currentValue, 0.0, accuracy: 0.000_001)
        XCTAssertEqual(sut.totalProfitLoss, 0.0, accuracy: 0.000_001)
        XCTAssertEqual(sut.todayProfitLoss, 0.0, accuracy: 0.000_001)
    }
    
    func test_todayProfitLoss_isZero_whenCloseEqualsLtp() {
        let sut = Holding(symbol: "INFY", quantity: 10, ltp: 100.0, avgPrice: 80.0, close: 100.0)
        
        XCTAssertEqual(sut.todayProfitLoss, 0.0, accuracy: 0.000_001)
    }
    
    func test_totalProfitLoss_positive_case() {
        let sut = Holding(symbol: "TCS", quantity: 5, ltp: 120.0, avgPrice: 100.0, close: 118.0)
        
        // totalInvested = 100*5 = 500
        // currentValue = 120*5 = 600
        // totalProfitLoss = 100
        XCTAssertEqual(sut.totalInvested, 500.0, accuracy: 0.000_001)
        XCTAssertEqual(sut.currentValue, 600.0, accuracy: 0.000_001)
        XCTAssertEqual(sut.totalProfitLoss, 100.0, accuracy: 0.000_001)
    }
    
    func test_todayProfitLoss_positive_case_whenCloseGreaterThanLtp() {
        let sut = Holding(symbol: "TCS", quantity: 5, ltp: 100.0, avgPrice: 90.0, close: 120.0)
        
        // (close - ltp) * qty = (120 - 100) * 5 = 100
        XCTAssertEqual(sut.todayProfitLoss, 100.0, accuracy: 0.000_001)
    }
    
}
