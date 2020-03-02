//
//  ImageResult.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 02.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import VisionKit

struct ImageResult {
    var imageAttributeName: String
    var regionImage: CGImage
    var rocognizedTest: String = ""
    var error: Int = 1
    
    init(imageAttributeName: String, regionImage: CGImage) {
        self.imageAttributeName = imageAttributeName
        self.regionImage = regionImage
    }
}
