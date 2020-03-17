//
//  GlobalRecognitionTextList.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 17.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

public enum ResultDatatype: Int {
    case none = 0
    case mark = 1
    case name = 2
    case studentNumber = 3
    case seminarGroup = 4
    case point = 5
}

public let Marks: [String] = [
    "1,0","1,3","1,7",
    "2,0","2,3","2,7",
    "3,0","3,2","3,7",
    "4,0","4,3","4,7",
    "5,0","5,3","5,7","6,0"
]

public let SeminarGroups: [String] = [
    "IF17wS-B",
    "FMI20"
]
