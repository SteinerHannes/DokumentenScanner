//
//  TemplateService.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 15.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

//swiftlint:disable function_parameter_count
import Foundation
import Combine

enum TemplateServiceError: Error {
    case badUrl
    case badEncoding
    case decoder(error: Error)
    case serverError
    case responseCode(code: Int)
    case response(text: String)
    case noJWT
}

final class TemplateService {
    let baseUrl: String = baseAuthority

    let session: URLSession
    let encoder: JSONEncoder
    let decoder: JSONDecoder

    init(session: URLSession, encoder: JSONEncoder, decoder: JSONDecoder) {
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
    }

    func createTemplate(name: String, description: String) -> AnyPublisher<AppAction, Never> {
        // chek if jwt exists
        if session.configuration.httpAdditionalHeaders?["Authorization"] == nil {
            return AnyPublisher<AppAction, Never>(
                Just(.service(action: .createTeamplateResult(result: .failure(.noJWT))))
            )
        }

        // prepare data for uplaod
        let template = TemplateEditDTO(name: name, description: description)
        // encode data
        guard let uploadData = try? self.encoder.encode(template) else {
            return AnyPublisher<AppAction, Never>(
                Just(.service(action: .createTeamplateResult(result: .failure(.badEncoding))))
            )
        }
        // configure an uplaod request
        guard let url = URL(string: baseUrl + "template" ) else {
            return AnyPublisher<AppAction, Never>(
                Just(.service(action: .createTeamplateResult(result: .failure(.badUrl))))
            )
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData

        // create and start an uplaod task
        return session.dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) -> Result<TemplateDTO, TemplateServiceError> in
                // cast is needed for statuscode
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
                        let answer: TemplateDTO = try self.decoder.decode(TemplateDTO.self, from: data)
                        return .success(answer)
                    } catch let decodeError {
                        print(String(data: data, encoding: .utf8) ?? "Daten sind nicht .uft8")
                        return .failure(.decoder(error: decodeError))
                    }
                }
                return .failure(.response(text: String(data: data, encoding: .utf8) ?? "Fehler" ))
        }
        .map { result -> AppAction in
            // if there is a result in the stream
            return .service(action: .createTeamplateResult(result: result))
        }
        .replaceError(with:
            .service(action: .createTeamplateResult(result: .failure(.serverError)))
        )
        .eraseToAnyPublisher()
    }

    func createPage(id: Int, number: Int, imagePath: String) -> AnyPublisher<AppAction, Never> {
        // chek if jwt exists
        if session.configuration.httpAdditionalHeaders?["Authorization"] == nil {
            return AnyPublisher<AppAction, Never>(
                Just(.service(action: .createPageResult(result: .failure(.noJWT))))
            )
        }
        // prepare data for uplaod
        let page = PageCreateDTO(templateID: id, number: number, imagePath: imagePath)
        // encode data
        guard let uploadData = try? self.encoder.encode(page) else {
            return AnyPublisher<AppAction, Never>(
                Just(.service(action: .createPageResult(result: .failure(.badEncoding))))
            )
        }
        // configure an uplaod request
        guard let url = URL(string: baseUrl + "page" ) else {
            return AnyPublisher<AppAction, Never>(
                Just(.service(action: .createPageResult(result: .failure(.badUrl))))
            )
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData

        // create and start an uplaod task
        return session.dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) -> Result<PageDTO, TemplateServiceError> in
                // cast is needed for statuscode
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
                        let answer: PageDTO = try self.decoder.decode(PageDTO.self, from: data)
                        return .success(answer)
                    } catch let decodeError {
                        print(String(data: data, encoding: .utf8) ?? "Daten sind nicht .uft8")
                        return .failure(.decoder(error: decodeError))
                    }
                }
                return .failure(.response(text: String(data: data, encoding: .utf8) ?? "Fehler" ))
        }
        .map { result -> AppAction in
            // if there is a result in the stream
            return .service(action: .createPageResult(result: result))
        }
        .replaceError(with:
            .service(action: .createPageResult(result: .failure(.serverError)))
        )
            .eraseToAnyPublisher()
    }

    func createAttribute(name: String, x: Int, y: Int, width: Int,
                         height: Int, dataType: String, pageId: Int) -> AnyPublisher<AppAction, Never> {
        // chek if jwt exists
        if session.configuration.httpAdditionalHeaders?["Authorization"] == nil {
            return AnyPublisher<AppAction, Never>(
                Just(.service(action: .createPageResult(result: .failure(.noJWT))))
            )
        }
        // prepare data for uplaod
        let attribute = AttributeCreateDTO(name: name, x: x, y: y, width: width,
                                           height: height, dataType: dataType, pageId: pageId)
        // encode data
        guard let uploadData = try? self.encoder.encode(attribute) else {
            return AnyPublisher<AppAction, Never>(
                Just(.service(action: .createAttributeResult(result: .failure(.badEncoding))))
            )
        }
        // configure an uplaod request
        guard let url = URL(string: baseUrl + "attribute" ) else {
            return AnyPublisher<AppAction, Never>(
                Just(.service(action: .createAttributeResult(result: .failure(.badUrl))))
            )
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = uploadData

        // create and start an uplaod task
        return session.dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) -> Result<AttributeDTO, TemplateServiceError> in
                // cast is needed for statuscode
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
                        let answer: AttributeDTO = try self.decoder.decode(AttributeDTO.self, from: data)
                        return .success(answer)
                    } catch let decodeError {
                        print(String(data: data, encoding: .utf8) ?? "Daten sind nicht .uft8")
                        return .failure(.decoder(error: decodeError))
                    }
                }
                return .failure(.response(text: String(data: data, encoding: .utf8) ?? "Fehler" ))
        }
        .map { result -> AppAction in
            // if there is a result in the stream
            return .service(action: .createAttributeResult(result: result))
        }
        .replaceError(with:
            .service(action: .createAttributeResult(result: .failure(.serverError)))
        )
            .eraseToAnyPublisher()
    }
}
