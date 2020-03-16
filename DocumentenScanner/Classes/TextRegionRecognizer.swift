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

/// The text recognizer for the PageRegionAndResult struct
final class TextRegionRecognizer {
    /// The list of all regions on a page
    let pageRegions: [PageRegion]

    init(imageResults: [PageRegion]) {
        self.pageRegions = imageResults
    }

    /// A dispatch queue (thread) for multithreading the text recognition
    private let queue = DispatchQueue(label: "com.dokumentenscanner.scan",
                                      qos: .default, attributes: [], autoreleaseFrequency: .workItem)

    /**
     The fucntion "returns" a list of the recognized text in the order of the page regions
     */
    func recognizeText(withCompletionHandler completionHandler: @escaping ([(String, VNConfidence)])
        -> Void) {
        queue.async {
            // extracs the images from the structs
            let images = (0..<self.pageRegions.count).compactMap({ self.pageRegions[$0].regionImage })
            // makes a tupel of an image and a request
            let imagesAndRequests = images.map({ (image: $0, request: VNRecognizeTextRequest()) })
            // append the result for each tupel
            let listOfTextsInRegions = imagesAndRequests.map { image, request -> (String, VNConfidence)in
                // initilaize the request
                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                do {
                    // start the request
                    try handler.perform([request])
                    guard let observations = request.results as? [VNRecognizedTextObservation] else {
                        return ("", 1.0)
                    }
                    // return the result
                    let text = observations.compactMap({
                        $0.topCandidates(1).first?.string
                    }).joined(separator: " ")
                    let averageConfidence = observations.compactMap({
                        $0.confidence
                    }).reduce(0, +) / Float(observations.count)
                    return (text, averageConfidence)
                } catch {
                    return ("", 0.0)
                }
            }
            // send the result back to the main thread
            DispatchQueue.main.async {
                completionHandler(listOfTextsInRegions)
            }
        }
    }
}
