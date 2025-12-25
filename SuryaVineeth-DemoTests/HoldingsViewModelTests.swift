//
//  HoldingsViewModelTests.swift
//  SuryaVineeth-DemoTests
//
//  Created by Surya Vineeth on 24/12/25.
//

import XCTest

import UIKit
@testable import SuryaVineeth_Demo

@MainActor
final class HoldingsViewModelTests: XCTestCase {
    
    private final class FetchHoldingsUsecaseStub: FetchHoldingsUsecaseProtocol {
        enum Mode {
            case success([Holding])
            case failure(Error)
        }
        
        var mode: Mode
        private(set) var executeCallCount = 0
        
        init(mode: Mode) {
            self.mode = mode
        }
        
        func execute() async throws -> [Holding] {
            executeCallCount += 1
            switch mode {
            case .success(let holdings):
                return holdings
            case .failure(let error):
                throw error
            }
        }
    }
    
    private struct DummyError: LocalizedError {
        let errorDescription: String?
    }
    
    // MARK: - Helpers
    
    private func makeHoldings() -> [Holding] {
        [
            Holding(symbol: "INFY", quantity: 10, ltp: 120, avgPrice: 100, close: 110), // profit
            Holding(symbol: "TCS",  quantity: 5,  ltp: 80,  avgPrice: 100, close: 90)   // loss
        ]
    }
    
    // MARK: - Tests
    
    func test_loadHoldings_success_triggersHoldingsUpdated_andSummaryUpdated() async {
        // Arrange
        let holdings = makeHoldings()
        let usecase = FetchHoldingsUsecaseStub(mode: .success(holdings))
        let formatter = CurrencyFormatterStub()
        let sut = HoldingsViewModel(formatter: formatter, usecase: usecase)
        
        let holdingsUpdated = expectation(description: "onHoldingsUpdated called")
        let summaryUpdated = expectation(description: "onSummaryUpdated called")
        
        sut.onHoldingsUpdated = {
            holdingsUpdated.fulfill()
        }
        
        sut.onSummaryUpdated = { vm in
            // Assert summary VM basics
            XCTAssertFalse(vm.isExpanded)
            XCTAssertEqual(vm.currentValue, "₹1600.00")
            XCTAssertEqual(vm.totalInvestedValue, "₹1500.00")
            XCTAssertEqual(vm.totalProfitLossValue, "₹100.00 (6.67%)")
            XCTAssertEqual(vm.todayProfitLossValue, "₹-50.00")
            
            summaryUpdated.fulfill()
        }
        
        // Act
        sut.loadHoldings()
        
        // Assert
        await fulfillment(of: [holdingsUpdated, summaryUpdated], timeout: 1.0)
        XCTAssertEqual(usecase.executeCallCount, 1)
        XCTAssertEqual(sut.numberOfHoldings(), 2)
        XCTAssertEqual(sut.cellViewModel(for: 0).symbol, "INFY")
        XCTAssertEqual(sut.cellViewModel(for: 1).symbol, "TCS")
    }
    
    func test_loadHoldings_failure_triggersError_andDoesNotTriggerUpdates() async {
        // Arrange
        let error = DummyError(errorDescription: "Network down")
        let usecase = FetchHoldingsUsecaseStub(mode: .failure(error))
        let formatter = CurrencyFormatterStub()
        let sut = HoldingsViewModel(formatter: formatter, usecase: usecase)
        
        let errorExpectation = expectation(description: "onError called")
        errorExpectation.assertForOverFulfill = true
        
        // Inverted expectations: should NOT be called on failure
        let holdingsUpdated = expectation(description: "onHoldingsUpdated should not be called")
        holdingsUpdated.isInverted = true
        
        let summaryUpdated = expectation(description: "onSummaryUpdated should not be called")
        summaryUpdated.isInverted = true
        
        sut.onHoldingsUpdated = { holdingsUpdated.fulfill() }
        sut.onSummaryUpdated = { _ in summaryUpdated.fulfill() }
        
        sut.onError = { message in
            XCTAssertEqual(message, DisplayableErrorType.generic.message)
            errorExpectation.fulfill()
        }
        
        // Act
        sut.loadHoldings()
        
        // Assert
        await fulfillment(of: [errorExpectation, holdingsUpdated, summaryUpdated], timeout: 1.0)
        XCTAssertEqual(usecase.executeCallCount, 1)
        XCTAssertEqual(sut.numberOfHoldings(), 0)
    }
    
