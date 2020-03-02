//
//  ImageAttribute.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 26.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI

struct ImageAttribute: Identifiable {
    
    var id: String = UUID().uuidString
    var name: String = ""
    var rectState: CGSize = .zero
    var width: CGFloat = .zero
    var height: CGFloat = .zero
    var datatype: Int = 0
}
