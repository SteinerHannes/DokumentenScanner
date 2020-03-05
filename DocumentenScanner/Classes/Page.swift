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
    public var id: Int
    /// The image of the page
    public var image: UIImage
    /// The regions on the image where text recognition takes place
    public var regions: [ImageRegion] = []
}