    func test_toggleSummary_flipsExpanded_andEmitsUpdatedSummary() async {
        // Arrange
        let holdings = makeHoldings()
        let usecase = FetchHoldingsUsecaseStub(mode: .success(holdings))
        let formatter = CurrencyFormatterStub()
        let sut = HoldingsViewModel(formatter: formatter, usecase: usecase)
        
        let initialSummary = expectation(description: "initial summary emitted (collapsed)")
        let expandedSummary = expectation(description: "expanded summary emitted after toggle")
        
        var receivedExpandedStates: [Bool] = []
        
        sut.onSummaryUpdated = { vm in
            receivedExpandedStates.append(vm.isExpanded)
            if receivedExpandedStates.count == 1 {
                XCTAssertFalse(vm.isExpanded)
                initialSummary.fulfill()
            } else if receivedExpandedStates.count == 2 {
                XCTAssertTrue(vm.isExpanded)
                expandedSummary.fulfill()
            }
        }
        
        // Act
        sut.loadHoldings()
        await fulfillment(of: [initialSummary], timeout: 1.0)
        
        sut.toggleSummary()
        
        // Assert
        await fulfillment(of: [expandedSummary], timeout: 1.0)
        XCTAssertEqual(receivedExpandedStates, [false, true])
    }
    
    func test_cellViewModel_formatsLtpAndPnlCorrectly() async {
        // Arrange
        let holding = Holding(symbol: "INFY", quantity: 10, ltp: 120, avgPrice: 100, close: 110)
        let usecase = FetchHoldingsUsecaseStub(mode: .success([holding]))
        let formatter = CurrencyFormatterStub()
        let sut = HoldingsViewModel(formatter: formatter, usecase: usecase)
        
        let summaryUpdated = expectation(description: "summary emitted")
        sut.onSummaryUpdated = { vm in summaryUpdated.fulfill() }
        
        // Act
        sut.loadHoldings()
        await fulfillment(of: [summaryUpdated], timeout: 1.0)
        
        let cellVM = sut.cellViewModel(for: 0)
        
//         Assert
        XCTAssertEqual(cellVM.symbol, "INFY")
        XCTAssertEqual(cellVM.quantity, "10")
        XCTAssertEqual(cellVM.ltp, "₹120.00")
        XCTAssertEqual(cellVM.pnlText, "₹200.00")
        XCTAssertEqual(cellVM.pnlColor, .systemTeal)
    }
    
    func test_loadHoldings_networkUnavailable_mapsToCorrectMessage() async {
        // Arrange
        let usecase = FetchHoldingsUsecaseStub(mode: .failure(HoldingsDomainError.networkUnavailable))
        let formatter = CurrencyFormatterStub()
        let sut = HoldingsViewModel(formatter: formatter, usecase: usecase)
        
        let errorExpectation = expectation(description: "onError called")
        
        sut.onError = { message in
            XCTAssertEqual(message, DisplayableErrorType.networkUnavailable.message)
            errorExpectation.fulfill()
        }
        
        // Act
        sut.loadHoldings()
        
        // Assert
        await fulfillment(of: [errorExpectation], timeout: 1.0)
    }
    
    func test_loadHoldings_timeout_mapsToCorrectMessage() async {
        // Arrange
        let usecase = FetchHoldingsUsecaseStub(mode: .failure(HoldingsDomainError.timeout))
        let formatter = CurrencyFormatterStub()
        let sut = HoldingsViewModel(formatter: formatter, usecase: usecase)
        
        let errorExpectation = expectation(description: "onError called")
        
        sut.onError = { message in
            XCTAssertEqual(message, DisplayableErrorType.timeout.message)
            errorExpectation.fulfill()
        }
        
        // Act
        sut.loadHoldings()
        
        // Assert
        await fulfillment(of: [errorExpectation], timeout: 1.0)
    }
    
    func test_loadHoldings_unauthorised_mapsToCorrectMessage() async {
        // Arrange
        let usecase = FetchHoldingsUsecaseStub(mode: .failure(HoldingsDomainError.unauthorized))
        let formatter = CurrencyFormatterStub()
        let sut = HoldingsViewModel(formatter: formatter, usecase: usecase)
        
        let errorExpectation = expectation(description: "onError called")
        
        sut.onError = { message in
            XCTAssertEqual(message, DisplayableErrorType.unauthorized.message)
            errorExpectation.fulfill()
        }
        
        // Act
        sut.loadHoldings()
        
        // Assert
        await fulfillment(of: [errorExpectation], timeout: 1.0)
    }
    
    func test_loadHoldings_serverError_mapsToCorrectMessage() async {
        // Arrange
        let usecase = FetchHoldingsUsecaseStub(mode: .failure(HoldingsDomainError.server))
        let formatter = CurrencyFormatterStub()
        let sut = HoldingsViewModel(formatter: formatter, usecase: usecase)
        
        let errorExpectation = expectation(description: "onError called")
        
        sut.onError = { message in
            XCTAssertEqual(message, DisplayableErrorType.server.message)
            errorExpectation.fulfill()
        }
        
        // Act
        sut.loadHoldings()
        
        // Assert
        await fulfillment(of: [errorExpectation], timeout: 1.0)
    }
    
