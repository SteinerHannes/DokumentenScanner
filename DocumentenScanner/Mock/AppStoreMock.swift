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
    /// Returns an app store mock, with all important things
    public static func getAppStore() -> AppStore {
        var appState = AppStates()

        let template: Template = getTemplate()
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

    public static func getTemplate() -> Template {
        // create pages
        let pages: [Page] = self.pages()
        // create templte with the pages

        //swiftlint:disable line_length
        return Template(name: "Klausur", info: "Am Ende der Woche konnte man in der App Vorlagen mit einer Seite erstellen. Das heißt man konnte ein Foto machen, aus welchem das Dokument rausgeschnitten und anschließend ausgerichtet wurde. Weiter war es möglich Regionen auf dem Dokument zu markieren und diese in der Vorlage abspeichern. Ansonsten konnten die Vorlage schon dazu benutzt werden, um die Regionen auf dem neuen Foto heraus zu schneiden.", pages: pages)
        //swiftlint:ensable line_length
    }

    /// Creates mock ImageRegions
    private static func regions1() -> [ImageRegion] {
        let region1 = ImageRegion(name: "Note", rectState: CGSize(width: 10, height: 10),
                                  width: 50, height: 100, datatype: .mark)
        let region2 = ImageRegion(name: "Seminargruppe", rectState: CGSize(width: 10, height: 10),
                                  width: 50, height: 100, datatype: .seminarGroup)
        let region3 = ImageRegion(name: "Matrikelnummer", rectState: CGSize(width: 10, height: 10),
                                  width: 50, height: 100, datatype: .studentNumber)
        return [region1, region2, region3]
    }

    /// Creates mock ImageRegions
    private static func regions2() -> [ImageRegion] {
        let region1 = ImageRegion(name: "Test", rectState: CGSize(width: 10, height: 10),
                                  width: 50, height: 100, datatype: .mark)
        let region2 = ImageRegion(name: "Bla", rectState: CGSize(width: 10, height: 10),
                                  width: 50, height: 100, datatype: .seminarGroup)
        let region3 = ImageRegion(name: "Naja", rectState: CGSize(width: 10, height: 10),
                                  width: 50, height: 100, datatype: .studentNumber)
        return [region1, region2, region3]
    }

    /// Creates mock Pages
    private static func pages() -> [Page] {
        let page1 = Page(id: 0, image: UIImage(imageLiteralResourceName: "test"), regions: regions1())
        let page2 = Page(id: 1, image: UIImage(imageLiteralResourceName: "post"), regions: regions2())
        let page3 = Page(id: 2, image: UIImage(imageLiteralResourceName: "klausur1"), regions: regions1())
        let page4 = Page(id: 3, image: UIImage(imageLiteralResourceName: "klausur2"), regions: regions2())
        return [page1, page2, page3, page4]
    }
}
