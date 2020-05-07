//
//  OCRState.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 22.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//
// swiftlint:disable cyclomatic_complexity function_body_length
import Foundation
import Combine
import SwiftUI

struct OCRState {
    var result: [[PageRegion]?] = []
}

enum OCRAction {
    /// Send the results of the textrecognition to the correct page number
    case sendResult(pageNumber: Int, result: [PageRegion])
    /// Adds an empty list to the result list at the page number
    case appendResult(at: Int)
    /// Initialize the result list
    case initResult(array: [[PageRegion]?])
    /// Clears the result list
    case clearResult
    /// Change the result at page and region, with textfield
    case changeResult(page: Int, region: Int, text: String)

    case ocrTesseract(page: Page, engine: OCREngine)

    case handelError(_: OCRServiceError)

    case handelOCRResult(result: Result<(Int, [OcrResult]), OCRServiceError>)

    case handelImageUplaodResult(result: Result<String, OCRServiceError>)

    case handelOCR(pageID: Int, imageUrl: String, engine: OCREngine)
}

/// The reducer of the ocr state
/// for sending pages to the sever and recive the results
func ocrReducer(state: inout OCRState, action: OCRAction, enviorment: AppEnviorment, template: Template?)
    -> AnyPublisher<AppAction, Never>? {
        switch action {
            case let .sendResult(pageNumber: number, result: pageRegions):
                state.result[number] = pageRegions

            case let .appendResult(at: pageNumber):
                state.result[pageNumber] = []

            case let .initResult(array: nilPages):
                state.result = nilPages

            case .clearResult:
                state.result = []

            case let .changeResult(page: page, region: region, text: text):
                state.result[page]![region].textResult = text

            case let .ocrTesseract(page: page, engine: engine):
                return enviorment.ocr.uploadImage(image: page._image!)
                    .flatMap { (action) -> AnyPublisher<AppAction, Never> in
                        print("in schleife", page.id)
                        switch action {
                            case let .ocr(action: .handelImageUplaodResult(result: result)):
                                switch result {
                                    case let .success(url):
                                        print("Starte ocr")
                                        return Just(AppAction.ocr(action:
                                            .handelOCR(pageID: page.id, imageUrl: url, engine: engine)))
                                            .eraseToAnyPublisher()
                                    case let .failure(error):
                                        return Just(AppAction.ocr(action: .handelError(error)))
                                            .eraseToAnyPublisher()
                            }
                            default:
                                return Just(action).eraseToAnyPublisher()
                        }
                }.eraseToAnyPublisher()

            case let .handelOCR(pageID: id, imageUrl: url, engine: engine):
                print("Start begonnen")
                return enviorment.ocr.OCRonPage(pageID: id, imageUrl: url, engine: engine)

            case .handelImageUplaodResult(result: _):
                print("...")

            case let .handelOCRResult(result: result):
                switch result {
                    case let .success((pageID, ocrlist)):
                        print(ocrlist.debugDescription)
                        print(pageID)
                        guard let template = template else {
                            return Empty().eraseToAnyPublisher()
                        }
                        let page = template.pages.first { (page) -> Bool in
                            page.id == pageID
                        }
                        if page == nil {
                            return Empty().eraseToAnyPublisher()
                        }
                        var result: [PageRegion] = Array.init(repeating: .init(), count: page!.regions.count)
                        for ocr in ocrlist {
                            let index: Int = page!.regions.firstIndex { (region) -> Bool in
                                region.id == String(ocr.attributeId)
                            }!
                            let region = page!.regions[index]

                            result[index] = PageRegion(regionID: region.id,
                                                       regionName: region.name,
                                                       datatype: region.datatype,
                                                       textResult: ocr.value, confidence: ocr.confidence)
                        }
                        return Just(AppAction.ocr(action: .sendResult(pageNumber: page!.number,
                                                                      result: result)))
                            .eraseToAnyPublisher()

                    case let .failure(error):
                        print("ocr beendet mit fehler")
                        return Just(AppAction.ocr(action: .handelError(error))).eraseToAnyPublisher()
            }

            case let .handelError(error):
                print("Error:", error)
        }
        return Empty().eraseToAnyPublisher()
}

///// The unique id of the attribute in that region
//public var regionID: String
///// The image of the region
//public var regionImage: CGImage?
///// The data type of the content of the region
//public var datatype: ResultDatatype
/////
//public var textResult: String = ""
/////
//public var confidence: VNConfidence = 0.0
//
//public var regionName: String
