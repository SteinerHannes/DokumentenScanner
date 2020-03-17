//
//  LinkedPageRegions.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 17.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

enum RegionActionType {
    case compare
    case sum
}
//swiftlint:disable switch_case_alignment
class LinkedPageRegions {
    private let type: RegionActionType

    init(from type: RegionActionType) {
        self.type = type
    }

    private var regions: [String] = []

    func setRegionsFor(ids list: [String]) {
        self.regions = list
    }

    func evaluateRegions() -> Bool {
        switch self.type {
            case .compare:
                return regions[0] == regions[1]
            case .sum:
                var sum: Double = 0.0
                for index in 0..<regions.count-1 {
                    sum += Double(regions[index]) ?? 0
                }
                return sum == Double(regions.last!) ?? 0
        }
    }
}
