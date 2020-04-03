//
//  PageDTO.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 02.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

public struct PageDTO: Codable {
    public let id: Int
    public let number: Int
    public let imagePath: String
    public let imageHash: String
    public let created: String //Date
    public let updated: String //Date
    public let attributes: [AttributeDTO]
}

public struct PageCreateDTO: Codable {
    /// template id
    public let templateID: Int
    public let number: Int
    public let imagePath: String
}
