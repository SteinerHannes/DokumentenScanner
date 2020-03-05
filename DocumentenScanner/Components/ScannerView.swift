//
//  ScannerView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 24.02.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI
import UIKit
import Vision
import VisionKit

struct ScannerView: UIViewControllerRepresentable {
    @Binding var isActive: Bool
    
    typealias UIViewControllerType = VNDocumentCameraViewController
    
    private let completionHandler: ([Page]?) -> Void
    
    init(isActive: Binding<Bool>, completion: @escaping ([Page]?) -> Void) {
        print("init ScannerView")
        self.completionHandler = completion
        self._isActive = isActive
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ScannerView>) -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: UIViewControllerRepresentableContext<ScannerView>) {
//        print("updateVC")
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(isActive: self.$isActive, completion: completionHandler)
    }
    
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let completionHandler: ([Page]?) -> Void
        @Binding var isActive: Bool

        init(isActive: Binding<Bool>, completion: @escaping ([Page]?) -> Void) {
            self.completionHandler = completion
            self._isActive = isActive
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
//            print("Document camera view controller did finish with ", scan)
            var pages: [Page] = []
            
            for index in 0..<scan.pageCount {
                pages.append(Page(id: index, image: scan.imageOfPage(at: index)))
            }

            completionHandler(pages)
            self.isActive = false
        }
        
        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
//            print("Document camera view controller did cancel")
            completionHandler(nil)
            self.isActive = false
        }
        
        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
//            print("Document camera view controller did finish with error ", error)
            completionHandler(nil)
            self.isActive = false
        }
    }
    
}
