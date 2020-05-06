//
//  ControlMechanism.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 18.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

public struct LinksDTO: Codable {
    public let links: [LinkDTO]
}

public struct LinkDTO: Codable {
    public let id: String
    public let linktype: Int
    public let regionIDs: [String]
}

struct ControlMechanism: Identifiable {
    var id: String = UUID().uuidString
    var controltype: ControlType
    var regionIDs: [String] = []

    var linktypeName: String {
        switch self.linktype {
            case .compare:
                return "Vergleich"
            case .sum:
                return "Summieren und Vergleichen"
        }
    }
}

enum ControlType: Int {
    case compare = 0
    case sum = 1
}

extension ControlMechanism: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case linktype
        case regionIDs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: CodingKeys.id)
        let linktypeInt = try container.decode(Int.self, forKey: CodingKeys.linktype)
        switch linktypeInt {
            case 0:
                linktype = .compare
            case 1:
                linktype = .sum
            default:
                linktype = .compare
        }
        regionIDs = try container.decode([String].self, forKey: CodingKeys.regionIDs)
    }
}
