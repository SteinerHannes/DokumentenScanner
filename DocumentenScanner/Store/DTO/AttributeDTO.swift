//
//  AttributeDTO.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 03.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

public struct AttributeDTO: Codable {
    public let name: String
    public let x: Int
    public let y: Int
    public let width: Int
    public let height: Int
    public let dataType: String
    public let created: String //Date
    public let updated: String //Date
}

public struct AttributeCreateDTO: Codable {
    public let name: String
    public let x: Int
    public let y: Int
    public let width: Int
    public let height: Int
    public let dataType: String
    public let pageId: Int
}
