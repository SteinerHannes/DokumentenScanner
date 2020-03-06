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

struct OCRScannerView: UIViewControllerRepresentable {
    private let completionHandler: ([String]?) -> Void

    init(completion: @escaping ([String]?) -> Void) {
        self.completionHandler = completion
        print("init OCRScannerView")
    }

    typealias UIViewControllerType = VNDocumentCameraViewController

    func makeUIViewController(context: UIViewControllerRepresentableContext<OCRScannerView>) ->
        VNDocumentCameraViewController {
        let viewController = VNDocumentCameraViewController()
        viewController.delegate = context.coordinator
        return viewController
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController,
                                context: UIViewControllerRepresentableContext<OCRScannerView>) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(completion: completionHandler)
    }

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let completionHandler: ([String]?) -> Void

        init(completion: @escaping ([String]?) -> Void) {
            self.completionHandler = completion
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFinishWith scan: VNDocumentCameraScan) {
//            print("Document camera view controller did finish with ", scan)
            let recognizer = TextRecognizer(cameraScan: scan)
            recognizer.recognizeText(withCompletionHandler: completionHandler)
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            completionHandler(nil)
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController,
                                          didFailWithError error: Error) {
//            print("Document camera view controller did finish with error ", error)
            completionHandler(nil)
        }
    }
}
