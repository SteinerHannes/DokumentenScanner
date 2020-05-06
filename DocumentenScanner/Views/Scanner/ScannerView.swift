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

/// UIViewController representable for the VNDocumentCameraViewController
struct ScannerView: UIViewControllerRepresentable {
    /// It shows wether the UIView is active or not
    @Binding var isActive: Bool

    typealias UIViewControllerType = VNDocumentCameraViewController

    /// The function which get triggered after the view dismisses
    private let completionHandler: ([Page]?) -> Void

    /**
     The initializer of this view
     - parameter isActive: Binding bool from the parent view,
     to active theview from outside and dismiss from the inside
     - parameter completion: The function after the UIView is dismissed
     */
    init(isActive: Binding<Bool>, completion: @escaping ([Page]?) -> Void) {
        print("init ScannerView")
        self.completionHandler = completion
        self._isActive = isActive
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ScannerView>)
        -> VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController,
                                context: UIViewControllerRepresentableContext<ScannerView>) {
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(isActive: self.$isActive, completion: completionHandler)
    }

    /// The view delegate
    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let completionHandler: ([Page]?) -> Void
        @Binding var isActive: Bool

        /**
         The initializer of this delegate
         - parameter isActive: Binding bool from the parent view,
         to active the view from outside and dismiss from the inside
         - parameter completion: The function after the UIView is dismissed
         */
        init(isActive: Binding<Bool>, completion: @escaping ([Page]?) -> Void) {
            self.completionHandler = completion
            self._isActive = isActive
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
            var pages: [Page] = []
            for index in 0..<scan.pageCount {
                pages.append(Page(id: index, number: index, _image: scan.imageOfPage(at: index)))
            }
            // Returns a list of pages with a page number and the image from the scan
            completionHandler(pages)
            self.isActive = false
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            completionHandler(nil)
            self.isActive = false
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFailWithError error: Error) {
            completionHandler(nil)
            self.isActive = false
        }
    }

}
