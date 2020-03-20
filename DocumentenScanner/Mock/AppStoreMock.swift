//
//  AppStoreMock.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 17.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI

class AppStoreMock {
    static func getAppStore() -> AppStore {
        var appState = AppStates()

        // create pages
        let pages: [Page] = self.pages()
        // create templte with the pages
        let template = Template(name: "Klausur", info: "Infotext", pages: pages)
        // set current template
        appState.currentTemplate = template
        // add templte to templates
        appState.teamplates.append(template)
        // set a new template to the test template
        appState.newTemplateState.newTemplate = template
        // set a test image
        appState.newTemplateState.image = UIImage(imageLiteralResourceName: "test")

        let store = AppStore(initialState: appState, reducer: appReducer, environment: AppEnviorment())
        return store
    }

    private static func regions1() -> [ImageRegion] {
        let region1 = ImageRegion(name: "Note", rectState: CGSize(width: 10, height: 10),
                                  width: 50, height: 100, datatype: .mark)
        let region2 = ImageRegion(name: "Seminargruppe", rectState: CGSize(width: 10, height: 10),
                                  width: 50, height: 100, datatype: .seminarGroup)
        let region3 = ImageRegion(name: "Matrikelnummer", rectState: CGSize(width: 10, height: 10),
                                  width: 50, height: 100, datatype: .studentNumber)
        return [region1, region2, region3]
    }

    private static func regions2() -> [ImageRegion] {
        let region1 = ImageRegion(name: "Test", rectState: CGSize(width: 10, height: 10),
                                  width: 50, height: 100, datatype: .mark)
        let region2 = ImageRegion(name: "Bla", rectState: CGSize(width: 10, height: 10),
                                  width: 50, height: 100, datatype: .seminarGroup)
        let region3 = ImageRegion(name: "Naja", rectState: CGSize(width: 10, height: 10),
                                  width: 50, height: 100, datatype: .studentNumber)
        return [region1, region2, region3]
    }

    private static func pages() -> [Page] {
        let page1 = Page(id: 0, image: UIImage(imageLiteralResourceName: "test"), regions: regions1())
        let page2 = Page(id: 1, image: UIImage(imageLiteralResourceName: "post"), regions: regions2())
        let page3 = Page(id: 2, image: UIImage(imageLiteralResourceName: "klausur1"), regions: regions1())
        let page4 = Page(id: 3, image: UIImage(imageLiteralResourceName: "klausur2"), regions: regions2())
        return [page1, page2, page3, page4]
    }
}
