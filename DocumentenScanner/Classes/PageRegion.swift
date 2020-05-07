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

    init(regionID: String, regionName: String, regionImage: CGImage?, datatype: ResultDatatype) {
        self.regionName = regionName
        self.regionID = regionID
        self.regionImage = regionImage
        self.datatype = datatype
    }

    init(regionID: String, regionName: String,
         datatype: ResultDatatype, textResult: String, confidence: Float) {
        self.regionName = regionID
        self.regionID = regionName
        self.textResult = textResult
        self.confidence = confidence
        self.datatype = .none
    }

    init() {
        self.regionName = ""
        self.regionID = ""
        self.textResult = ""
        self.confidence = 0.0
        self.datatype = .none
    }
}

extension PageRegion: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(regionID)
    }
}
