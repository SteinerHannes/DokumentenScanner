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
    public var name: String = "Klausur"
    /// The info text of the template
    public var info: String = "Bla bla zusätzliche Infos, die sicher ganz intressant sein könnten, oder uach nicht, wer weiß das schon"
    /// The pages of the template/document
    public var pages: [Page] = []
}
