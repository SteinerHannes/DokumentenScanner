//
//  MockData.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 05.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI
import VisionKit

class MockData {
    public func appStatePagesMock() -> AppState {
        let appState = AppState()
        let page1 = Page(id: 0, image: UIImage(imageLiteralResourceName: "test"))
        let page2 = Page(id: 1, image: UIImage(imageLiteralResourceName: "post"))
        let page3 = Page(id: 2, image: UIImage(imageLiteralResourceName: "klausur1"))
        let page4 = Page(id: 3, image: UIImage(imageLiteralResourceName: "klausur2"))
        
        appState.currentTemplate! = Template(id: "0", name: "Klausur", info: "Infotext", pages: [page1, page2, page3, page4])
        return appState
    }
}
