//
//  TextRegionRecognizer.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 07.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import Vision
import VisionKit

final class TextRegionRecognizer {
    let imageResults: [PageRegionAndResult]

    init(imageResults: [PageRegionAndResult]) {
        self.imageResults = imageResults
    }

    private let queue = DispatchQueue(label: "com.dokumentenscanner.scan",
                                      qos: .default, attributes: [], autoreleaseFrequency: .workItem)

    func recognizeText(withCompletionHandler completionHandler: @escaping ([String]) -> Void) {
        queue.async {
            let images = (0..<self.imageResults.count).compactMap({ self.imageResults[$0].regionImage })
            let imagesAndRequests = images.map({ (image: $0, request: VNRecognizeTextRequest()) })
            let textPerPage = imagesAndRequests.map { image, request -> String in
                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                do {
                    try handler.perform([request])
                    guard let observations = request.results as? [VNRecognizedTextObservation] else {
                        return ""
                    }
                    return observations.compactMap({
                        $0.topCandidates(1).first?.string
                    }).joined(separator: " ")
                } catch {
                    return ""
                }
            }
            DispatchQueue.main.async {
                completionHandler(textPerPage)
            }
        }
    }
}
