//
//  ExamService.swift
//  DokumentenScanner
//
//  Created by Hannes Steiner on 22.08.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import Combine

enum ExamServiceError: Error, LocalizedError {
    case badUrl
    case badEncoding
    case decoder(error: Error)
    case serverError
    case responseCode(code: Int)
    case response(text: String)
    case noJWT

    var localizedDescription: String {
        switch self {
            case .badUrl:
                return "URL konnte nicht zusammengesetzt werden"
            case .badEncoding:
                return "Codierungsfehler"
            case .decoder(error: let error):
                return "Decodierungsfehler" + error.localizedDescription
            case .serverError:
                return "Server-Fehler"
            case .responseCode(code: let code):
                return "Responsecode: \(code)"
            case .response(text: let text):
                return "Server-Antwort: " + text
            case .noJWT:
                return "Du bist nicht korrekt angemeldet."
        }
    }
}

final class ExamService {
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

    //swiftlint:disable line_length
    func getStudentList(examId: Int) -> AnyPublisher<AppAction, Never> {
        if hasInternetConnection() == false {
            return Just(.service(action: .getStudentListResult(result: .failure(.serverError))))
                .eraseToAnyPublisher()
        }
        // configure an uplaod request
        guard let url = URL(string: baseUrl + "/Exam/\(examId)/students" ) else {
            return Just(.service(action: .getStudentListResult(result: .failure(.badUrl))))
                .eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return session.dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) -> Result<(list: [ExamStudentDTO]?,id: Int), ExamServiceError> in
                // cast is needed for statuscode
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .failure(.serverError)
                }
                // check if answer is OK
                if httpResponse.statusCode != 200 {
                    print(String(data: data, encoding: .utf8) as Any)
                    sendNotification(titel: "Fehler",
                                     description: String(data: data, encoding: .utf8) ??
                        "\(httpResponse.statusCode)")
                    return .failure(.responseCode(code: httpResponse.statusCode))
                }
                // decode data and return it
                if let mimeType = response.mimeType,
                    mimeType == "application/json" {
                    do {
                        self.decoder.keyDecodingStrategy = .useDefaultKeys
                        self.decoder.dataDecodingStrategy = .base64
                        let answer: [ExamStudentDTO] = try self.decoder.decode([ExamStudentDTO].self, from: data)
                        print(String(data: data, encoding: .utf8) ?? "Daten sind nicht .uft8")
                        return .success((list: answer,id: examId))
                    } catch let decodeError {
                        print(String(data: data, encoding: .utf8) ?? "Daten sind nicht .uft8")
                        return .failure(.decoder(error: decodeError))
                    }
                }
                return .failure(.response(text: String(data: data, encoding: .utf8) ?? "Fehler" ))
        }
        .map { result -> AppAction in
            // if there is a result in the stream
            return .service(action: .getStudentListResult(result: result))
        }
        .replaceError(with:
            .service(action: .getStudentListResult(result: .failure(.serverError)))
        )
        .eraseToAnyPublisher()
    }
}
