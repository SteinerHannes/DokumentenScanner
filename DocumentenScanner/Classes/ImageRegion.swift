//
//  ImageRegion.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 26.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI

struct ImageRegion: Identifiable {
    /// The unique id of the region
    public var id: String = UUID().uuidString
    /// The name of the content of the region e.g. "Matrikelnummer"
    public var name: String = ""
    /// The distance from coordinate origin
    public var rectState: CGSize = .zero
    /// The width of the region
    public var width: CGFloat = .zero
    /// The height of the region
    public var height: CGFloat = .zero
    /// The data type of the content of the region
    public var datatype: ResultDatatype = .none
}

extension ImageRegion: Equatable {
    static func == (lhs: ImageRegion, rhs: ImageRegion) -> Bool {
        return
            lhs.id == rhs.id
    }
}
