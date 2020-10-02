//
//  LogService.swift
//  DokumentenScanner
//
//  Created by Hannes Steiner on 01.10.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import Combine

enum LogServiceError: Error, LocalizedError {
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

struct SessionStart: Codable {
    let platform: String
    let startedAt: Date
}

struct SessionEnd: Encodable {
    let stoppedAt = Date()
}

struct SessionID: Codable {
    let id: Int
}

public struct Event: Codable {
    var name: String
    var time: Int64
    var duration: Int64
    var data: [String: String]
}

final class LogService {
    let baseUrl: String = baseAuthority + "/Session"

    let session: URLSession
    let encoder: JSONEncoder
    let decoder: JSONDecoder

    var id: Int?

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

    func startSession(date: Date) -> AnyPublisher<AppAction, Never> {
        if hasInternetConnection() == false {
            return Just(.log(action: .error(.serverError)))
            .eraseToAnyPublisher()
        }
        // chek if jwt exists
        guard let jwt = UserDefaults.standard.string(forKey: "JWT") else {
            return Just(.log(action: .error(.noJWT)))
            .eraseToAnyPublisher()
        }
        // prepare data
        let start = SessionStart(platform: "iOS", startedAt: date)
        // encode data
        self.encoder.dateEncodingStrategy = .iso8601
        guard let uploadData = try? self.encoder.encode(start) else {
            return AnyPublisher<AppAction, Never>(
                Just(.log(action: .error(.badEncoding)))
            )
        }
        guard let url = URL(string: baseUrl) else {
            return AnyPublisher<AppAction, Never>(
                Just(.log(action: .error(.badUrl)))
            )
        }
        var request = URLRequest(url: url)
        let authValue: String = "Bearer \(jwt)"
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Authorization": authValue]
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData
        debugPrint(String(decoding: uploadData, as: UTF8.self))

        return session.dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) -> Result<Int?, LogServiceError> in
                // cast is neede for statuscode
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .failure(.serverError)
                }
                // check if answer is OK
                if httpResponse.statusCode != 200 {
                    return .failure(.responseCode(code: httpResponse.statusCode))
                }
                // decode data and return it
                if let mimeType = response.mimeType,
                    mimeType == "application/json" {
                    do {
                        let answer: SessionID = try self.decoder.decode(SessionID.self, from: data)
                        self.id = answer.id
                        return .success(answer.id)
                    } catch let decodeError {
                        return .failure(.decoder(error: decodeError))
                    }
                }
                return .failure(.response(text: String(data: data, encoding: .utf8) ?? "Fehler" ))
            }
            .map { (result) -> AppAction in
                // if there is an result
                return .log(action: .startResult(result))
            }
            .replaceError(with:
                .log(action:
                    .error(.serverError)
                )
            )
            .eraseToAnyPublisher()
    }

    func stopSession(id: Int) -> AnyPublisher<AppAction, Never> {
        // prepare data
        let data = SessionEnd()
        // encode data
        guard let uploadData = try? self.encoder.encode(data) else {
            return AnyPublisher<AppAction, Never>(
                Just(.log(action: .error(.badEncoding)))
            )
        }
        guard let url = URL(string: baseUrl + "/\(id)") else {
            return AnyPublisher<AppAction, Never>(
                Just(.log(action: .error(.badUrl)))
            )
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData

        return session.dataTaskPublisher(for: request)
            .map { (_: Data, response: URLResponse) -> Result<Int?, LogServiceError> in
                // cast is neede for statuscode
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .failure(.serverError)
                }
                // check if answer is OK
                if httpResponse.statusCode != 200 {
                    return .failure(.responseCode(code: httpResponse.statusCode))
                }
                self.id = nil
                return .success(nil)
            }
            .map { (result) -> AppAction in
                // if there is an result
                return .log(action: .startResult(result))
            }
            .replaceError(with:
                .log(action:
                    .error(.serverError)
                )
            )
            .eraseToAnyPublisher()
    }

    func sendEvent(_ event: Event, id: Int) -> AnyPublisher<AppAction, Never> {
        // encode data
        guard let uploadData = try? self.encoder.encode(event) else {
            return AnyPublisher<AppAction, Never>(
                Just(.log(action: .error(.badEncoding)))
            )
        }
        guard let url = URL(string: baseUrl + "/\(id)/event") else {
            return AnyPublisher<AppAction, Never>(
                Just(.log(action: .error(.badUrl)))
            )
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData

        return session.dataTaskPublisher(for: request)
            .map { (_: Data, response: URLResponse) -> Result<Int?, LogServiceError> in
                // cast is neede for statuscode
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .failure(.serverError)
                }
                // check if answer is OK
                if httpResponse.statusCode != 200 {
                    return .failure(.responseCode(code: httpResponse.statusCode))
                }
                // MARK: TODO stupid, no need for any return type at success
                return .success(self.id)
            }
            .map { (result) -> AppAction in
                // if there is an result
                return .log(action: .startResult(result))
            }
            .replaceError(with:
                .log(action:
                    .error(.serverError)
                )
            )
            .eraseToAnyPublisher()
    }
}
