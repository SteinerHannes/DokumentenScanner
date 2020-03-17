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

    private static func pages() -> [Page] {
        let page1 = Page(id: 0, image: UIImage(imageLiteralResourceName: "test"))
        let page2 = Page(id: 1, image: UIImage(imageLiteralResourceName: "post"))
        let page3 = Page(id: 2, image: UIImage(imageLiteralResourceName: "klausur1"))
        let page4 = Page(id: 3, image: UIImage(imageLiteralResourceName: "klausur2"))

        var list: [Page] = []
        list.append(page1)
        list.append(page2)
        list.append(page3)
        list.append(page4)

        return list
    }
}
