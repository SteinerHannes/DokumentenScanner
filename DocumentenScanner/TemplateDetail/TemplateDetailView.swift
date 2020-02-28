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
    
    private let id:String
    init(id: String) {
        self.id = id
    }
    
    @State private var text : String = ""
    @State private var showCamera : Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if self.showCamera {
                TemplateScannerView(isActive: self.$showCamera, completion: { image in
                    self.text = self.onCompletion(image: image)
                })
                    .edgesIgnoringSafeArea(.all)
            }else{
                ScrollView(.vertical, showsIndicators: true) {
                    Text(id)
                    VStack {
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
                        Text(text)
                        Image(uiImage: self.appState.image ?? UIImage(imageLiteralResourceName: "post"))
                            .resizable()
                            .scaledToFit()
                    }
                }
            }
        }.onAppear{
            self.appState.setCurrentImageTemplate(for: self.id)
        }
        .navigationBarTitle("\(self.appState.currentImageTemplate?.info ?? "FAIL")", displayMode: .large)
        .navigationBarItems(trailing: self.newPictureButton())
    }
    
    fileprivate func newPictureButton() -> some View {
        return Button(action: {
            self.showCamera = true
        }){
            Text("Neues Bild")
        }
    }
    
    fileprivate func onCompletion(image: UIImage?) -> String {
        guard image != nil else { return "" }
        self.appState.image = image!
        self.showCamera = false
        let templateSize = self.appState.currentImageTemplate!.attributeList[0].rectState
        let width = self.appState.currentImageTemplate!.attributeList[0].width
        let height = self.appState.currentImageTemplate!.attributeList[0].height
        let templateRect = CGRect(x: templateSize.width, y: templateSize.height, width:  width, height: height)
        let templateImage = self.appState.currentImageTemplate?.image!
        
        let proportionalRect = newProportionalRect(templateImage: templateImage!, newImage: image!, templateRect: templateRect)
        
        guard let newImage:CGImage = image!.cgImage?.cropping(to: proportionalRect)
        else {
            return("FAIL")
        }
        
        self.appState.image = UIImage(cgImage: newImage)
        
        return """
        Größe: \(image!.size)
        Größe: \(templateImage!.size)
        oriR:
        X: \(templateSize.width)
        Y: \(templateSize.height)
        Width: \(width)
        Height: \(height)
        Rect:
        X: \(proportionalRect.origin.x)
        Y: \(proportionalRect.origin.y)
        Width: \(proportionalRect.width)
        Height: \(proportionalRect.height)
        """
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
        TemplateDetailView(id: "String")
    }
}
