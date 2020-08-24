//
//  OCRService.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 22.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

//swiftlint:disable function_body_length
import Foundation
import Combine
import SwiftUI

public struct OcrResult: Codable {
    public let attributeId: Int
    public let confidence: Float
    public let value: String
}

public struct OcrRequest: Codable {
    public let engine: String
    public let image: String
    public let pageId: Int
}

enum OCRServiceError: Error {
    case badUrl
    case badEncoding
    case decoder(error: Error)
    case serverError
    case responseCode(code: Int)
    case response(text: String)
    case noJWT
}

final class OCRService {
    let baseUrl: String = baseAuthority

    let session: URLSession
    let encoder: JSONEncoder
    let decoder: JSONDecoder

    init(session: URLSession, encoder: JSONEncoder, decoder: JSONDecoder) {
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
    }

    private func hasInternetConnection() -> Bool {
        let status = Reach().connectionStatus()
        switch status {
            case .offline, .unknown:
                return false
            default:
                return true
        }
    }

    func OCRonPage(pageID: Int, imageUrl: String, engine: OCREngine)
        -> AnyPublisher<AppAction, Never> {
            print("OCRonPage", pageID, imageUrl, engine.rawValue)
        if hasInternetConnection() == false {
            return Just(AppAction.ocr(action: .handelError(.serverError))).eraseToAnyPublisher()
        }
        // chek if jwt exists
        guard let jwt = UserDefaults.standard.string(forKey: "JWT") else {
            return Just(AppAction.ocr(action: .handelError(.noJWT))).eraseToAnyPublisher()
        }
        // prepare data for uplaod
        let imageURL = imageUrl.replacingOccurrences(of: "/img/", with: "")
        let ocrRequest = OcrRequest(engine: engine.rawValue, image: imageURL, pageId: pageID)
        // encode data
        guard let uploadData = try? self.encoder.encode(ocrRequest) else {
            return Just(AppAction.ocr(action: .handelError(.badEncoding))).eraseToAnyPublisher()
        }
        print(ocrRequest)
        // configure an uplaod request
        guard let url = URL(string: baseUrl + "/ocr" ) else {
            return Just(AppAction.ocr(action: .handelError(.badUrl))).eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let authValue: String = "Bearer \(jwt)"
        request.allHTTPHeaderFields = ["Authorization": authValue]
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData

        return session.dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) -> Result<(Int, [OcrResult]), OCRServiceError> in
                // cast is needed for statuscode
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .failure(.serverError)
                }
                // check if answer is OK
                if httpResponse.statusCode != 200 {
                    sendNotification(titel: "Fehler",
                                     description: String(data: data, encoding: .utf8) ??
                        "\(httpResponse.statusCode)")
                    print(String(data: data, encoding: .utf8) as Any)
                    return .failure(.responseCode(code: httpResponse.statusCode))
                }
                // decode data and return it
                if let mimeType = response.mimeType,
                    mimeType == "application/json" {
                    do {
                        let answer: [OcrResult] = try self.decoder.decode([OcrResult].self, from: data)
                        return .success((pageID, answer))
                    } catch let decodeError {
                        print(String(data: data, encoding: .utf8) ?? "Daten sind nicht .uft8")
                        return .failure(.decoder(error: decodeError))
                    }
                }
                return .failure(.response(text: String(data: data, encoding: .utf8) ?? "Fehler" ))
        }
        .map { result -> AppAction in
            // if there is a result in the stream
            print("ocr fertig ohne fehler")
            return .ocr(action: .handelOCRResult(result: result))
        }
        .replaceError(with:
            // MARK: TODO besseres Fehlerhandling, es müssten dann leere Ergebnisse zurück geschickt werden.
            .ocr(action: .handelOCRResult(result: .failure(.serverError)))
        )
        .eraseToAnyPublisher()
    }

    func uploadImage(image: UIImage) -> AnyPublisher<AppAction, Never> {
        print("uploadImage:", image)
        if hasInternetConnection() == false {
            return Just(AppAction.ocr(action: .handelError(.serverError))).eraseToAnyPublisher()
        }
        // chek if jwt exists
        guard let jwt = UserDefaults.standard.string(forKey: "JWT") else {
            return Just(AppAction.ocr(action: .handelError(.noJWT))).eraseToAnyPublisher()
        }
        guard let data = image.pngData() else {
            return Just(AppAction.ocr(action: .handelError(.badEncoding))).eraseToAnyPublisher()
        }
        // configure an uplaod request
        guard let url = URL(string: baseUrl + "/Image/upload" ) else {
            return Just(AppAction.ocr(action: .handelError(.badUrl))).eraseToAnyPublisher()
        }
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let authValue: String = "Bearer \(jwt)"
        request.allHTTPHeaderFields = ["Authorization": authValue]
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let httpBody = NSMutableData()
        httpBody.append(convertFileData(fieldName: "image",
                                        fileName: "image.png",
                                        mimeType: "image/png",
                                        fileData: data,
                                        using: boundary))
        httpBody.appendString("--\(boundary)--")
        request.httpBody = httpBody as Data

        return session.dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) -> Result<String, OCRServiceError> in
                // cast is needed for statuscode
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .failure(.serverError)
                }
                // check if answer is OK
                if httpResponse.statusCode != 200 {
                    print(String(data: data, encoding: .utf8) as Any)
                    return .failure(.responseCode(code: httpResponse.statusCode))
                }
                // decode data and return it
                if let mimeType = response.mimeType,
                    mimeType == "application/json" {
                    do {
                        let answer: ImageResponse = try self.decoder.decode(ImageResponse.self, from: data)
                        return .success(answer.path)
                    } catch let decodeError {
                        print(String(data: data, encoding: .utf8) ?? "Daten sind nicht .uft8")
                        return .failure(.decoder(error: decodeError))
                    }
                }
                return .failure(.response(text: String(data: data, encoding: .utf8) ?? "Fehler" ))
        }
        .map { result -> AppAction in
            // if there is a result in the stream
            print("uploadimage fertig")
            return .ocr(action: .handelImageUplaodResult(result: result))
        }
        .replaceError(with:
            .ocr(action: .handelImageUplaodResult(result: .failure(.serverError)))
        )
        .eraseToAnyPublisher()
    }

    private func convertFileData(fieldName: String, fileName: String, mimeType: String,
                                 fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()
        data.appendString("--\(boundary)\r\n")
        //swiftlint:disable line_length
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        //swiftlint:enable line_length
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")

        return data as Data
    }
}

extension URLSession {
    func dataTask(with request: URLRequest,
                  result: @escaping (Result<(URLResponse, Data), Error>) -> Void)
    -> URLSessionDataTask {
        return dataTask(with: request) { (data, response, error) in
            if let error = error {
                result(.failure(error))
                return
            }
            guard let response = response, let data = data else {
                let error = NSError(domain: "error", code: 0, userInfo: nil)
                result(.failure(error))
                return
            }
            result(.success((response, data)))
        }
    }
}
