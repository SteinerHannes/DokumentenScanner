//
//  ExamDTO.swift
//  DokumentenScanner
//
//  Created by Hannes Steiner on 16.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

public struct ExamDTO: Codable {
    public let id: Int
    public let name: String
    public let owner: String
    public let date: String
    public let templateId: Int
}

public struct ExamStudentDTO: Codable, Identifiable {
    public let id: Int
    public let firstname: String
    public let lastname: String
    public let birthday: String
    public let seminarGroup: String
    public let grade: Double?
    public let points: Int?
    public let status: Status
}

public struct ExamResultDTO: Codable {
    public let studentId: Int
    public let grade: Double?
    public let points: Int?
    public let status: Status
}

public enum Status: String, Codable, CaseIterable {
    case Unbekannt,
    Anwesend,
    Bestanden,
    NichtBestanden,
    Unentschuldigt,
    Täuschung,
    Fristablauf,
    Entschuldigt,
    Krank,
    NichtZugelassen

    public static var allCases: [Status] {
        return [.Anwesend, .Bestanden, .Entschuldigt,
                .Fristablauf, .Krank, .NichtBestanden,
                .NichtZugelassen, .Täuschung, .Unbekannt, .Unentschuldigt]
    }
}

extension ExamStudentDTO: Equatable {
    static public func == (lhs: ExamStudentDTO, rhs: ExamStudentDTO) -> Bool {
        return lhs.id == rhs.id // &&
//            lhs.birthday == rhs.birthday &&
//            lhs.firstname == rhs.firstname &&
//            lhs.lastname == rhs.lastname &&
//            lhs.seminarGroup == rhs.seminarGroup &&
//            lhs.status = rhs.status
    }

}
