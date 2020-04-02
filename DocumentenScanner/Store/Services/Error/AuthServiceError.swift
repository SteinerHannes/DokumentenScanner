//
//  AuthServiceError.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 01.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI

enum AuthServiceError: Error {
    case badUrl
    case badEncoding
    case decoder(error: Error)
    case error
    case responseCode(code: Int)
    case response(text: String)
}

extension AuthServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .badEncoding:
                return "badEncoding"
            case .badUrl:
                return "badURL"
            case let .decoder(error: error):
                return "decoder \(error.localizedDescription)"
            case .error:
                return "error"
            case let .responseCode(code: code):
                return "response \(code)"
            case let .response(text: text):
                return "response \(text)"
        }
    }
}

extension AuthServiceError: Identifiable {
    var id: Int {
        switch self {
            case .badEncoding:
                return 1
            case .badUrl:
                return 2
            case .decoder(error: _):
                return 3
            case .error:
                return 4
            case .responseCode(code: _):
                return 5
            case .response(text: _):
                return 6
        }
    }
}

extension AuthServiceError {
    var alert: Alert {
        switch self {
            case .badEncoding:
                return Alert(title: Text("Die Eingabedaten sind fehlerhaft."))
            case .badUrl:
                return Alert(title: Text("Keine Verbindung zum Server möglich."))
            case let .decoder(error: error):
                return Alert(title: Text("Decoder: \(error.localizedDescription)"))
            case .error:
                return Alert(title: Text("Server nicht erreichber"))
            case let .responseCode(code: code):
                switch code {
                    case 404:
                        return Alert(title: Text("E-Mail-Adresse nicht gefunden"))
                    case 401:
                        return Alert(title: Text("Passwort falsch"))
                    default:
                        return Alert(title: Text("Serverfehler: \(code)"))
            }
            case let .response(text: text):
                return Alert(title: Text("Serverfehler: \(text)"))
        }
    }
}
