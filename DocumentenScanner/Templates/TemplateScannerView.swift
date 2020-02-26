//
//  TemplateScannerView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import UIKit
import Vision
import VisionKit

struct TemplateScannerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentation:Binding<PresentationMode>
//    @EnvironmentObject var appState:AppState
    
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    private let completionHandler: (UIImage?) -> Void
    
    init(completion: @escaping (UIImage?) -> Void) {
        self.completionHandler = completion
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TemplateScannerView>) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        //viewController.modalPresentationStyle = .formSheet
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: UIViewControllerRepresentableContext<TemplateScannerView>) {
        print("updateVC")
    }
    
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(presentationMode: self.presentation, appState: self.$appState, completion: completionHandler)
//    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(presentationMode: self.presentation, completion: completionHandler)
    }
    
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let completionHandler: (UIImage?) -> Void
        private var presentation: Binding<PresentationMode>
//        private var appState: EnvironmentObject<AppState>.Wrapper
        
//        init(presentationMode: Binding<PresentationMode>, appState: EnvironmentObject<AppState>.Wrapper, completion: @escaping (UIImage?) -> Void) {
//            self.completionHandler = completion
//            self.presentation = presentationMode
//            self.appState = appState
//        }
        
        init(presentationMode: Binding<PresentationMode>, completion: @escaping (UIImage?) -> Void) {
            self.completionHandler = completion
            self.presentation = presentationMode
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            print("Document camera view controller did finish with ", scan)
            let image = scan.imageOfPage(at: 0)
            //self.appState.images.wrappedValue.append(image)
            completionHandler(image)
            self.presentation.wrappedValue.dismiss()
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            print("Document camera view controller did cancel")
            completionHandler(nil)
            presentation.wrappedValue.dismiss()
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document camera view controller did finish with error ", error)
            completionHandler(nil)
            self.presentation.wrappedValue.dismiss()
        }
    }
    
}

//func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
//{
//    let imageViewScale = max(inputImage.size.width / viewWidth,
//                             inputImage.size.height / viewHeight)
//
//    // Scale cropRect to handle images larger than shown-on-screen size
//    let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
//                          y:cropRect.origin.y * imageViewScale,
//                          width:cropRect.size.width * imageViewScale,
//                          height:cropRect.size.height * imageViewScale)
//
//    // Perform cropping in Core Graphics
//    guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
//        else {
//            return nil
//    }
//
//    // Return image to UIImage
//    let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
//    return croppedImage
//}

//struct TemplateScannerView_Previews: PreviewProvider {
//    static var previews: some View {
//        TemplateScannerView(completion: nil)
//    }
//}
