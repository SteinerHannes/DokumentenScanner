//
//  ImageTemplate.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 27.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import VisionKit

struct ImageTemplate: Identifiable {
    public var id:String = UUID().uuidString
    public var attributeList:[ImageAttribute] = []
    public var image:UIImage?
    public var name:String = "Klausur"
    public var info:String = "Bla bla zusätzliche Infos, die sicher ganz intressant sein könnten, oder uach nicht, wer weiß das schon"
    
//    init(attributeList:[ImageAttribute],image:UIImage) {
//        self.attributeList = attributeList
//        self.image = image
//    }
}
