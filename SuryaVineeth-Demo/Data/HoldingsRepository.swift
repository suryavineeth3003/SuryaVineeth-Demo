//
//  HoldingsRepository.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

import Foundation

final class HoldingsRepository: HoldingsRepositoryProtocol {
    private let remote: HoldingsRemoteDataSourceProtocol
    private let local: HoldingsLocalDataSourceProtocol
    
    init(remoteDataSource: HoldingsRemoteDataSourceProtocol, localDataSource: HoldingsLocalDataSourceProtocol) {
        self.remote = remoteDataSource
        self.local = localDataSource
    }
    
    /// Fetches hodings from remote api. In case remote fails and is eligible for fallback then it getches the cached data and return
    /// - Returns: array of holdings
    func fetchHoldings() async throws -> [Holding] {
        do {
            let dtoList = try await remote.fetchHoldings()
            local.save(dtoList)
            return dtoList.map({Holding(dto: $0)})
        } catch {
            guard shouldFallbackToCache(error) else {
                throw mapToDomainError(error)
            }
            let cached = local.fetchHoldings()
            guard !cached.isEmpty else {
                throw mapToDomainError(error)
            }
            return cached.map(Holding.init(dto:))
        }
    }
}

private extension HoldingsRepository {
    
    /// Determines id fallback to be performs for the error received
    /// - Parameter error: error received
    /// - Returns: true if eligible else false
     func shouldFallbackToCache(_ error: Error) -> Bool {
        switch error {
        case let e as HoldingsApiError:
            switch e {
            case .transport:
                return true
            case .httpStatus(let status):
                return (500...599).contains(status) || status == 429
            case .decodeError(_), .invalidResponse:
                return false
            case .noData:
                return false
            }
        case is URLError:
            return true // if your remote still throws URLError directly
        default:
            return false
        }
    }
    
    /// Maps the data layer error to Domain layer error before passing back to domain
    /// - Parameter error: error received from api
    /// - Returns: mapped Domain error
    func mapToDomainError(_ error: Error) -> HoldingsDomainError {
        // Data-layer → Domain-layer mapping
        if let api = error as? HoldingsApiError {
            switch api {
            case .invalidResponse, .noData:
                return .unknown

            case .decodeError(_):
                return .decoding

            case .httpStatus(let code):
                switch code {
                case 401, 403: return .unauthorized
                case 500...599: return .server
                default: return .unknown
                }

            case .transport(let urlError):
                switch urlError.code {
                case .notConnectedToInternet: return .networkUnavailable
                case .timedOut: return .timeout
                default: return .unknown
                }
            }
        }

        // If some other error leaks here
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet: return .networkUnavailable
            case .timedOut: return .timeout
            default: return .unknown
            }
        }

        return .unknown
    }
}
