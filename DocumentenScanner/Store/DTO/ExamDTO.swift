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
}

public struct StudentDTO: Codable {
    public let id: Int
    public let firstname: String
    public let lastname: String
    public let birthday: String
    public let seminarGroup: String
    public let grade: Double
    public let points: Int
}

public struct ExamResultDTO: Codable {
    public let studentId: Int
    public let grade: Double
    public let points: Int
}
