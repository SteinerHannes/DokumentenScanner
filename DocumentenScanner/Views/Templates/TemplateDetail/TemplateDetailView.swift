//
//  TemplateDetailView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 28.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import Vision

//swiftlint:disable multiple_closures_with_trailing_closure
struct TemplateDetailView: View {
    @EnvironmentObject var store: AppStore

    var template: Template

    var idList: [String: ImageRegion]

    /// It shows wether the text recognition is finished or not
    @State var textRecognitionDidFinish: Bool = false
    /// It shows wether the ScannerView is active or not
    @State private var showCamera: Bool = false
    /// It shows wether the alert is active or not
    @State private var showAlert: Bool = false
    /// Is set when the taken pages != the pages of the template
    @State private var takenPages: Int?

    @State var links: [String: (Int, Int)] = [:]

    init(template: Template) {
        print("init TemplateDetailView")
        self.template = template
        var tempIdList: [String: ImageRegion] = [:]
        for page in self.template.pages {
            for region in page.regions {
                tempIdList[region.id] = region
            }
        }
        self.idList = tempIdList
    }

    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 16) {
                    DocumentInfo(template: template)
                    DocumentPreview(template: template)
                    DocumentResult(template: template)
                    DocumentLink(template: template, links: self.$links, idList: self.idList)
                }
            }
            .resignKeyboardOnDragGesture()
            .navigationBarTitle("\(self.template.name)",
                displayMode: .large)
                .navigationBarItems(trailing: self.newPictureButton())
                .alert(isPresented: self.$showAlert) {
                    //swiftlint:disable line_length
                    Alert(title: Text("Fehler!"), message: Text("Die Anzahl der aufgenommen Seiten (\(self.takenPages!)) stimmt nicht mit der Anzahl der Template Seiten (\(self.template.pages.count)) überein.")
                    )
                    //swiftlint:enable line_length
            }
            if self.showCamera {
                ScannerView(isActive: self.$showCamera, completion: { pages in
                    self.onCompletion(pages: pages)
                }).edgesIgnoringSafeArea(.all)
                    .navigationBarHidden(true)
            }
        }
    }

    fileprivate func newPictureButton() -> some View {
        return Button(action: {
            self.showCamera = true
        }) {
            Image(systemName: "doc.text.viewfinder")
                .font(.body)
            Text("Scannen")
        }
    }

    /**
     The function is triggers after the ScannerView did finish. Here the text recognition takes place.
     The regocnized text will be saved in the correct order
     (ordered like the pages and the regions of the pages).
     */
    fileprivate func onCompletion(pages: [Page]?) {
        self.showCamera = false
        self.textRecognitionDidFinish = false
        guard pages != nil else { return }
        if pages!.count == self.store.states.currentTemplate!.pages.count {
            let array = [[PageRegion]?].init(repeating: nil, count: pages!.count)
            self.store.send(.initResult(array: array))
            for page in pages! {
                self.store.send(.appendResult(at: page.id))
                let imageResults: [PageRegion] = getPageRegions(page: page)
                TextRegionRecognizer(imageResults: imageResults).recognizeText { (pageRegions) in
                    self.store.send(.sendResult(pageNumber: page.id, result: pageRegions))
                    var counter: Int = 0
                    for region in pageRegions {
                        self.links[region.regionID] = (page.id, counter)
                        counter += 1
                    }
                }
            }
        } else {
            self.takenPages = pages!.count
            self.showAlert = true
        }
    }

    /**
     The function returns an array of all calculated page regions from taken picture.
     The template is used as reference.
     */
    fileprivate func getPageRegions(page: Page) -> [PageRegion] {
        var results: [PageRegion] = []
        for region in self.store.states.currentTemplate!.pages[page.id].regions {
            let templateSize = region.rectState
            let width = region.width
            let height = region.height
            let templateRect = CGRect(x: templateSize.width,
                                      y: templateSize.height, width: width, height: height)
            let templateImage = self.store.states.currentTemplate!.pages[page.id]._image
            let image = page._image

            let proportionalRect = newProportionalRect(templateImage: templateImage,
                                                       newImage: image, templateRect: templateRect)

            guard let newImage: CGImage = image.cgImage?.cropping(to: proportionalRect)
                else {
                    continue
            }

            let imageAndId: PageRegion = PageRegion(regionID: region.id,
                                                    regionName: region.name,
                                                    regionImage: newImage,
                                                    datatype: region.datatype)
            results.append(imageAndId)
        }
        return results
    }

    /**
     The function calulates the position of the regions in the taken picture
     corresponding to the template picutre.
     */
    func newProportionalRect(templateImage: UIImage, newImage: UIImage, templateRect: CGRect) -> CGRect {
        let newWidthScale = (((newImage.size.width * 100)/templateImage.size.width) - 100)/100
        let newX = templateRect.origin.x + templateRect.origin.x * newWidthScale
        let newWidth = templateRect.width + templateRect.width * newWidthScale

        let newHeightScale = (((newImage.size.height * 100)/templateImage.size.height) - 100)/100
        let newY = templateRect.origin.y + templateRect.origin.y * newHeightScale
        let newHeight = templateRect.height + templateRect.height * newHeightScale

        let newRect = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        return newRect
    }
}

struct TemplateDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TemplateDetailView(template: AppStoreMock.realTemplate())
                .environmentObject(AppStoreMock.getAppStore())
        }
    }
}
