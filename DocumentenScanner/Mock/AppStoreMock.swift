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

        let template: Template = realTemplate()
        // set current template
        appState.currentTemplate = template
        // add templte to templates
        appState.teamplates.append(template)
        // set a new template to the test template
        appState.newTemplateState.newTemplate = template
        // set a test image
        appState.newTemplateState.image = UIImage(imageLiteralResourceName: "page1")

//        let image = UIImage(imageLiteralResourceName: "test").cgImage!
//        var test = PageRegion(regionID: "0", regionName: "Note", regionImage: image, datatype: .none)
//        test.confidence = Float.random(in: 0...1)
//        test.textResult = "textasda as d"
//
//        appState.result = [nil, [test, test, test], nil, [test, test, test]]

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

//swiftlint:disable function_body_length
    public static func realTemplate() -> Template {
        let region_1_1 = ImageRegion(id: "6375F9A5-08F9-4B24-8D1E-5B2CB1E96B5E",
                                     name: "Name",
                                     rectState: CGSize(width: 814.2506440972215,
                                                       height: 305.03466666666645),
                                     width: 603.4773333333337,
                                     height: 112.41242187499938,
                                     datatype: ResultDatatype.none)
        let region_1_2 = ImageRegion(id: "97540B70-56DE-4B18-B301-10AE6A32A6C7",
                                     name: "Matrikelnummer",
                                     rectState: CGSize(width: 1000.5924969793698,
                                                       height: 477.1322803674259),
                                     width: 378.7760181519318,
                                     height: 79.46870533709807,
                                     datatype: ResultDatatype.none)
        let region_1_3 = ImageRegion(id: "F449DE5E-9265-4F6E-96C1-71763EC97928",
                                     name: "Seminargruppe",
                                     rectState: CGSize(width: 1023.3227161472214,
                                                       height: 559.3459658892018),
                                     width: 308.0309922900178,
                                     height: 98.91843314670382,
                                     datatype: ResultDatatype.none)
        let region_1_4 = ImageRegion(id: "1B10D0CD-DE0D-4983-B60B-15B0D07D3149",
                                     name: "Punkte zur 1. Aufgabe ",
                                     rectState: CGSize(width: 804.0375270973395,
                                                       height: 928.4354497413003),
                                     width: 61.22519627352801,
                                     height: 73.04980422150925,
                                     datatype: ResultDatatype.none)
        let region_1_5 = ImageRegion(id: "4E514AF3-0AFC-4F86-94BC-6158027C6CD0",
                                     name: "Punkte zur 2. Aufgabe ",
                                     rectState: CGSize(width: 870.0314720945621,
                                                       height: 930.2450186465326),
                                     width: 47.77778116861987,
                                     height: 68.22221883138013,
                                     datatype: ResultDatatype.none)
        let region_1_6 = ImageRegion(id: "34BAA4E4-63B1-48E1-B673-A8A9FCC10D21",
                                     name: "Punkte zur 3. Aufgabe ",
                                     rectState: CGSize(width: 924.4008382599063,
                                                       height: 927.5772328120122),
                                     width: 52.983856186378944,
                                     height: 71.90664595312887,
                                     datatype: ResultDatatype.none)
        let region_1_7 = ImageRegion(id: "45419F6E-4BFC-4C44-B920-B33FE6920B93",
                                     name: "Punkte zur 4. Aufgabe ",
                                     rectState: CGSize(width: 979.1907498491578,
                                                       height: 928.0256172471986),
                                     width: 55.55555216471362,
                                     height: 75.33333333333348,
                                     datatype: ResultDatatype.none)
        let region_1_8 = ImageRegion(id: "907EF51F-F3F3-4E40-9A66-7792B68537F6",
                                     name: "Punkte zur 5. Aufgabe ",
                                     rectState: CGSize(width: 1034.8599500693392,
                                                       height: 929.0150619469048),
                                     width: 55.111114501953125,
                                     height: 71.55555216471362,
                                     datatype: ResultDatatype.none)

        let region_1_9 = ImageRegion(id: "6479F12C-3D37-43FE-AB9B-E93EDEF0C9CC",
                                     name: "Gesamtpunkte",
                                     rectState: CGSize(width: 782.006517235502,
                                                       height: 1023.4812383948176),
                                     width: 120.69132628233888,
                                     height: 110.08664975466263,
                                     datatype: ResultDatatype.none)
        let region_1_10 = ImageRegion(id: "BE88199C-62D7-4AEF-BDBE-7191B975C7FB",
                                     name: "Note",
                                     rectState: CGSize(width: 1139.655133680555,
                                                       height: 1012.0497552083334),
                                     width: 266.2399999999998,
                                     height: 141.9946666666665,
                                     datatype: ResultDatatype.mark)
        let page1 = Page(id: 0,
                         image: UIImage(imageLiteralResourceName: "page1"),
                         regions: [region_1_1, region_1_2, region_1_3, region_1_4, region_1_5,
                                   region_1_6, region_1_7, region_1_8, region_1_9, region_1_10])

        let region_2_1 = ImageRegion(id: "034C939D-900D-4BAF-8983-2D6174464AC6",
                                      name: "Aufgabe 1",
                                      rectState: CGSize(width: 1243.2471398475745,
                                                        height: 315.22542767031405),
                                      width: 88.50157457086652,
                                      height: 61.33240387195747,
                                      datatype: ResultDatatype.none)
        let region_2_2 = ImageRegion(id: "6DA3ADC2-9958-4D4F-BAEA-DF7F638B8AB8",
                                     name: "Aufgabe 2",
                                     rectState: CGSize(width: 1236.0303398822161,
                                                       height: 1084.7944953933525),
                                     width: 86.4433961685545,
                                     height: 51.866045615263374,
                                     datatype: ResultDatatype.none)
        let region_2_3 = ImageRegion(id: "60273F95-3AE8-4226-97B9-7A62A56DC3C2",
                                     name: "Aufgabe 3",
                                     rectState: CGSize(width: 1234.041688512115,
                                                       height: 1707.5851333878702),
                                     width: 84.66666666666674,
                                     height: 58.22221883138013,
                                     datatype: ResultDatatype.none)
        let page2 = Page(id: 1,
                         image: UIImage(imageLiteralResourceName: "page2"),
                         regions: [region_2_1, region_2_2, region_2_3])

        let region_3_1 = ImageRegion(id: "FF52C7A8-01A2-4B48-A6B6-9CAD5AFF2586",
                                     name: "Aufgabe 4",
                                     rectState: CGSize(width: 1267.0932481727805,
                                                       height: 300.45505974683965),
                                     width: 94.02138688568948,
                                     height: 66.19320953358874,
                                     datatype: ResultDatatype.none)
        let region_3_2 = ImageRegion(id: "FF44642E-E064-4598-9741-D6BEDB003F2E",
                                     name: "Aufgabe 5",
                                     rectState: CGSize(width: 1260.4795729948166,
                                                       height: 1665.1411082818177),
                                     width: 97.02481011305326,
                                     height: 57.50555628521079,
                                     datatype: ResultDatatype.none)

        let page3 = Page(id: 2,
                         image: UIImage(imageLiteralResourceName: "page3"),
                         regions: [region_3_1, region_3_2])

        let template = Template(id: "4C1FF6B7-99A1-42E6-A671-0F058C8EFB2B",
                                name: "Klausur",
                                info: "Grundlagen Infromationstechnologie",
                                pages: [page1, page2, page3],
                                links: [])
        return template
    }
}
