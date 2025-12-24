//
//  SummaryViewModelTests.swift
//  SuryaVineeth-DemoTests
//
//  Created by Surya Vineeth on 23/12/25.
//

import XCTest
@testable import SuryaVineeth_Demo

final class SummaryViewModelTests: XCTestCase {
    
    // MARK: - Tests
    
    func test_init_formatsAllValuesUsingFormatter_andDefaultsIsExpandedFalse() {
        let summary = SummaryModel(
            totalInvested: 1550,
            currentValue: 2000,
            totalProfitLoss: 450,
            todayProfitLoss: 25
        )
        
        let formatter = CurrencyFormatterStub()
        let sut = SummaryViewModel(summary: summary, formatter: formatter)
        
        XCTAssertEqual(sut.currentValue, "₹2000.00")
        XCTAssertEqual(sut.totalInvestedValue, "₹1550.00")
        XCTAssertEqual(sut.totalProfitLossValue, "₹450.00 (29.03%)")
        XCTAssertEqual(sut.todayProfitLossValue, "₹25.00")
        XCTAssertEqual(sut.isExpanded, false)
    }
    
    func test_init_formatsNegativeProfitLoss_withPercentage_andRedColor() {
        // Given
        let summary = SummaryModel(
            totalInvested: 2000,
            currentValue: 1500,
            totalProfitLoss: -500,
            todayProfitLoss: -50
        )

        let formatter = CurrencyFormatterStub()

        // When
        let sut = SummaryViewModel(summary: summary, formatter: formatter)

        // Then
        XCTAssertEqual(sut.currentValue, "₹1500.00")
        XCTAssertEqual(sut.totalInvestedValue, "₹2000.00")
        XCTAssertEqual(sut.totalProfitLossValue, "₹-500.00 (-25.00%)")
        XCTAssertEqual(sut.todayProfitLossValue, "₹-50.00")

        XCTAssertEqual(sut.totalProfitLossTextColor, .red)
        XCTAssertEqual(sut.todayProfitLossTextColor, .red)
        XCTAssertFalse(sut.isExpanded)
    }
    
    func test_init_setsIsExpandedTrue_whenPassedTrue() {
        let summary = SummaryModel(
            totalInvested: 10,
            currentValue: 10,
            totalProfitLoss: 0,
            todayProfitLoss: 0
        )
        
        let formatter = CurrencyFormatterStub()
        let sut = SummaryViewModel(summary: summary, formatter: formatter, isExpanded: true)
        
        XCTAssertTrue(sut.isExpanded)
    }
    
    func test_init_setsColorsToSystemTeal_whenProfitLossIsPositiveOrZero() {
        let summary = SummaryModel(
            totalInvested: 100,
            currentValue: 100,
            totalProfitLoss: 0,
            todayProfitLoss: 10
        )
        
        let formatter = CurrencyFormatterStub()
        let sut = SummaryViewModel(summary: summary, formatter: formatter)
        
        XCTAssertEqual(sut.totalProfitLossTextColor, .systemTeal)
        XCTAssertEqual(sut.todayProfitLossTextColor, .systemTeal)
    }
    
    func test_init_setsColorsToRed_whenProfitLossIsNegative() {
        let summary = SummaryModel(
            totalInvested: 100,
            currentValue: 90,
            totalProfitLoss: -10,
            todayProfitLoss: -5
        )
        
        let formatter = CurrencyFormatterStub()
        let sut = SummaryViewModel(summary: summary, formatter: formatter)
        
        XCTAssertEqual(sut.totalProfitLossTextColor, .red)
        XCTAssertEqual(sut.todayProfitLossTextColor, .red)
    }
}


