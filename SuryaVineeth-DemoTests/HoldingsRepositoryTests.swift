//
//  HoldingsRepositoryTests.swift
//  SuryaVineeth-DemoTests
//
//  Created by Surya Vineeth on 23/12/25.
//

import XCTest
@testable import SuryaVineeth_Demo


final class HoldingsRepositoryTests: XCTestCase {
    
    // MARK: - Mocks / Spies
    
    final class RemoteMock: HoldingsRemoteDataSourceProtocol {
        enum Mode {
            case success([HoldingDTO])
            case failure(Error)
        }
        
        var mode: Mode
        private(set) var fetchCallCount = 0
        
        init(mode: Mode) { self.mode = mode }
        
        func fetchHoldings() async throws -> [HoldingDTO] {
            fetchCallCount += 1
            switch mode {
            case .success(let dtos):
                return dtos
            case .failure(let error):
                throw error
            }
        }
    }
    
    final class LocalSpy: HoldingsLocalDataSourceProtocol {
        var stubbedCache: [HoldingDTO] = []
        
        private(set) var saveCallCount = 0
        private(set) var savedValue: [HoldingDTO]?
        
        private(set) var fetchCallCount = 0
        private(set) var deleteCallCount = 0
        
        func save(_ holdings: [HoldingDTO]) {
            saveCallCount += 1
            savedValue = holdings
            stubbedCache = holdings
        }
        
        func fetchHoldings() -> [HoldingDTO] {
            fetchCallCount += 1
            return stubbedCache
        }
        
        func deleteHoldings() {
            deleteCallCount += 1
            stubbedCache = []
        }
    }
    
    // MARK: - Tests
    
