//
//  HoldingsLocalDataSourceTests.swift
//  SuryaVineeth-DemoTests
//
//  Created by Surya Vineeth on 23/12/25.
//

import XCTest
@testable import SuryaVineeth_Demo


final class HoldingsLocalDataSourceTests: XCTestCase {
    
    private let key = "cached_holdings_test"
    private var sut: HoldingsLocalDataSource!
    private var userDefaults: UserDefaults = UserDefaults.standard
    
    override func setUp() {
        super.setUp()
        sut = HoldingsLocalDataSource(defaults: userDefaults,cacheKey: key)
    }
    
    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: key)
        sut = nil
        super.tearDown()
    }
    
    func test_fetchHoldings_whenNothingSaved_returnsEmpty() {
        XCTAssertTrue(sut.fetchHoldings().isEmpty)
    }
    
    func test_saveThenFetch_returnsSameHoldings() {
        let holdings: [HoldingDTO] = [HoldingDTO(symbol: "BGHT", quantity: 12, ltp: 35.8, avgPrice: 45, close: 67)]
        sut.save(holdings)
        XCTAssertEqual(sut.fetchHoldings(), holdings)
    }
    
    func test_deleteHoldings_clearsSavedData() {
        sut.save([HoldingDTO(symbol: "BGHT", quantity: 12, ltp: 35.8, avgPrice: 45, close: 67)])
        sut.deleteHoldings()
        XCTAssertTrue(sut.fetchHoldings().isEmpty)
    }
}
