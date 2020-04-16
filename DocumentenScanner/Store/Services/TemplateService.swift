//
//  TemplateService.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 15.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

//swiftlint:disable function_parameter_count function_body_length
import Foundation
import Combine
import VisionKit

struct ImageResponse: Decodable {
    public let path: String
}

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

    private func hasInternetConnection() -> Bool {
        let status = Reach().connectionStatus()
        switch status {
            case .offline, .unknown:
                return false
            default:
                return true
        }
    }

    func getTemplateList() -> AnyPublisher<AppAction, Never> {
        if hasInternetConnection() == false {
            return Just(.service(action: .getTemplateListResult(result: .failure(.serverError))))
                .eraseToAnyPublisher()
        }
        // configure an uplaod request
        guard let url = URL(string: baseUrl + "/template" ) else {
            return Just(.service(action: .getTemplateListResult(result: .failure(.badUrl))))
                .eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return session.dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) -> Result<[Template], TemplateServiceError> in
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
                        self.decoder.keyDecodingStrategy = .useDefaultKeys
                        self.decoder.dataDecodingStrategy = .base64
                        let answer: [Template] = try self.decoder.decode([Template].self, from: data)
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
            return .service(action: .getTemplateListResult(result: result))
        }
        .replaceError(with:
            .service(action: .getTemplateListResult(result: .failure(.serverError)))
        )
        .eraseToAnyPublisher()

    }

    func createTemplate(name: String, description: String, links: [Link]) -> AnyPublisher<AppAction, Never> {
        if hasInternetConnection() == false {
            return Just(.service(action: .createTeamplateResult(result: .failure(.serverError))))
                .eraseToAnyPublisher()
        }
        // chek if jwt exists
        guard let jwt = UserDefaults.standard.string(forKey: "JWT") else {
            return Just(.service(action: .createTeamplateResult(result: .failure(.noJWT))))
                .eraseToAnyPublisher()
        }
        let linkArray: [LinkDTO] = links.map { (link) -> LinkDTO in
            return LinkDTO(id: link.id, linktype: link.linktype.rawValue, regionIDs: link.regionIDs)
        }
        guard let linkJson = try? self.encoder.encode(LinksDTO(links: linkArray)) else {
            return Just(.service(action: .createTeamplateResult(result: .failure(.badEncoding))))
                .eraseToAnyPublisher()
        }
        guard let extra = String(data: linkJson, encoding: .utf8) else {
            return Just(.service(action: .createTeamplateResult(result: .failure(.badEncoding))))
                .eraseToAnyPublisher()
        }
        // prepare data for uplaod
        let template = TemplateEditDTO(name: name, description: description, extra:  extra)
        print(template)
        // encode data
        guard let uploadData = try? self.encoder.encode(template) else {
            return Just(.service(action: .createTeamplateResult(result: .failure(.badEncoding))))
                .eraseToAnyPublisher()
        }
        // configure an uplaod request
        guard let url = URL(string: baseUrl + "/template" ) else {
            return Just(.service(action: .createTeamplateResult(result: .failure(.badUrl))))
                .eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let authValue: String = "Bearer \(jwt)"
        request.allHTTPHeaderFields = ["Authorization": authValue]
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
                    print(String(data: data, encoding: .utf8) as Any)
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
        if hasInternetConnection() == false {
            return Just(.service(action: .createTeamplateResult(result: .failure(.serverError))))
                .eraseToAnyPublisher()
        }
        // chek if jwt exists
        guard let jwt = UserDefaults.standard.string(forKey: "JWT") else {
            return Just(.service(action: .createTeamplateResult(result: .failure(.noJWT))))
                .eraseToAnyPublisher()
        }
        // prepare data for uplaod
        let page = PageCreateDTO(templateID: id, number: number, imagePath: imagePath)
        // encode data
        guard let uploadData = try? self.encoder.encode(page) else {
            return Just(.service(action: .createPageResult(result: .failure(.badEncoding))))
                .eraseToAnyPublisher()
        }
        // configure an uplaod request
        guard let url = URL(string: baseUrl + "/page" ) else {
            return Just(.service(action: .createPageResult(result: .failure(.badUrl))))
                .eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let authValue: String = "Bearer \(jwt)"
        request.allHTTPHeaderFields = ["Authorization": authValue]
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
                    print(String(data: data, encoding: .utf8) as Any)
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
        if hasInternetConnection() == false {
            return Just(.service(action: .createTeamplateResult(result: .failure(.serverError))))
                .eraseToAnyPublisher()
        }
        // chek if jwt exists
        guard let jwt = UserDefaults.standard.string(forKey: "JWT") else {
            return Just(.service(action: .createTeamplateResult(result: .failure(.noJWT))))
                .eraseToAnyPublisher()
        }
        // prepare data for uplaod
        let attribute = AttributeCreateDTO(name: name, x: x, y: y, width: width,
                                           height: height, dataType: dataType, pageId: pageId)
        // encode data
        guard let uploadData = try? self.encoder.encode(attribute) else {
            return Just(.service(action: .createAttributeResult(result: .failure(.badEncoding))))
                .eraseToAnyPublisher()
        }
        // configure an uplaod request
        guard let url = URL(string: baseUrl + "/attribute" ) else {
            return Just(.service(action: .createAttributeResult(result: .failure(.badUrl))))
                .eraseToAnyPublisher()
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let authValue: String = "Bearer \(jwt)"
        request.allHTTPHeaderFields = ["Authorization": authValue]
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
                    print(String(data: data, encoding: .utf8) as Any)
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

    func uploadImage(image: UIImage) -> AnyPublisher<AppAction, Never> {
        if hasInternetConnection() == false {
            return Just(.service(action: .uploadImageResult(result: .failure(.serverError))))
                .eraseToAnyPublisher()
        }
        // chek if jwt exists
        guard let jwt = UserDefaults.standard.string(forKey: "JWT") else {
            return Just(.service(action: .createTeamplateResult(result: .failure(.noJWT))))
                .eraseToAnyPublisher()
        }
        guard let data = image.pngData() else {
            return Just(.service(action: .uploadImageResult(result: .failure(.badEncoding))))
                .eraseToAnyPublisher()
        }
        // configure an uplaod request
        guard let url = URL(string: baseUrl + "/Image/upload" ) else {
            return Just(.service(action: .uploadImageResult(result: .failure(.badUrl))))
                .eraseToAnyPublisher()
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

        // create and start an uplaod task
        return session.dataTaskPublisher(for: request)
            .map { (data: Data, response: URLResponse) -> Result<String, TemplateServiceError> in
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
            return .service(action: .uploadImageResult(result: result))
        }
        .replaceError(with:
            .service(action: .uploadImageResult(result: .failure(.serverError)))
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

extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            self.append(data)
        }
    }
}
