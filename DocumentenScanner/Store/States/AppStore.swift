//
//  AppStore.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 15.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

//swiftlint:disable switch_case_alignment
import Foundation
import Combine
import VisionKit

final class AppEnviorment {
    /// Global session
    var session = URLSession.shared
    /// Global decoder
    let decoder = JSONDecoder()
    /// Global encoder
    let encoder = JSONEncoder()

    /// The api service for managing templates, pages and attributes
    lazy var template = TemplateService(session: session, encoder: encoder, decoder: decoder)
    /// The api service for managing login and logout
    lazy var auth = AuthService(session: session, encoder: encoder, decoder: decoder)

    lazy var ocr = OCRService(session: session, encoder: encoder, decoder: decoder)

    /// Set a auth token into the global session
    func setJWT(token: String) {
        let defaults = UserDefaults.standard
        defaults.set(token, forKey: "JWT")
    }

    func deleteJWT() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "JWT")
    }
}

public typealias StatusCode = Int

/// The actions of the app state
enum AppAction {
    /// The routing reducer function
    case routing(action: RoutingAction)
    /// The reducer function for the new template
    case newTemplate(action: NewTemplateAction)
    /// The reducer function for login. register and logout
    case auth(action: AuthAction)
    /// The reducer function for API-Services
    case service(action: ServiceAction)
    /// The reducer function for OCR-Service
    case ocr(action: OCRAction)
    /// Clears the variables of the cuurent selected template
    case clearCurrentTemplate
    /// Sets the current template in the state
    case setCurrentTemplate(id: String)
    /// Adds a new template to the temaplte list
    case addNewTemplate(template: Template)
    /// Sets the cached image, for the image in the page
    case setImage(page: Int, image: UIImage?)
}

/// The new app state
struct AppStates {
    /// Variables for routing
    var routes: RoutingState
    /// Variables for the new template
    var newTemplateState: NewTemplateState
    /// Variables for authentification
    var authState: AuthState

    var serviceState: ServiceState

    var ocrState: OCRState
    /// The loaded templates
    var teamplates: [Template] = []
    /// The currently inspected template
    var currentTemplate: Template?

    init() {
        self.routes = RoutingState()
        self.newTemplateState = NewTemplateState()
        self.authState = AuthState()
        self.serviceState = ServiceState()
        self.ocrState = OCRState()
    }

    init(template: Template) {
        self.routes = RoutingState()
        self.newTemplateState = NewTemplateState()
        self.authState = AuthState()
        self.serviceState = ServiceState()
        self.ocrState = OCRState()
        self.teamplates.append(template)
    }
}

/// The reducer the handle the functionality of the app state actions
func appReducer(
    states: inout AppStates,
    action: AppAction,
    environment: AppEnviorment
) -> AnyPublisher<AppAction, Never>? {
    switch action {
        case let .routing(action: action):
            routingReducer(state: &states.routes, action: action)

        case let .newTemplate(action: action):
            newTemplateReducer(state: &states.newTemplateState, action: action)

        case let .auth(action: action):
            return authReducer(state: &states.authState, action: action, enviorment: environment)

        case let .service(action: action):
            return serviceReducer(states: &states, action: action, enviorment: environment)

        case let .ocr(action: action):
            return ocrReducer(state: &states.ocrState, action: action,
                              enviorment: environment, template: states.currentTemplate)

        case let .addNewTemplate(template: template):
            states.teamplates.append(template)

        case let .setCurrentTemplate(id: id):
            states.currentTemplate = states.teamplates.first(where: { template -> Bool in
                template.id == id
            })

        case .clearCurrentTemplate:
            states.currentTemplate = nil

        case let .setImage(page: page, image: image):
            states.currentTemplate!.pages[page]._image = image
            let index = states.teamplates.firstIndex { (template) -> Bool in
                states.currentTemplate!.id == template.id
            }!
            states.teamplates[index].pages[page]._image = image
    }
    return Empty().eraseToAnyPublisher()
}

typealias AppStore = Store<AppStates, AppAction, AppEnviorment>

typealias OCRCallback = ([OcrResult]) -> Void

typealias OCRApi = (String, OCRCallback) -> Void

let ocrApi: OCRApi = { id, callback in
    let ocrresult: [OcrResult] = []
    callback(ocrresult)
}

typealias Dispatcher = (AppAction) -> Void
