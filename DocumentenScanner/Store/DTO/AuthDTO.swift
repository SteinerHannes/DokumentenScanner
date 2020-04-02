//
//  AuthDTO.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 30.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

public struct LoginDTO: Codable {
    public let email: String
    public let password: String
}

public struct RegisterDTO: Codable {
    public let email: String
    public let username: String
    public let password: String
}
