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
//swiftlint:disable switch_case_alignment cyclomatic_complexity function_body_length
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
                request.usesLanguageCorrection = false
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
                    let textResult = observations.compactMap({
                        $0.topCandidates(1).first?.string
                    }).joined(separator: " ")
                    let confidence = observations.compactMap({
                        $0.topCandidates(1).first?.confidence
                    }).reduce(0, +) / Float(observations.count)
                    // decide on the datatype wich settings is used durgin recognition
                    var result = ""
                    var newConfidence: VNConfidence = confidence
                    // second check and correction
                    switch self.pageRegions[index].datatype {
                        case .mark:
                            for char in textResult {
                                result.append(char.changeCharacterInMarkOrPoint())
                            }
                            if result.count == 2 && !result.contains(",") {
                                result.insert(",", at: result.index(after: result.startIndex))
                            }
                            let regex = "[1-6],[0-9]"
                            print("erkannt:", textResult)
                            print("gewandelt:", result)
                            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
                            if !predicate.evaluate(with: result) {
                                newConfidence = Float.nan
                                result = ""
                            } else {
                                newConfidence = 1.0
                            }
                        case .point:
                            for char in textResult {
                                result.append(char.changeCharacterInMarkOrPoint())
                            }
                        case .seminarGroup:
                            (result, newConfidence) = fuzzyString(text: textResult, results: SeminarGroups)
                        default:
                            result = textResult
                    }
                    // set the result
                    self.pageRegions[index].textResult = result
                    self.pageRegions[index].confidence = newConfidence
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

extension Character {
    func changeCharacterInMarkOrPoint() -> Character {
        let allowedChars = "0123456789"
        let conversionTable = [
            "s": "5",
            "S": "5",
            "o": "0",
            "Q": "0",
            "O": "0",
            "0": "0",
            "l": "1",
            "I": "1",
            "B": "8",
            "F": "4",
            ".": ","
        ]
        let maxSubstitutions = 2
        var current = String(self)
        var counter = 0
        while !allowedChars.contains(current) && counter < maxSubstitutions {
            if let altChar = conversionTable[current] {
                current = altChar
                counter += 1
            } else {
                break
            }
        }
        return current.first!
    }
}

func fuzzyString(text: String, results: [String]) -> (String, Float) {
    var distance: Double = 0.0
    var result: String = text

    for res in results {
        let tempDis: Double = text.distanceJaroWinkler(between: res)
        if distance < tempDis {
            distance = tempDis
            result = res
        }
        if distance == 1.0 {
            break
        }
    }
    return (result, Float(distance))
}

extension String {
    // Source: https://github.com/autozimu/StringMetric.swift/blob/master/Sources/StringMetric.swift

    public func distanceJaroWinkler(between target: String) -> Double {
        var stringOne = self
        var stringTwo = target
        if stringOne.count > stringTwo.count {
            stringTwo = self
            stringOne = target
        }

        let stringOneCount = stringOne.count
        let stringTwoCount = stringTwo.count

        if stringOneCount == 0 && stringTwoCount == 0 {
            return 1.0
        }

        let matchingDistance = stringTwoCount / 2
        var matchingCharactersCount: Double = 0
        var transpositionsCount: Double = 0
        var previousPosition = -1

        // Count matching characters and transpositions.
        for (i, stringOneChar) in stringOne.enumerated() {
            for (j, stringTwoChar) in stringTwo.enumerated() {
                if max(0, i - matchingDistance)..<min(stringTwoCount, i + matchingDistance) ~= j {
                    if stringOneChar == stringTwoChar {
                        matchingCharactersCount += 1
                        if previousPosition != -1 && j < previousPosition {
                            transpositionsCount += 1
                        }
                        previousPosition = j
                        break
                    }
                }
            }
        }

        if matchingCharactersCount == 0.0 {
            return 0.0
        }

        // Count common prefix (up to a maximum of 4 characters)
        let commonPrefixCount = min(max(Double(self.commonPrefix(with: target).count), 0), 4)

        //swiftlint:disable line_length
        let jaroSimilarity = (matchingCharactersCount / Double(stringOneCount) + matchingCharactersCount / Double(stringTwoCount) + (matchingCharactersCount - transpositionsCount) / matchingCharactersCount) / 3

        // Default is 0.1, should never exceed 0.25 (otherwise similarity score could exceed 1.0)
        let commonPrefixScalingFactor = 0.1

        return jaroSimilarity + commonPrefixCount * commonPrefixScalingFactor * (1 - jaroSimilarity)
    }
}
