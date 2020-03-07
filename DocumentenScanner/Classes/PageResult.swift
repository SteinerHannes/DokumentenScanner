//
//  PageRegion.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 02.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import VisionKit

struct PageRegion {
    /// The name of the attribute in that region
    var imageAttributeName: String
    /// The image of the region
    var regionImage: CGImage

    init(imageAttributeName: String, regionImage: CGImage) {
        self.imageAttributeName = imageAttributeName
        self.regionImage = regionImage
    }
}
