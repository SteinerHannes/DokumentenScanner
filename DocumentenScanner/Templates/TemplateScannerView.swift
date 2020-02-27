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
    @Binding var isActive:Bool
    
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    private let completionHandler: (UIImage?) -> Void
    
    init(isActive: Binding<Bool> ,completion: @escaping (UIImage?) -> Void) {
        self.completionHandler = completion
        self._isActive = isActive
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TemplateScannerView>) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: UIViewControllerRepresentableContext<TemplateScannerView>) {
        print("updateVC")
    }
    
//    func makeCoordinator() -> Coordinator {
//        return Coordinator(presentationMode: self.presentation, appState: self.$appState, completion: completionHandler)
//    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isActive: self.$isActive, completion: completionHandler)
    }
    
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let completionHandler: (UIImage?) -> Void
        @Binding var isActive:Bool
//        private var appState: EnvironmentObject<AppState>.Wrapper
        
//        init(presentationMode: Binding<PresentationMode>, appState: EnvironmentObject<AppState>.Wrapper, completion: @escaping (UIImage?) -> Void) {
//            self.completionHandler = completion
//            self.presentation = presentationMode
//            self.appState = appState
//        }
        
        init(isActive: Binding<Bool>, completion: @escaping (UIImage?) -> Void) {
            self.completionHandler = completion
            self._isActive = isActive
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            print("Document camera view controller did finish with ", scan)
            let image = scan.imageOfPage(at: 0)
            //self.appState.images.wrappedValue.append(image)
            completionHandler(image)
            self.isActive = false
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            print("Document camera view controller did cancel")
            completionHandler(nil)
            self.isActive = false
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document camera view controller did finish with error ", error)
            completionHandler(nil)
            self.isActive = false
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
