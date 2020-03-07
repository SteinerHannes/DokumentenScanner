//
//  TemplateDetailView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 28.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

//swiftlint:disable multiple_closures_with_trailing_closure
struct TemplateDetailView: View {
    @EnvironmentObject var appState: AppState

    private var isLoading: Bool {
        return (self.result.isEmpty && !cameraDidFinish)
    }

    @State var cameraDidFinish: Bool = false

    @State private var result : [[String]] = []
    @State private var showCamera : Bool = false

    init() {
        print("init TemplateDetailView")
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                if self.showCamera {
                    ScannerView(isActive: self.$showCamera, completion: { pages in
                        self.onCompletion(pages: pages)
                    }).edgesIgnoringSafeArea(.all)
                        .navigationBarHidden(true)
                } else {
                    Form {
                        Section {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .top, spacing: 10) {
                                    Image(uiImage: self.appState.currentTemplate!.pages[0].image)
                                        .renderingMode(.original)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 88, height: 88)
                                        .layoutPriority(1)
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(self.appState.currentTemplate!.name)
                                            .font(.headline)
                                            .lineLimit(1)
                                        Text(self.appState.currentTemplate!.info)
                                            .font(.system(size: 13))
                                            .lineLimit(4)
                                    }
                                }.frame(height: 88)
                            }
                        }
                        if(!isLoading) {
                            ForEach(0..<self.appState.currentTemplate!.pages.count) { index in
                                Section {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(alignment: .top, spacing: 10) {
                                            Image(uiImage: self.appState.currentTemplate!.pages[index].image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(minWidth: 0, maxWidth: 88, minHeight: 0, maxHeight: 88)
                                            VStack(alignment: .leading, spacing: 5) {
                                                Text(self.pageInfo(index: index))
                                                    .font(.headline)
                                                    .lineLimit(1)
                                                Text(self.regionInfo(index: index))
                                                    .font(.system(size: 13))
                                                    .lineLimit(4)
                                            }
                                        }
                                    }
                                    //swiftlint:disable line_length
                                    ForEach(0..<self.appState.currentTemplate!.pages[index].regions.count) { regionIndex in
                                        if(index < self.result.count) {
                                            if( regionIndex < self.result[index].count) {
                                                Text("\(self.appState.currentTemplate!.pages[index].regions[regionIndex].name):").font(.headline)
                                                TextField("", text: self.$result[index][regionIndex])
                                            } else {
                                                HStack(alignment: .center, spacing: 0) {
                                                    Spacer()
                                                    ActivityIndicator(isAnimating: true)
                                                        .configure { $0.color = .tertiaryLabel }
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                    //swiftlint:enable line_length
                                }
                            }
                        } else if (isLoading) {
                            HStack(alignment: .center, spacing: 0) {
                                Spacer()
                                ActivityIndicator(isAnimating: isLoading)
                                    .configure { $0.color = .tertiaryLabel }
                                Spacer()
                            }
                        }
                    }
                    .listStyle(GroupedListStyle())
                    .environment(\.horizontalSizeClass, .regular)
                    .resignKeyboardOnDragGesture()
                }
            }
            .navigationBarTitle("\(self.appState.currentTemplate?.name ?? "FAIL")", displayMode: .large)
            .navigationBarItems(leading: self.leadingItem(), trailing: self.newPictureButton())
            .navigationBarBackButtonHidden(true)
        }
    }

    fileprivate func regionInfo(index: Int) -> String {
        return self.appState.currentTemplate!.pages[index].regions.map({ (regeion) -> String in
            return regeion.name
        }).joined(separator: ", ")
    }

    fileprivate func pageInfo(index: Int) -> String {
        return "Seite \(index+1) von \(self.appState.currentTemplate!.pages.count)"
    }

    fileprivate func newPictureButton() -> some View {
        return Button(action: {
            self.showCamera = true
            self.cameraDidFinish = false
        }) {
            Text("Neues Bild")
        }
    }

    fileprivate func leadingItem() -> some View {
        return Button(action: {
            self.appState.isTemplateDetailViewPresented = false
        }) {
            BackButtonView()
        }
    }

    fileprivate func onCompletion(pages: [Page]?) {
        self.showCamera = false
        self.cameraDidFinish = false
        self.result = []
        guard pages != nil else { return }
        if pages!.count == self.appState.currentTemplate!.pages.count {
            for page in pages! {
                self.result.append([])
                let imageResults: [PageRegionAndResult] = getPageRegions(page: page)
                TextRegionRecognizer(imageResults: imageResults).recognizeText { (resultArray) in
                    self.result[page.id] = resultArray
                    if page.id == pages!.count - 1 {
                        self.cameraDidFinish = true
                    }
                }
            }
        }
    }

    fileprivate func getPageRegions(page: Page) -> [PageRegionAndResult] {
        var results: [PageRegionAndResult] = []
        for region in self.appState.currentTemplate!.pages[page.id].regions {
            let templateSize = region.rectState
            let width = region.width
            let height = region.height
            let templateRect = CGRect(x: templateSize.width,
                                      y: templateSize.height, width:  width, height: height)
            let templateImage = self.appState.currentTemplate!.pages[page.id].image
            let image = page.image

            let proportionalRect = newProportionalRect(templateImage: templateImage,
                                                       newImage: image, templateRect: templateRect)

            guard let newImage:CGImage = image.cgImage?.cropping(to: proportionalRect)
                else {
                    continue
            }

            let imageResult: PageRegionAndResult = PageRegionAndResult(imageAttributeName: region.name,
                                                                       regionImage: newImage)
            results.append(imageResult)
        }
        return results
    }

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
        TemplateDetailView()
    }
}
