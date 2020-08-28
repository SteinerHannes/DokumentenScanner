//
//  TemplateDTO.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 02.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

public struct TemplateDTO: Codable {
    public let id: Int
    public let name: String
    public let description: String
    public let created: String // Date
    public let updated: String // Date
    public let owner: UserInfoDTO?
    public let pages: [PageDTO]
    public let extra: LinksDTO
    public let examId: Int
}

public struct TemplateEditDTO: Codable {
    public let name: String
    public let description: String
    public let extra: String
}
