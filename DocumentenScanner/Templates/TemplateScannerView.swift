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
    @Binding var isActive: Bool
    
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    private let completionHandler: (UIImage?) -> Void
    
    init(isActive: Binding<Bool>, completion: @escaping (UIImage?) -> Void) {
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
        @Binding var isActive: Bool
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
