//
//  HoldingsDomainError.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 25/12/25.
//

import Foundation
enum HoldingsDomainError: Error {
    case networkUnavailable
    case timeout
    case unauthorized
    case server
    case decoding
    case unknown
}
