//
//  Page.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 05.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import VisionKit

struct Page: Identifiable {
    /// The unique id of the page (page number)
    public let id: Int
    /// The image of the page
    public var _image: UIImage = UIImage(imageLiteralResourceName: "page1")
    /// The regions on the image where text recognition takes place
    public var regions: [ImageRegion] = []

    public var url: String = ""

    public var imageHash: String = ""

    public var created: String = "" //Date

    public var updated: String = "" //Date
}

extension Page: Decodable {
    enum CodingKeys: String, CodingKey {
        case id = "number"
        case regions = "attributes"
        case url = "imagePath"
        case imageHash
        case created
        case updated
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: CodingKeys.id)
        regions = try container.decode([ImageRegion].self, forKey: CodingKeys.regions)
        url = try container.decode(String.self, forKey: CodingKeys.url)
        imageHash = try container.decode(String.self, forKey: CodingKeys.imageHash)
        created = try container.decode(String.self, forKey: CodingKeys.created)
        updated = try container.decode(String.self, forKey: CodingKeys.updated)
    }
}
