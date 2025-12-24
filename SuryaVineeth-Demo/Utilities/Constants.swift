//
//  Constants.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 22/12/25.
//

import Foundation

enum PortfolioTab: String, CaseIterable {
    case positions
    case holdings
    
    var title: String {
        switch self {
        case .positions:
            return NSLocalizedString("POSITIONS", comment: "Positions")
        case .holdings:
            return NSLocalizedString("HOLDINGS", comment: "Holdings")
        }
    }
}


enum SummaryRowType: String, CaseIterable {
    case investedValue
    case currentValue
    case todayPL
    case totalPL
    
    var title: String {
        switch self {
        case .investedValue:
            return NSLocalizedString("Total investment﹡", comment: "Total investment")
        case .currentValue:
            return NSLocalizedString("Current value﹡", comment: "Current value")
        case .todayPL:
            return NSLocalizedString("Today's Profit & Loss﹡", comment: "Today's Profit & Loss")
        case .totalPL:
            return NSLocalizedString("Profit & Loss﹡", comment: "Profit & Loss")
        }
    }
}

enum HoldingItemKeyType: String, CaseIterable {
    case ltp
    case quantity
    case pnl
    
    var title: String {
        switch self {
        case .ltp:
            return NSLocalizedString("LTP:", comment: "LTP:")
        case .quantity:
            return NSLocalizedString("NET QTY:", comment: "NET QTY:")
        case .pnl:
            return NSLocalizedString("P&L:", comment: "P&L:")
        }
    }
    
}

enum API: String {
    case positions
    case holdings
    
    var endpointUrl: URL? {
        switch self {
        case .holdings:
            return URL(string: "https://35dee773a9ec441e9f38d5fc249406ce.api.mockbin.io/")
        default:
            return nil
        }
    }
}

enum DisplayableErrorType {
    case networkUnavailable
    case timeout
    case unauthorized
    case server
    case decoding
    case generic
    
    var message: String {
        switch self {
        case .networkUnavailable:
            return NSLocalizedString("No internet connection.", comment: "No internet connection.")
        case .timeout:
            return NSLocalizedString( "Request timed out. Please try again.", comment: "Request timed out. Please try again.")
        case .unauthorized:
            return NSLocalizedString( "Session expired !!. Please login again.", comment: "Session expired !!. Please login again.")
        case .server:
            return NSLocalizedString("Server error. Try again later.", comment: "Server error. Try again later.")
        case .decoding:
            return NSLocalizedString("Unexpected response from server.", comment: "Unexpected response from server.")
        case .generic:
            return NSLocalizedString("Something went wrong.", comment: "Something went wrong.")
        
        }
    }
}

enum AlertMessage: String {
    case profileClick
    case SearchClick
    case sortClick
    case failedToFetchHolding
    case alertActionTitle
    
    var text: String {
        switch self {
        case .profileClick:
            return NSLocalizedString("Profile coming soon...", comment: "Profile")
        case .SearchClick:
            return NSLocalizedString("Search coming soon...", comment: "Search")
        case .sortClick:
            return NSLocalizedString("Sort coming soon...", comment: "Sort")
        case .failedToFetchHolding:
            return NSLocalizedString("Unable to load Holdings.", comment: "Unable to load Holdings.")
        case .alertActionTitle:
            return NSLocalizedString("Retry", comment: "Retry")
        }
    }
}


enum NavigationTitle: String {
    case portfolio
    
    var title: String {
        switch self {
        case .portfolio:
            return NSLocalizedString("Portfolio", comment: "Portfolio")
        }
    }
}

