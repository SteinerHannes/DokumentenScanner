//
//  AuthService.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 30.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import Combine

struct LoginAnswer: Decodable {
    let jwt: String
}

struct ErrorAnswer: Decodable {
    let error: String
}

final class AuthService {
    let baseUrl: String = baseAuthority + "/auth"

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
        // encode data
        guard let uploadData = try? self.encoder.encode(login) else {
            return AnyPublisher<AppAction, Never>(
                Just(.auth(action: .loginResult(result: .failure(.badEncoding))))
            )
        }
        // configure an uplaod request
        guard let url = URL(string: baseUrl + "/login") else {
            return AnyPublisher<AppAction, Never>(
                Just(.auth(action: .loginResult(result: .failure(.badUrl))))
            )
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData

        // create and start an uplaod task
        return session.dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) -> Result<LoginAnswer, AuthServiceError> in
                // cast is neede for statuscode
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("123")
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
                        let answer: LoginAnswer = try self.decoder.decode(LoginAnswer.self, from: data)
                        return .success(answer)
                    } catch let decodeError {
                        return .failure(.decoder(error: decodeError))
                    }
                }
                return .failure(.response(text: String(data: data, encoding: .utf8) ?? "Fehler" ))
            }
            .map { (result) -> AppAction in
                // if there is an AppAction
                return .auth(action: .loginResult(result: result))
            }
            .replaceError(with:
                .auth(action:
                    .loginResult(result: Result<LoginAnswer, AuthServiceError>.failure(.serverError))
                )
            )
            .eraseToAnyPublisher()
    }

    func register(email: String, name: String, password: String) -> AnyPublisher<AppAction, Never> {
        // prepare data for uplaod
        let register: RegisterDTO = RegisterDTO(email: email, username: name, password: password)
        // encode data
        guard let uploadData = try? self.encoder.encode(register) else {
            return AnyPublisher<AppAction, Never>(
                Just(.auth(action: .registerResult(result: .failure(.badEncoding))))
            )
        }
        guard let url = URL(string: baseUrl + "/register") else {
            return AnyPublisher<AppAction, Never>(
                Just(.auth(action: .registerResult(result: .failure(.badUrl))))
            )
        }
        print(url.absoluteURL)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData

        // create and start an uplaod task
        return session.dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) -> Result<StatusCode, AuthServiceError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return .failure(.serverError)
                }
                if httpResponse.statusCode == 200 {
                    return .success(200)
                }
                if let mimeType = response.mimeType,
                    mimeType == "application/json" {
                    do {
                        let answer: ErrorAnswer = try self.decoder.decode(ErrorAnswer.self, from: data)
                        if answer.error == "Email exists" {
                            return .failure(.response(text: "Diese E-Mail existiert bereits."))
                        } else if answer.error == "Username exists" {
                            return .failure(.response(text: "Dieser Name ist bereits vergeben."))
                        } else {
                            return .failure(.response(text: answer.error))
                        }

                    } catch let decodeError {
                        return .failure(.decoder(error: decodeError))
                    }
                }
                return .failure(.response(text: String(data: data, encoding: .utf8) ?? "Fehler" ))
        }
        .map { (result) -> AppAction in
            return .auth(action: .registerResult(result: result))
        }
        .replaceError(with:
            .auth(action: .registerResult(result: Result<StatusCode, AuthServiceError>.failure(.serverError)))
        )
        .eraseToAnyPublisher()
    }
}
