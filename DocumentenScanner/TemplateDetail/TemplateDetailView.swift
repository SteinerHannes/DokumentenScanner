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
        return self.result.isEmpty && cameraDidFinish
    }
    
    @State var cameraDidFinish: Bool = false
    
    @State private var result : [String] = []
    @State private var showCamera : Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if self.showCamera {
                ScannerView(isActive: self.$showCamera, completion: { image in
                    self.onCompletion(image: image)
                }).edgesIgnoringSafeArea(.all)
                .navigationBarHidden(true)
            }else{
                Form {
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .top, spacing: 10) {
                                Image(uiImage: self.appState.currentImageTemplate?.image ?? UIImage(imageLiteralResourceName: "post"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(minWidth: 0, maxWidth: 88, minHeight: 0, idealHeight: 88, maxHeight: 88)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(self.appState.currentImageTemplate?.name ?? "").font(.headline)
                                    Text(self.appState.currentImageTemplate?.info ?? "").font(.system(size: 13))
                                }
                            }
                        }
                    }
                    if(!result.isEmpty){
                        ForEach(0..<result.count) { index in
                            Section(header: Text(self.appState.currentImageTemplate!.attributeList[index].name)) {
                                TextField(self.appState.currentImageTemplate!.attributeList[index].name, text: self.$result[index])
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
//        .onAppear{
//            self.appState.setCurrentImageTemplate(for: self.id)
//        }
        .navigationBarTitle("\(self.appState.currentImageTemplate?.name ?? "FAIL")", displayMode: .large)
            .navigationBarItems(leading: self.leadingItem(), trailing: self.newPictureButton())
        .navigationBarBackButtonHidden(true)
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
    
    fileprivate func onCompletion(image: UIImage?){
        self.showCamera = false
        guard image != nil else { return }
        self.cameraDidFinish = true
        let imageResults: [ImageResult] = getImageRegions(image: image!)
        TextRegionRecognizer(imageResults: imageResults).recognizeText { (resultArray) in
            self.result = resultArray
        }
    }
    
    fileprivate func getImageRegions(image: UIImage) -> [ImageResult] {
        var results: [ImageResult] = []
        
        for attribute in self.appState.currentImageTemplate!.attributeList {
            
            let templateSize = attribute.rectState
            let width = attribute.width
            let height = attribute.height
            let templateRect = CGRect(x: templateSize.width, y: templateSize.height, width:  width, height: height)
            let templateImage = self.appState.currentImageTemplate!.image!

            let proportionalRect = newProportionalRect(templateImage: templateImage, newImage: image, templateRect: templateRect)

            guard let newImage:CGImage = image.cgImage?.cropping(to: proportionalRect)
                else {
                    continue
            }

            let imageResult: ImageResult = ImageResult(imageAttributeName: attribute.name, regionImage: newImage)
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