    func test_loadHoldings_decodingError_mapsToCorrectMessage() async {
        // Arrange
        let usecase = FetchHoldingsUsecaseStub(mode: .failure(HoldingsDomainError.decoding))
        let formatter = CurrencyFormatterStub()
        let sut = HoldingsViewModel(formatter: formatter, usecase: usecase)
        
        let errorExpectation = expectation(description: "onError called")
        
        sut.onError = { message in
            XCTAssertEqual(message, DisplayableErrorType.decoding.message)
            errorExpectation.fulfill()
        }
        
        // Act
        sut.loadHoldings()
        
        // Assert
        await fulfillment(of: [errorExpectation], timeout: 1.0)
    }
    
    func test_loadHoldings_unKnownError_mapsToCorrectMessage() async {
        // Arrange
        let usecase = FetchHoldingsUsecaseStub(mode: .failure(HoldingsDomainError.unknown))
        let formatter = CurrencyFormatterStub()
        let sut = HoldingsViewModel(formatter: formatter, usecase: usecase)
        
        let errorExpectation = expectation(description: "onError called")
        
        sut.onError = { message in
            XCTAssertEqual(message, DisplayableErrorType.generic.message)
            errorExpectation.fulfill()
        }
        
        // Act
        sut.loadHoldings()
        
        // Assert
        await fulfillment(of: [errorExpectation], timeout: 1.0)
    }
    
    func test_toggleSummary_doesNotChangeSummaryValues() async {
        // Arrange
        let holdings = makeHoldings()
        let usecase = FetchHoldingsUsecaseStub(mode: .success(holdings))
        let formatter = CurrencyFormatterStub()
        let sut = HoldingsViewModel(formatter: formatter, usecase: usecase)
        
        let initial = expectation(description: "initial summary emitted")
        let toggled = expectation(description: "toggled summary emitted")
        
        var receivedVMs: [SummaryViewModel] = []
        
        sut.onSummaryUpdated = { vm in
            receivedVMs.append(vm)
            if receivedVMs.count == 1 {
                initial.fulfill()
            } else if receivedVMs.count == 2 {
                toggled.fulfill()
            }
        }
        
        // Act
        sut.loadHoldings()
        await fulfillment(of: [initial], timeout: 1.0)
        
        sut.toggleSummary()
        await fulfillment(of: [toggled], timeout: 1.0)
        
        // Assert
        XCTAssertEqual(receivedVMs.count, 2)
        
        XCTAssertEqual(receivedVMs[0].currentValue, receivedVMs[1].currentValue)
        XCTAssertEqual(receivedVMs[0].totalInvestedValue, receivedVMs[1].totalInvestedValue)
        XCTAssertEqual(receivedVMs[0].totalProfitLossValue, receivedVMs[1].totalProfitLossValue)
        XCTAssertEqual(receivedVMs[0].todayProfitLossValue, receivedVMs[1].todayProfitLossValue)
    }
    
    func test_cellViewModel_negativePnl_usesRedColor() async {
        let holding = Holding(symbol: "TCS", quantity: 5, ltp: 80, avgPrice: 100, close: 90)
        let usecase = FetchHoldingsUsecaseStub(mode: .success([holding]))
        let formatter = CurrencyFormatterStub()
        let sut = HoldingsViewModel(formatter: formatter, usecase: usecase)

        let summaryUpdated = expectation(description: "summary emitted")
        sut.onSummaryUpdated = { _ in summaryUpdated.fulfill() }

        sut.loadHoldings()
        await fulfillment(of: [summaryUpdated], timeout: 1.0)

        let cellVM = sut.cellViewModel(for: 0)

        XCTAssertEqual(cellVM.pnlColor, .systemRed)
    }
    
    func test_loadHoldings_calledTwice_replacesHoldings() async {
        let first = [Holding(symbol: "INFY", quantity: 1, ltp: 1, avgPrice: 1, close: 1)]
        let second = [Holding(symbol: "TCS", quantity: 1, ltp: 1, avgPrice: 1, close: 1)]
        
        let usecase = FetchHoldingsUsecaseStub(mode: .success(first))
        let formatter = CurrencyFormatterStub()
        let sut = HoldingsViewModel(formatter: formatter, usecase: usecase)
        
        let firstUpdate = expectation(description: "first holdings update")
        let secondUpdate = expectation(description: "second holdings update")
        
        var updateCount = 0
        sut.onHoldingsUpdated = {
            updateCount += 1
            if updateCount == 1 { firstUpdate.fulfill() }
            if updateCount == 2 { secondUpdate.fulfill() }
        }
        
        // 1st load
        sut.loadHoldings()
        await fulfillment(of: [firstUpdate], timeout: 1.0)
        
        XCTAssertEqual(sut.numberOfHoldings(), 1)
        XCTAssertEqual(sut.cellViewModel(for: 0).symbol, "INFY")
        
        // 2nd load
        usecase.mode = .success(second)
        sut.loadHoldings()
        await fulfillment(of: [secondUpdate], timeout: 1.0)
        
        XCTAssertEqual(sut.numberOfHoldings(), 1)
        XCTAssertEqual(sut.cellViewModel(for: 0).symbol, "TCS")
    }
}
