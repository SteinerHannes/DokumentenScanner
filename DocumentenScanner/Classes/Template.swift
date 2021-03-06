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

    public var controlMechanisms: [ControlMechanism] = []

    public var created: String = "" // Date

    public var updated: String = "" // Date

    public var owner: UserInfoDTO?

    public var examId: Int = -1

    public var studentList: [ExamStudentDTO]?
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
        case examId
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let tempIdInt = try container.decode(Int.self, forKey: CodingKeys.id)
        id = String(tempIdInt)
        name = try container.decode(String.self, forKey: CodingKeys.name)
        info = try container.decode(String.self, forKey: CodingKeys.info)
        do {
            pages = try container.decode([Page].self, forKey: CodingKeys.pages)
        } catch {
            pages = []
        }
        do {
            created = try container.decode(String.self, forKey: CodingKeys.created)
        } catch {
            created = ""
        }
        do {
            updated = try container.decode(String.self, forKey: CodingKeys.updated)
        } catch {
            updated = ""
        }
        owner = try container.decode(UserInfoDTO.self, forKey: CodingKeys.owner)
        do {
            let linkObject = try container.decode(LinksDTO.self, forKey: CodingKeys.link)
            controlMechanisms = linkObject.links.map({ (link) -> ControlMechanism in
                return ControlMechanism(id: link.id,
                            controltype: ControlType(rawValue: link.linktype)!,
                            regionIDs: link.regionIDs)
            })
        } catch {
            controlMechanisms = []
        }
        do {
            examId = try container.decode(Int.self, forKey: .examId)
        } catch {
            examId = -1
        }
    }
}
