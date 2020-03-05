//
//  TemplateDetailView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 28.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

struct TemplateDetailView: View {
    @EnvironmentObject var appState: AppState
    
    private var isLoading: Bool {
        return (self.result.isEmpty && !cameraDidFinish)
    }
    
    @State var cameraDidFinish: Bool = false
    
    @State private var result : [[String]] = []
    @State private var showCamera : Bool = false
    
    init(){
        print("init TemplateDetailView")
    }
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading, spacing: 0) {
                if self.showCamera {
                    ScannerView(isActive: self.$showCamera, completion: { pages in
                        self.onCompletion(pages: pages)
                    }).edgesIgnoringSafeArea(.all)
                        .navigationBarHidden(true)
                }else{
                    Form {
                        Section {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .top, spacing: 10) {
                                    Image(uiImage: self.appState.currentTemplate!.pages[0].image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(minWidth: 0, maxWidth: 88, minHeight: 0, idealHeight: 88, maxHeight: 88)
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text(self.appState.currentTemplate!.name).font(.headline)
                                        Text(self.appState.currentTemplate!.info).font(.system(size: 13))
                                    }
                                }
                            }
                        }
                        if(!isLoading){
                            ForEach (0..<self.appState.currentTemplate!.pages.count) { index in
                                Section {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(alignment: .top, spacing: 10) {
                                            Image(uiImage: self.appState.currentTemplate!.pages[index].image)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(minWidth: 0, maxWidth: 88, minHeight: 0, idealHeight: 88, maxHeight: 88)
                                        }
                                    }
                                    ForEach(0..<self.appState.currentTemplate!.pages[index].regions.count){ regionIndex in
                                        Text("\(self.appState.currentTemplate!.pages[index].regions[regionIndex].name):")
                                        if(index < self.result.count){
                                            TextField("", text: self.$result[index][regionIndex])
                                        }
                                    }
                                }
                            }
                        }else if (isLoading){
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
    
    fileprivate func newPictureButton() -> some View {
        return Button(action: {
            self.showCamera = true
        }){
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
    
    fileprivate func onCompletion(pages: [Page]?){
        self.showCamera = false
        guard pages != nil else { return }
        if pages!.count == self.appState.currentTemplate!.pages.count {
            for page in pages! {
                print(page.id)
                let imageResults: [PageResult] = getPageRegions(page: page)
                TextRegionRecognizer(imageResults: imageResults).recognizeText { (resultArray) in
                    self.result.append(resultArray)
                    if page.id == pages!.count {
                        print("Finish")
                        print(self.result)
//                        while(self.result[page.id].count != self.appState.currentTemplate!.pages[page.id].regions.count) { }
                        self.cameraDidFinish = true
                    }
                }
            }
        }
    }
    
    fileprivate func getPageRegions(page: Page) -> [PageResult] {
        var results: [PageResult] = []
        for region in self.appState.currentTemplate!.pages[page.id].regions {
            let templateSize = region.rectState
            let width = region.width
            let height = region.height
            let templateRect = CGRect(x: templateSize.width, y: templateSize.height, width:  width, height: height)
            let templateImage = self.appState.currentTemplate!.pages[page.id].image
            let image = page.image
            
            let proportionalRect = newProportionalRect(templateImage: templateImage, newImage: image, templateRect: templateRect)
            
            guard let newImage:CGImage = image.cgImage?.cropping(to: proportionalRect)
                else {
                    continue
            }
            
            let imageResult: PageResult = PageResult(imageAttributeName: region.name, regionImage: newImage)
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
