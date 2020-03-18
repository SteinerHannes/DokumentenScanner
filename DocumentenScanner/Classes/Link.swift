//
//  Link.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 18.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

struct Link: Identifiable {
    var id: String = UUID().uuidString
    var linktype: LinkType
    var regionIDs: [String] = []
}

enum LinkType: Int {
    case compare = 0
    case sum = 1
}
