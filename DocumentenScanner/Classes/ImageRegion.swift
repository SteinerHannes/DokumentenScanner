//
//  ImageRegion.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 26.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI

struct ImageRegion: Identifiable {
    /// The unique id of the region
    public var id: String = UUID().uuidString
    /// The name of the content of the region e.g. "Matrikelnummer"
    public var name: String = ""
    /// The distance from coordinate origin
    public var rectState: CGSize = .zero
    /// The width of the region
    public var width: CGFloat = .zero
    /// The height of the region
    public var height: CGFloat = .zero
    /// The data type of the content of the region
    public var datatype: ResultDatatype = .none
}

extension ImageRegion: Equatable {
    static func == (lhs: ImageRegion, rhs: ImageRegion) -> Bool {
        return
            lhs.id == rhs.id
    }
}

extension ImageRegion: Decodable {
    enum CodingKeys: String, CodingKey {
        case name
        case x
        case y
        case width
        case height
        case datatype = "dataType"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: CodingKeys.name)
        let x = try container.decode(Int.self, forKey: CodingKeys.x)
        let y = try container.decode(Int.self, forKey: CodingKeys.y)
        rectState = CGSize(width: x, height: y)
        let tempWidth = try container.decode(Int.self, forKey: CodingKeys.width)
        width = CGFloat(tempWidth)
        let tempHeight = try container.decode(Int.self, forKey: CodingKeys.height)
        height = CGFloat(tempHeight)
        let datatypeString = try container.decode(String.self, forKey: CodingKeys.datatype)
        switch datatypeString {
            case "Unknown":
                datatype = .none
            case "Grade":
                datatype = .mark
            case "FirstName", "LastName":
                datatype = .name
            case "StudentId":
                datatype = .studentNumber
            case "SeminarGroup":
                datatype = .seminarGroup
            case "Points":
                datatype = .point
            default:
                datatype = .none
        }

    }
}
