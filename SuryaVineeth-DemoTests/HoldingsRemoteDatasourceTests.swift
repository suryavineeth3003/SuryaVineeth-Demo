//
//  HoldingsRemoteDatasourceTests.swift
//  SuryaVineeth-DemoTests
//
//  Created by Surya Vineeth on 23/12/25.
//

import XCTest
@testable import SuryaVineeth_Demo


final class MockURLProtocol: URLProtocol {

    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    static var error: Error?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let error = Self.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        guard let handler = Self.requestHandler else {
            fatalError("MockURLProtocol.requestHandler not set")
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() { }
}

final class HoldingsRemoteDatasourceTests: XCTestCase {

    private var session: URLSession!
    private var sut: HoldingsRemoteDatasource!
    private var url: URL!

    override func setUp() {
        super.setUp()

        url = URL(string: "https://example.com/holdings")!

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)

        sut = HoldingsRemoteDatasource(url: url, session: session)

        // Reset mock state
        MockURLProtocol.requestHandler = nil
        MockURLProtocol.error = nil
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        MockURLProtocol.error = nil
        sut = nil
        session = nil
        url = nil
        super.tearDown()
    }

    @MainActor
    func test_fetchHoldings_when200AndValidJSON_returnsHoldings() async throws {
        // Given
        let json = """
        {
          "data": {
            "userHolding": [
              { "symbol": "AAPL", "quantity": 2, "ltp": 38.05, "avgPrice": 150.0, "close": 40 },
              { "symbol": "TSLA", "quantity": 1, "ltp": 38.05, "avgPrice": 700.0, "close": 40}
            ]
          }
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.url, self.url)

            let response = HTTPURLResponse(
                url: self.url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, json)
        }

        // When
        let result = try await sut.fetchHoldings()

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].symbol, "AAPL")
        XCTAssertEqual(result[0].quantity, 2)
        XCTAssertEqual(result[0].avgPrice, 150.0)

        XCTAssertEqual(result[1].symbol, "TSLA")
        XCTAssertEqual(result[1].quantity, 1)
        XCTAssertEqual(result[1].avgPrice, 700.0)
    }

    func test_fetchHoldings_whenNon200_throwsBadServerResponse() async {
        // Given
        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: self.url,
                statusCode: 500,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, Data())
        }

        // When / Then
        do {
            _ = try await sut.fetchHoldings()
            XCTFail("Expected to throw, but succeeded")
        } catch let error as HoldingsApiError {
            guard case .httpStatus(let code) = error else {
                return XCTFail("Expected .httpStatus, got: \(error)")
            }
            XCTAssertEqual(code, 500)
        } catch {
            XCTFail("Expected 500 error, got: \(error)")
        }
    }

    func test_fetchHoldings_when200ButInvalidJSON_throwsDecodingError() async {
        let invalidJSON = """
        { "oops": true }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { _ in
            let response = HTTPURLResponse(
                url: self.url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            return (response, invalidJSON)
        }

        // When / Then
        do {
            _ = try await sut.fetchHoldings()
            XCTFail("Expected decoding error, but succeeded")
        } catch let error as HoldingsApiError {
            XCTAssertEqual(error, .decodeError(error))
        } catch {
            XCTFail("Expected DecodingError, got: \(error)")
        }
    }

    func test_fetchHoldings_whenNetworkFails_throwsUnderlyingError() async {
        // Given
        let expected = URLError(.notConnectedToInternet)
        MockURLProtocol.error = expected

        // When / Then
        do {
            _ = try await sut.fetchHoldings()
            XCTFail("Expected to throw, but succeeded")
        } catch let error as HoldingsApiError {
            guard case .transport(let underlying) = error else {
                return XCTFail("Expected .transport, got: \(error)")
            }
            XCTAssertEqual(underlying.code, expected.code)
        } catch {
            XCTFail("Expected URLError, got: \(error)")
        }
    }
}
