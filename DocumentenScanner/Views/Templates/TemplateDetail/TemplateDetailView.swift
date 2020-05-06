//
//  TemplateDetailView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 28.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import Vision
import class Kingfisher.KingfisherManager

private enum ViewAlert: Int, Identifiable {
    case pages = 0
    case pictures = 1

    var id: Int {
        return self.rawValue
    }
}

public enum OCREngine: String {
    case onDevice = "Vision"
    case tesseract = "Tesseract"
}

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
    @State private var alert: ViewAlert?
    /// Is set when the taken pages != the pages of the template
    @State private var takenPages: Int?

    @State var controlMechanims: [String: (Int, Int)] = [:]

    @State private var time: Double = 0.5

    @State private var engine: OCREngine?

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
                    DocumentControl(template: template,
                                    controlMechanisms: self.$controlMechanims,
                                    idList: self.idList)
                }
            }
            .resignKeyboardOnDragGesture()
            .navigationBarTitle("\(self.template.name)",
                displayMode: .large)
            .navigationBarItems(trailing: self.newPictureButton())
            .alert(item: $alert) { alert -> Alert in
                if alert == .pages {
                    //swiftlint:disable line_length
                    return Alert(title: Text("Fehler!"),
                                 message: Text("Die Anzahl der aufgenommen Seiten (\(self.takenPages!)) stimmt nicht mit der Anzahl der Template Seiten (\(self.template.pages.count)) überein.")
                    )
                    //swiftlint:enable line_length
                } else {
                    return Alert(title: Text("Warte, bis alle Bilder des Templates geladen sind."))
                }
            }
            if self.engine != nil {
                ScannerView(isActive: self.$showCamera, completion: { pages in
                    switch self.engine {
                        case .onDevice:
                            self.onCompletionOnDevice(pages: pages)
                        case .tesseract:
                            self.onCompletionTessaract(pages: pages)
                        case nil:
                            break
                    }
                }).edgesIgnoringSafeArea(.all)
                    .navigationBarHidden(true)
            }
        }
        .actionSheet(isPresented: self.$showCamera, content: { () -> ActionSheet in
            ActionSheet(title: Text("Texterkennung Engine"),
                        message: Text("Wähle eine Texterkennung Engine aus."),
                        buttons: [
                .default(Text("Vision (Lokal)"), action: {
                    self.engine = .onDevice
                }),
                .default(Text("Tessaract (Server)"), action: {
                    self.engine = .tesseract
                }),
                .cancel()
            ])
        })
        .onAppear {
            DispatchQueue.main.async {
                self.loadCachedImages()
            }
        }
    }

    fileprivate func loadCachedImages() {
        var again: Bool = false
        for (index, page) in self.template.pages.indexed() where page._image == nil {
            print("loadCachedImages")
            let key = baseAuthority + page.url
            guard let image =
                KingfisherManager.shared.cache.retrieveImageInMemoryCache(forKey: key) else {
                    again = true
                    continue
            }
            self.store.send(.setImage(page: index, image: image))
        }
        if again == true {
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                self.time += 1
                self.loadCachedImages()
            }
        }
    }

    fileprivate func newPictureButton() -> some View {
        return Button(action: {
            for page in self.store.states.currentTemplate!.pages where page._image == nil {
                self.alert = .pictures
                return
            }
            self.showCamera = true
        }) {
            Image(systemName: "doc.text.viewfinder")
                .font(.body)
            Text("Scannen")
        }
    }

    /**
     The function is triggers after the ScannerView did finish and the on device engine is selected.
     Here the text recognition takes place.
     The regocnized text will be saved in the correct order
     (ordered like the pages and the regions of the pages).
     */
    fileprivate func onCompletionOnDevice(pages: [Page]?) {
        self.engine = nil
        self.textRecognitionDidFinish = false
        guard let pages = pages else { return }
        if pages.count == self.store.states.currentTemplate!.pages.count {
            let array = [[PageRegion]?].init(repeating: nil, count: pages.count)
            self.store.send(.ocr(action: .initResult(array: array)))
            for page in pages {
                self.store.send(.ocr(action: .appendResult(at: page.number)))
                let imageResults: [PageRegion] = getPageRegions(page: page)
                TextRegionRecognizer(imageResults: imageResults).recognizeText { (pageRegions) in
                    self.store.send(.ocr(action: .sendResult(pageNumber: page.number, result: pageRegions)))
                    var counter: Int = 0
                    for region in pageRegions {
                        self.controlMechanims[region.regionID] = (page.number, counter)
                        counter += 1
                    }
                }
            }
        } else {
            self.takenPages = pages.count
            self.alert = .pages
        }
    }

    /**
     The function is triggers after the ScannerView did finish and the engine tessaract is selected
     The regocnized text will be saved in the correct order
     (ordered like the pages and the regions of the pages).
     */
    fileprivate func onCompletionTessaract(pages: [Page]?) {
        guard let engine = self.engine else {
            return
        }
        self.engine = nil
        self.textRecognitionDidFinish = false
        guard var pages = pages else { return }
        if pages.count == self.store.states.currentTemplate!.pages.count {
            for index in 0..<pages.count {
                pages[index].id = self.template.pages[index].id
                self.store.send(
                    .ocr(action: .ocrTesseract(page: pages[index], engine: engine)))
            }

//            let array = [[PageRegion]?].init(repeating: nil, count: pages!.count)
//            self.store.send(.ocr(action: .initResult(array: array)))
//            for page in pages! {
//                self.store.send(.ocr(action: .appendResult(at: page.id)))
//                let imageResults: [PageRegion] = getPageRegions(page: page)
//                TextRegionRecognizer(imageResults: imageResults).recognizeText { (pageRegions) in
//                    self.store.send(.ocr(action: .sendResult(pageNumber: page.id, result: pageRegions)))
//                    var counter: Int = 0
//                    for region in pageRegions {
//                        self.controlMechanisms[region.regionID] = (page.id, counter)
//                        counter += 1
//                    }
//                }
//            }
        } else {
            self.takenPages = pages.count
            self.alert = .pages
        }
    }

    /**
     The function returns an array of all calculated page regions from taken picture.
     The template is used as reference.
     */
    fileprivate func getPageRegions(page: Page) -> [PageRegion] {
        var results: [PageRegion] = []
        for region in self.store.states.currentTemplate!.pages[page.number].regions {
            let templateSize = region.rectState
            let width = region.width
            let height = region.height
            let templateRect = CGRect(x: templateSize.width,
                                      y: templateSize.height, width: width, height: height)
            let templateImage = self.store.states.currentTemplate!.pages[page.number]._image
            let image = page._image

            let proportionalRect = newProportionalRect(templateImage: templateImage!,
                                                       newImage: image!, templateRect: templateRect)

            guard let newImage: CGImage = image!.cgImage?.cropping(to: proportionalRect)
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

//struct PageRegion {
//    /// The unique id of the attribute in that region
//    public var regionID: String
//    /// The image of the region
//    public var regionImage: CGImage?
//    /// The data type of the content of the region
//    public var datatype: ResultDatatype
//    ///
//    public var textResult: String = ""
//    ///
//    public var confidence: VNConfidence = 0.0
//
//    public var regionName: String
//
//    init(regionID: String, regionName: String, regionImage: CGImage, datatype: ResultDatatype) {
//        self.regionName = regionName
//        self.regionID = regionID
//        self.regionImage = regionImage
//        self.datatype = datatype
//    }
//}
//
//extension PageRegion: Hashable {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(regionID)
//    }
//}