    @MainActor
    func test_fetchHoldings_whenRemoteSucceeds_savesToLocal_andReturnsMappedHoldings() async throws {
        // Given
        let dto1 = HoldingDTO(symbol: "AAPL", quantity: 2,ltp: 50.0, avgPrice: 150.0, close: 12.5)
        let dto2 = HoldingDTO(symbol: "TSLA", quantity: 1,ltp: 60.0, avgPrice: 700.5, close: 65.0)
        
        let remote = RemoteMock(mode: .success([dto1, dto2]))
        let local = LocalSpy()
        let sut = HoldingsRepository(remoteDataSource: remote, localDataSource: local)
        
        // When
        let result = try await sut.fetchHoldings()
        
        // Then
        XCTAssertEqual(remote.fetchCallCount, 1)
        XCTAssertEqual(local.saveCallCount, 1)
        XCTAssertEqual(local.savedValue?.count, 2)
        XCTAssertEqual(local.savedValue?.first?.symbol, "AAPL")
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].symbol, "AAPL")
        XCTAssertEqual(result[0].quantity, 2)
        XCTAssertEqual(result[1].symbol, "TSLA")
        XCTAssertEqual(result[1].quantity, 1)
    }
    
    @MainActor
    func test_fetchHoldings_whenRemoteFails_returnsCachedLocal_andDoesNotSave() async throws {
        // Given
        let cached1 = HoldingDTO(symbol: "INFY", quantity: 10, ltp: 78, avgPrice: 1200.0, close: 54)
        let cached2 = HoldingDTO(symbol: "TCS", quantity: 5, ltp: 65, avgPrice: 3500.0, close: 34)
        
        let remote = RemoteMock(mode: .failure(URLError(.timedOut)))
        let local = LocalSpy()
        local.stubbedCache = [cached1, cached2]
        
        let sut = HoldingsRepository(remoteDataSource: remote, localDataSource: local)
        
        // When
        let result = try await sut.fetchHoldings()
        
        // Then
        XCTAssertEqual(remote.fetchCallCount, 1)
        XCTAssertEqual(local.saveCallCount, 0) 
        XCTAssertEqual(local.fetchCallCount, 1)
        
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].symbol, "INFY")
        XCTAssertEqual(result[0].quantity, 10)
        XCTAssertEqual(result[1].symbol, "TCS")
        XCTAssertEqual(result[1].quantity, 5)
    }
    
    @MainActor
    func test_fetchHoldings_whenRemoteFailsAndCacheEmpty_throwsDomainError() async {
        let remote = RemoteMock(mode: .failure(URLError(.notConnectedToInternet)))
        let local = LocalSpy()
        local.stubbedCache = []

        let sut = HoldingsRepository(remoteDataSource: remote, localDataSource: local)

        do {
            _ = try await sut.fetchHoldings()
            XCTFail("Expected to throw")
        } catch let err as HoldingsDomainError {
            XCTAssertEqual(err, .networkUnavailable)
        } catch {
            XCTFail("Expected HoldingsDomainError, got \(error)")
        }

        XCTAssertEqual(remote.fetchCallCount, 1)
        XCTAssertEqual(local.fetchCallCount, 1)
        XCTAssertEqual(local.saveCallCount, 0)
    }
    
    @MainActor
    func test_fetchHoldings_whenRemoteDecodingFails_doesNotFallback_andThrowsDomainDecoding() async {
        // Given
        let remote = RemoteMock(mode: .failure(HoldingsApiError.decodeError(DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "bad")))))
        let local = LocalSpy()
        local.stubbedCache = [HoldingDTO(symbol: "INFY", quantity: 1, ltp: 1, avgPrice: 1, close: 1)] 

        let sut = HoldingsRepository(remoteDataSource: remote, localDataSource: local)

        // When / Then
        do {
            _ = try await sut.fetchHoldings()
            XCTFail("Expected to throw")
        } catch let error as HoldingsDomainError {
            XCTAssertEqual(error, .decoding)
            XCTAssertEqual(local.fetchCallCount, 0)
            XCTAssertEqual(local.saveCallCount, 0)
        } catch {
            XCTFail("Expected HoldingsDomainError.decoding, got: \(error)")
        }
    }
    
    @MainActor
    func test_fetchHoldings_whenRemoteUnauthorized_doesNotFallback_andThrowsDomainUnauthorized() async {
        // Given
        let remote = RemoteMock(mode: .failure(HoldingsApiError.httpStatus(401)))
        let local = LocalSpy()
        local.stubbedCache = [HoldingDTO(symbol: "INFY", quantity: 1, ltp: 1, avgPrice: 1, close: 1)] // should NOT be used

        let sut = HoldingsRepository(remoteDataSource: remote, localDataSource: local)

        // When / Then
        do {
            _ = try await sut.fetchHoldings()
            XCTFail("Expected to throw")
        } catch let error as HoldingsDomainError {
            XCTAssertEqual(error, .unauthorized)
            XCTAssertEqual(local.fetchCallCount, 0)
            XCTAssertEqual(local.saveCallCount, 0)
        } catch {
            XCTFail("Expected HoldingsDomainError.unauthorized, got: \(error)")
        }
    }
    
    @MainActor
    func test_fetchHoldings_whenRemote500_fallsBackToCache_andDoesNotThrow() async throws {
        // Given
        let cached = [
            HoldingDTO(symbol: "INFY", quantity: 10, ltp: 78, avgPrice: 1200, close: 54)
        ]
        let remote = RemoteMock(mode: .failure(HoldingsApiError.httpStatus(500)))
        let local = LocalSpy()
        local.stubbedCache = cached

        let sut = HoldingsRepository(remoteDataSource: remote, localDataSource: local)

        // When
        let result = try await sut.fetchHoldings()

        // Then
        XCTAssertEqual(remote.fetchCallCount, 1)
        XCTAssertEqual(local.fetchCallCount, 1)
        XCTAssertEqual(local.saveCallCount, 0)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].symbol, "INFY")
    }
    
    @MainActor
    func test_fetchHoldings_whenTransportTimeout_fallsBackToCache() async throws {
        // Given
        let cached = [HoldingDTO(symbol: "TCS", quantity: 5, ltp: 65, avgPrice: 3500, close: 34)]
        let remote = RemoteMock(mode: .failure(HoldingsApiError.transport(URLError(.timedOut))))
        let local = LocalSpy()
        local.stubbedCache = cached

        let sut = HoldingsRepository(remoteDataSource: remote, localDataSource: local)

        // When
        let result = try await sut.fetchHoldings()

        // Then
        XCTAssertEqual(local.fetchCallCount, 1)
        XCTAssertEqual(result.first?.symbol, "TCS")
    }
    
    private struct SomeRandomError: Error {}

    @MainActor
    func test_fetchHoldings_whenRemoteUnknownError_doesNotFallback_andThrowsUnknown() async {
        // Given
        let remote = RemoteMock(mode: .failure(SomeRandomError()))
        let local = LocalSpy()
        local.stubbedCache = [HoldingDTO(symbol: "INFY", quantity: 1, ltp: 1, avgPrice: 1, close: 1)] // should not be used
        let sut = HoldingsRepository(remoteDataSource: remote, localDataSource: local)

        // When / Then
        do {
            _ = try await sut.fetchHoldings()
            XCTFail("Expected to throw")
        } catch let error as HoldingsDomainError {
            XCTAssertEqual(error, .unknown)
            XCTAssertEqual(local.fetchCallCount, 0)
        } catch {
            XCTFail("Expected HoldingsDomainError.unknown, got: \(error)")
        }
    }
}
