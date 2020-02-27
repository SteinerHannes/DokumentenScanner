//
//  ImageTemplate.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 27.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import VisionKit

struct ImageTemplate {
    public var attributeList:[ImageAttribute]
    public var image:UIImage
    
    init(attributeList:[ImageAttribute],image:UIImage) {
        self.attributeList = attributeList
        self.image = image
    }
}
