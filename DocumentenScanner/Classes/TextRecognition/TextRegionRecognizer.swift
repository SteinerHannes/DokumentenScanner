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
//swiftlint:disable switch_case_alignment
/// The text recognizer for the PageRegionAndResult struct
final class TextRegionRecognizer {
    /// The list of all regions on a page
    var pageRegions: [PageRegion]

    init(imageResults: [PageRegion]) {
        self.pageRegions = imageResults
    }

    /// A dispatch queue (thread) for multithreading the text recognition
    private let queue = DispatchQueue(label: "com.dokumentenscanner.scan",
                                      qos: .default, attributes: [], autoreleaseFrequency: .workItem)

    /**
     The fucntion "returns" a list of the recognized text in the order of the page regions
     */
    func recognizeText(withCompletionHandler completionHandler: @escaping ([PageRegion])
        -> Void) {
        queue.async {
            // extracs the images from the structs
            for index in 0..<self.pageRegions.count {
                let handler = VNImageRequestHandler(cgImage: self.pageRegions[index].regionImage!,
                                                    options: [:])
                // if needed later, just remove this line -> at the moment not needed
                self.pageRegions[index].regionImage = nil
                let request = VNRecognizeTextRequest()
                // decide on the datatype wich settings is used durgin recognition
                switch self.pageRegions[index].datatype {
                    case .mark:
                        request.recognitionLevel = .accurate
                        request.customWords = Marks
                    case .seminarGroup:
                        request.recognitionLevel = .accurate
                        request.customWords = SeminarGroups
                    default:
                        request.recognitionLevel = .accurate
                }
                // start the request
                do {
                    try handler.perform([request])
                    guard let observations = request.results as? [VNRecognizedTextObservation]  else {
                        continue
                    }
                    // set the result
                    self.pageRegions[index].textResult = observations.compactMap({
                        $0.topCandidates(1).first?.string
                    }).joined(separator: " ")
                    self.pageRegions[index].confidence = observations.compactMap({
                        $0.confidence
                    }).reduce(0, +) / Float(observations.count)
                } catch {
                    continue
                }
            }
            // send the results back to the main thread
            DispatchQueue.main.async {
                completionHandler(self.pageRegions)
            }
        }
    }
}
