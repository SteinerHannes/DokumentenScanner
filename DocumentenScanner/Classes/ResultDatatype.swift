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
    case firstname = 2
    case lastname = 3
    case studentNumber = 4
    case seminarGroup = 5
    case point = 6

    func getName() -> String {
        switch self {
            case .none:
                return "Unbekannt"
            case .mark:
                return "Note"
            case .firstname:
                return "Vorname"
            case .lastname:
                return "Nachname"
            case .studentNumber:
                return "Matrikelnummer"
            case .seminarGroup:
                return "Seminargruppe"
            case .point:
                return "Punkte"
        }
    }

    func getNameType() -> String {
        switch self {
            case .none:
                return "Unknown"
            case .mark:
                return "Grade"
            case .firstname:
                return "FirstName"
            case .lastname:
                return "LastName"
            case .studentNumber:
                return "StudentId"
            case .seminarGroup:
                return "SeminarGroup"
            case .point:
                return "Points"
        }
    }
}
