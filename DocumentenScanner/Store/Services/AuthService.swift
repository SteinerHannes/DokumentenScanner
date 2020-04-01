//
//  AuthService.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 30.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import Combine

enum AuthServiceError: Error, LocalizedError {
    case badUrl
    case badEncoding
    case url(error: URLError)
    case decoder(error: Error)
    case error
    case responseCode(code: Int)
    case response(text: String)

    var errorDescription: String? {
        switch self {
            case .badEncoding:
                return "badEncoding"
            case .badUrl:
                return "badURL"
            case let .decoder(error: error):
                return "decoder \(error.localizedDescription)"
            case let .url(error: error):
                return "url \(error.localizedDescription)"
            case .error:
                return "error"
            case let .responseCode(code: code):
                return "response \(code)"
            case let .response(text: text):
                return "response \(text)"
        }
    }
}

struct LoginAnswer: Decodable {
    let jwt: String
}

final class AuthService {
    let baseUrl: String = "http://192.168.178.79:5000/auth/"

    let session: URLSession
    let encoder: JSONEncoder
    let decoder: JSONDecoder

    init(session: URLSession, encoder: JSONEncoder, decoder: JSONDecoder) {
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
    }

    func login(email: String, password: String) -> AnyPublisher<AppAction, Never> {
        // prepare data for uplaod
        let login = LoginDTO(email: email, password: password)

        guard let uploadData = try? JSONEncoder().encode(login) else {
            return AnyPublisher<AppAction, Never>(Just(.loginResult(result: .failure(.badEncoding))))
        }

        // configure an uplaod request
        guard let url = URL(string: baseUrl + "login") else {
            return AnyPublisher<AppAction, Never>(Just(.loginResult(result: .failure(.badUrl))))
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData

        // create and start an uplaod task
        return session.dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) -> Result<LoginAnswer, AuthServiceError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                        return .failure(.error)
                }
                if httpResponse.statusCode != 200 {
                    return .failure(.responseCode(code: httpResponse.statusCode))
                }
                if let mimeType = response.mimeType,
                    mimeType == "application/json" {
                    do {
                        let answer: LoginAnswer = try self.decoder.decode(LoginAnswer.self, from: data)
                        return .success(answer)
                    } catch let decodeError {
                        return .failure(.decoder(error: decodeError))
                    }
                }
                return .failure(.response(text: String(data: data, encoding: .utf8) ?? "Fehler" ))
            }
            .map { (result) -> AppAction in
                return .loginResult(result: result)
            }
            .replaceError(with: .loginResult(result: Result<LoginAnswer, AuthServiceError>.failure(.badUrl)))
            .eraseToAnyPublisher()
    }
}
