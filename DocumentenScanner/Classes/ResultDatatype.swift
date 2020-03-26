//
//  ResultDatatype.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 17.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

public enum ResultDatatype: Int {
    case none = 0
    case mark = 1
    case name = 2
    case studentNumber = 3
    case seminarGroup = 4
    case point = 5

    func getName() -> String {
        switch self {
            case .none:
                return "Unbekannt"
            case .mark:
                return "Note"
            case .name:
                return "Name"
            case .studentNumber:
                return "Matrikelnummer"
            case .seminarGroup:
                return "Seminargruppe"
            case .point:
                return "Punkte"
        }
    }
}
