//
//  ModelMapper.swift
//  SuryaVineeth-Demo
//
//  Created by Surya Vineeth on 23/12/25.
//

import Foundation

extension Holding {
    init(dto: HoldingDTO) {
        self.symbol = dto.symbol
        self.quantity = dto.quantity
        self.ltp = dto.ltp
        self.avgPrice = dto.avgPrice
        self.close = dto.close
    }
}
