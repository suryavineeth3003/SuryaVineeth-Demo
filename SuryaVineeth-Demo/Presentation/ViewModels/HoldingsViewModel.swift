//
//  HoldingsViewModel.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

import Foundation

class HoldingsViewModel {
    
    var onHoldingsUpdated: (() -> Void)?
    var onSummaryUpdated: ((SummaryViewModel) -> Void)?
    var onError: ((String) -> Void)?
    
    private var holdings: [Holding] = []
    private var summaryModel: SummaryModel?
    private var isSummaryExpanded = false
    
    private let formatter: CurrencyFormatter
    private let usecase: FetchHoldingsUsecaseProtocol
    
    init( formatter: CurrencyFormatter, usecase: FetchHoldingsUsecaseProtocol) {
        self.formatter = formatter
        self.usecase = usecase
    }
    
    
    /// Fetches the holdings from the repository
    func loadHoldings() {
        Task {
            do {
                let holdings = try await self.usecase.execute()
                await MainActor.run {
                    self.holdings = holdings
                    self.onHoldingsUpdated?()
                    self.summaryModel = SummaryModel(holdings: holdings)
                    self.updateSummary()
                }
            } catch {
                await MainActor.run {
                    self.onError?(self.message(for: error))
                }
            }
        }
    }
    
    private func updateSummary() {
        guard let summaryModel else {return}
        let vm = SummaryViewModel(
            summary: summaryModel,
            formatter: formatter,
            isExpanded: isSummaryExpanded)
        onSummaryUpdated?(vm)
    }
    
    /// Maps the error to its respective error message to display in the UI
    /// - Parameter error: error received
    /// - Returns: Displayable message
    private func message(for error: Error) -> String {
        switch error as? HoldingsDomainError {
        case .networkUnavailable: return DisplayableErrorType.networkUnavailable.message
        case .timeout: return DisplayableErrorType.timeout.message
        case .unauthorized: return DisplayableErrorType.unauthorized.message
        case .server: return DisplayableErrorType.server.message
        case .decoding: return DisplayableErrorType.decoding.message
        default: return DisplayableErrorType.generic.message
        }
    }
    
    func toggleSummary() {
        isSummaryExpanded.toggle()
        updateSummary()
    }
    
    func numberOfHoldings() -> Int {
        holdings.count
    }
    
    func cellViewModel(for index: Int) -> HoldingCellViewModel {
        HoldingCellViewModel(holding: holdings[index], formatter: formatter)
    }
    
}
