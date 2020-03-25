//
//  PageRegion.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 02.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import VisionKit
import Vision

struct PageRegion {
    /// The unique id of the attribute in that region
    public var regionID: String
    /// The image of the region
    public var regionImage: CGImage?
    /// The data type of the content of the region
    public var datatype: ResultDatatype
    ///
    public var textResult: String = ""
    ///
    public var confidence: VNConfidence = 0.0

    public var regionName: String

    init(regionID: String, regionName: String, regionImage: CGImage, datatype: ResultDatatype) {
        self.regionName = regionName
        self.regionID = regionID
        self.regionImage = regionImage
        self.datatype = datatype
    }
}

extension PageRegion : Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(regionID)
    }
}
