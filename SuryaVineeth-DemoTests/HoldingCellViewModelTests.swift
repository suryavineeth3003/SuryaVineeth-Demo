//
//  HoldingCellViewModelTests.swift
//  SuryaVineeth-DemoTests
//
//  Created by Surya Vineeth on 24/12/25.
//

import XCTest
@testable import SuryaVineeth_Demo

final class CurrencyFormatterStub: CurrencyFormatter {
    func format(_ value: Double) -> String {
        return String(format: "₹%.2f", value)
    }
}

final class HoldingCellViewModelTests: XCTestCase {

    // MARK: - Tests

    func test_init_mapsSymbolAndQuantityCorrectly() {
        // Arrange
        let holding = Holding(
            symbol: "INFY",
            quantity: 10,
            ltp: 100,
            avgPrice: 90,
            close: 95
        )
        let formatter = CurrencyFormatterStub()

        // Act
        let sut = HoldingCellViewModel(holding: holding, formatter: formatter)

        // Assert
        XCTAssertEqual(sut.symbol, "INFY")
        XCTAssertEqual(sut.quantity, "10")
    }

    func test_init_formatsLTPUsingFormatter() {
        let holding = Holding(
            symbol: "TCS",
            quantity: 5,
            ltp: 123.456,
            avgPrice: 100,
            close: 120
        )
        let formatter = CurrencyFormatterStub()

        let sut = HoldingCellViewModel(holding: holding, formatter: formatter)

        XCTAssertEqual(sut.ltp, "₹123.46")
    }

    func test_init_setsPositivePnlTextAndColor_whenProfit() {
        let holding = Holding(
            symbol: "HDFC",
            quantity: 10,
            ltp: 120,
            avgPrice: 100,
            close: 110
        )
        let formatter = CurrencyFormatterStub()

        let sut = HoldingCellViewModel(holding: holding, formatter: formatter)

        XCTAssertEqual(sut.pnlText, "₹200.00")
        XCTAssertEqual(sut.pnlColor, .systemTeal)
    }

    func test_init_setsNegativePnlTextAndColor_whenLoss() {
        let holding = Holding(
            symbol: "WIPRO",
            quantity: 10,
            ltp: 80,
            avgPrice: 100,
            close: 90
        )
        let formatter = CurrencyFormatterStub()

        let sut = HoldingCellViewModel(holding: holding, formatter: formatter)

        XCTAssertEqual(sut.pnlText, "₹-200.00")
        XCTAssertEqual(sut.pnlColor, .systemRed)
    }

    func test_init_setsSystemTealColor_whenPnlIsZero() {
        let holding = Holding(
            symbol: "ICICI",
            quantity: 10,
            ltp: 100,
            avgPrice: 100,
            close: 100
        )
        let formatter = CurrencyFormatterStub()

        let sut = HoldingCellViewModel(holding: holding, formatter: formatter)

        XCTAssertEqual(sut.pnlText, "₹0.00")
        XCTAssertEqual(sut.pnlColor, .systemTeal)
    }
}
