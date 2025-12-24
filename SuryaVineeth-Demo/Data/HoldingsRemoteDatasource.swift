//
//  HoldingsRemoteDatasource.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

import Foundation

enum HoldingsApiError: Error, Equatable {
    case invalidResponse
    case httpStatus(Int)
    case decodeError(Error)
    case noData
    case transport(URLError)

    static func == (lhs: HoldingsApiError, rhs: HoldingsApiError) -> Bool {
        switch (lhs, rhs) {
        case (.decodeError, .decodeError):
            return true
        case let (.httpStatus(a), .httpStatus(b)):
            return a == b
        case (.noData, .noData), (.invalidResponse, .invalidResponse):
            return true
        case let (.transport(a), .transport(b)):
            return a.code == b.code
        default:
            return false
        }
    }
}

final class HoldingsRemoteDatasource: HoldingsRemoteDataSourceProtocol {
    private let url: URL
    private let session: URLSession
    
    init(url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }
    
    /// Fetches holdings from remote api
    /// - Returns: array of holdings
    func fetchHoldings() async throws -> [HoldingDTO] {
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw HoldingsApiError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw HoldingsApiError.httpStatus(httpResponse.statusCode)
            }
            
            guard !data.isEmpty else {
                throw HoldingsApiError.noData
            }
            
            do {
                let decoded = try JSONDecoder().decode(HoldingsResponse.self, from: data)
                return decoded.data.userHolding
            } catch {
                throw HoldingsApiError.decodeError(error)
            }
        } catch let urlError as URLError {
            throw HoldingsApiError.transport(urlError)
        }
    }
}
