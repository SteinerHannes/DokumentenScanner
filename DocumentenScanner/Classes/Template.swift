//
//  ImageTemplate.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 27.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import VisionKit

struct Template: Identifiable {
    /// The unique id of the template
    public var id: String = UUID().uuidString
    /// The name of the template
    public var name: String = ""
    /// The info text of the template
    public var info: String = ""
    /// The pages of the template/document
    public var pages: [Page] = []

    public var links: [Link] = []

    public var created: String = "" // Date

    public var updated: String = "" // Date

    public var owner: UserInfoDTO?
}

extension Template: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case info = "description"
        case pages
        case created
        case updated
        case owner
        case link = "extra"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let tempIdInt = try container.decode(Int.self, forKey: CodingKeys.id)
        id = String(tempIdInt)
        name = try container.decode(String.self, forKey: CodingKeys.name)
        info = try container.decode(String.self, forKey: CodingKeys.info)
        pages = try container.decode([Page].self, forKey: CodingKeys.pages)
        created = try container.decode(String.self, forKey: CodingKeys.created)
        updated = try container.decode(String.self, forKey: CodingKeys.updated)
        owner = try container.decode(UserInfoDTO.self, forKey: CodingKeys.owner)
        do {
            let linkObject = try container.decode(LinksDTO.self, forKey: CodingKeys.link)
            links = linkObject.links.map({ (link) -> Link in
                return Link(id: link.id,
                            linktype: LinkType(rawValue: link.linktype)!,
                            regionIDs: link.regionIDs)
            })
        } catch {
            links = []
        }
    }
}
