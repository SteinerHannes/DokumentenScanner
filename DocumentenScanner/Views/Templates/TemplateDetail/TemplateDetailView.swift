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

    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>

    var template: Template

    var idList: [String: ImageRegion]

    /// It shows wether the text recognition is finished or not
    @State var textRecognitionDidFinish: Bool = false
    /// It shows wether the ScannerViewAlert is active or not
    @State private var showCamera: Bool = false
    /// It shows wether the alert is active or not
    @State private var alert: ViewAlert?
    /// Is set when the taken pages != the pages of the template
    @State private var takenPages: Int?

    @State var controlMechanims: [String: (Int, Int)] = [:]

    @State private var time: Double = 0.5

    @State private var engine: OCREngine?

    @State private var edit: Bool = false

    @State private var delete: Bool = false

    private var hideNavigationBar: Bool {
        return self.engine != nil && self.showCamera
    }

    private var bottomPadding: CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0.0
        }
        return 0.0
    }

    private var disableSaveButton: Bool {
        if self.store.states.ocrState.result.count == self.template.pages.count {
            var results: Int = 0
            var temp: Int = 0
            for res in self.store.states.ocrState.result {
                guard let count = res?.count else {
                    return false
                }
                results += count
            }
            for page in self.template.pages {
                temp += page.regions.count
            }
            if temp == results {
                return true
            }
        }
        return false
    }

    init(template: Template) {
        //print("init TemplateDetailView")
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
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 16) {
                    DocumentInfo(template: template)
                    DocumentPreview(template: template)
                    DocumentExam(template: template).environmentObject(self.store)
                    DocumentResult(template: template)
                    DocumentControl(template: template,
                                    controlMechanisms: self.$controlMechanims,
                                    idList: self.idList)
                    Button(action: {
                        self.sendResults()
                    }) {
                        SecondaryButton(title: "Ergebnisse an den Server senden")
                    }
                    .disabled(!disableSaveButton)
                    .padding([.horizontal, .vertical])
                }
                .padding(.bottom, 40 + bottomPadding)
                .padding(.top)
            }
            .resignKeyboardOnDragGesture()
            .navigationBarTitle("\(self.template.name)", displayMode: .large)
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
            .navigationBarItems(trailing: StartStopButton().environmentObject(self.store))
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                HStack(alignment: .center, spacing: 0) {
                    Button(action: {
                        self.delete = true
                    }) {
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "trash")
                            Text("Löschen")
                        }
                        .accentColor(.red)

                    }.alert(isPresented: self.$delete) { () -> Alert in
                        Alert(
                            title: Text("Vorlage löschen"),
                            message: Text("Bist du sicher, dass du die Vorlage löschen möchtest?"),
                            primaryButton: .destructive(Text("Löschen"), action: {
                                self.store.send(.service(action: .deleteTemplate(id: self.template.id)))
                                self.presentation.wrappedValue.dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    self.store.send(.service(action: .getTemplateList))
                                }
                            }),
                            secondaryButton: .cancel())
                    }
                    Spacer()
                    Button(action: {
                        for page in self.store.states.currentTemplate!.pages where page._image == nil {
                            self.alert = .pictures
                            return
                        }
                        self.showCamera = true
                    }) {
                        Image(systemName: "doc.text.viewfinder")
                        Text("Scannen")
                    }
                    Spacer()
                    NavigationLink(destination: PageSelectView()
                        .onAppear {
                            self.store.send(.newTemplate(action: .setTemplate(template: self.template)))
                        }
                    ) {
                        HStack(alignment: .center, spacing: 8) {
                            Image(systemName: "square.and.pencil")
                            Text("Bearbeiten")
                        }
                    }
                }
                .padding([.bottom, .horizontal, .top])
                .frame(height: 40)
            }
            .frame(height: 40+self.bottomPadding, alignment: .top)
            .background(BlurView(style: .regular))
            .offset(x: 0, y: self.bottomPadding)
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
                })
                .onAppear {
                    // Without async this action adds the Navigtionbar to the view -> BUG
                    DispatchQueue.main.async {
                        self.store.send(.log(action: .navigation("ScannerScreen")))
                    }
                }
                .onDisappear {
                    self.store.send(.log(action: .navigation("TemplateDetailScreen")))
                }
                .navigationBarHidden(true)
                .edgesIgnoringSafeArea(.all)
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
            self.store.send(.log(action: .navigation("TemplateDetailScreen")))
        }
        .onAppear {
            DispatchQueue.main.async {
                self.loadCachedImages()
            }
        }
    }

    struct Student: Equatable {
        var vorname: String
        var nachname: String
        var matrikel: String
    }

    public static let studenten: [Student] = [
        .init(vorname: "Hannes", nachname: "Steiner", matrikel: "01234"),
        .init(vorname: "Tobias", nachname: "Kallauke", matrikel: "01233"),
        .init(vorname: "Greta", nachname: "Helten", matrikel: "01235"),
        .init(vorname: "Mandy", nachname: "Quanz", matrikel: "01236"),
        .init(vorname: "Julian", nachname: "Arend", matrikel: "01237"),
        .init(vorname: "Lara", nachname: "Bishof", matrikel: "01238"),
        .init(vorname: "Janine", nachname: "Klz", matrikel: "01239"),
        .init(vorname: "Tim", nachname: "Müller", matrikel: "01240")

    ]

    fileprivate func sendResults() {
        let types: [ResultDatatype] = [.firstname, .lastname, .mark, .seminarGroup, .studentNumber]
        var result: [PageRegion] = []
        // vorname, nachname, matrikel, note
        for page in self.store.states.ocrState.result {
            if page == nil {
                return
            } else {
                for res in page! {
                    if types.contains(res.datatype) {
                        result.append(res)
                    }
                }
            }
        }
        let dic = Dictionary(grouping: result) { $0.datatype }
        for student in TemplateDetailView.studenten {
            var tempDis: Double = 0.0
            for type in types {
                guard let array = dic[type], let region = array.first else {
                    fatalError()
                }
                switch region.datatype {
                    case .none:
                        continue
                    case .mark:
                        continue
                    case .firstname:
                        tempDis += student.vorname.distanceJaroWinkler(between: region.textResult)
                    case .lastname:
                        tempDis += student.nachname.distanceJaroWinkler(between: region.textResult)
                    case .studentNumber:
                        tempDis += student.matrikel.distanceJaroWinkler(between: region.textResult)
                    case .seminarGroup:
                        continue
                        //tempDis += student.vorname.distanceJaroWinkler(between: region.textResult)
                    case .point:
                        continue
                }
            }
            //print(student, tempDis/3)
        }
    }

    func fuzzyString(text: String, results: [String]) -> (String, Float) {
        var distance: Double = 0.0
        var result: String = text

        for res in results {
            let tempDis: Double = text.distanceJaroWinkler(between: res)
            if distance < tempDis {
                distance = tempDis
                result = res
            }
            if distance == 1.0 {
                break
            }
        }
        return (result, Float(distance))
    }

    fileprivate func loadCachedImages() {
        var again: Bool = false
        for (index, page) in self.template.pages.indexed() where page._image == nil {
            //print("loadCachedImages")
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
            let array = [[PageRegion]?].init(repeating: nil, count: pages.count)
            self.store.send(.ocr(action: .initResult(array: array)))
            for index in 0..<pages.count {
                self.store.send(.ocr(action: .appendResult(at: pages[index].number)))
                pages[index].id = self.template.pages[index].id
                self.store.send(
                    .ocr(action: .ocrTesseract(page: pages[index], engine: engine)))
            }
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

struct BlurView: UIViewRepresentable {

    let style: UIBlurEffect.Style

    func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<BlurView>) {

    }
}

struct TemplateDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            NavigationView {
//                TemplateDetailView(template: AppStoreMock.realTemplate())
//                    .environmentObject(AppStoreMock.getAppStore())
//            }
//            .previewDevice("iPad Air 2")
//            .navigationViewStyle(StackNavigationViewStyle())
            NavigationView {
                TemplateDetailView(template: AppStoreMock.realTemplate())
                    .environmentObject(AppStoreMock.getAppStore())
            }.previewDevice("iPhone X")
        }
    }
}
