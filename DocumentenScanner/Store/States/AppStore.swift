//
//  AppStore.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 15.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

//swiftlint:disable switch_case_alignment cyclomatic_complexity
import Foundation
import Combine
import VisionKit

final class AppEnviorment {
    let session = URLSession.shared
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let files = FileManager.default

    var test: String = ""

    lazy var template = TemplateService()
    lazy var auth = AuthService(session: session, encoder: encoder, decoder: decoder)
}

/// The actions of the app state
enum AppAction {
    /// The routing reducer function
    case routing(action: RoutingAction)
    /// The reducer function for the new template
    case newTemplate(action: NewTemplateAction)
    case clearCurrentTemplate
    case setCurrentTemplate(id: String)
    case addNewTemplate(template: Template)
    case sendResult(pageNumber: Int, result: [PageRegion])
    case appendResult(at: Int)
    case initResult(array: [[PageRegion]?])
    case clearResult
    case setResult(page: Int, region: Int, text: String)
    case login(email: String, password: String)
    case test(text: String)
    case loginResult(result: Result<LoginAnswer, AuthServiceError>)
}

/// The new app state
struct AppStates {
    /// Variables for routing
    var routes: RoutingState
    /// Variables for the new template
    var newTemplateState: NewTemplateState
    /// The loaded templates
    var teamplates: [Template] = []
    /// The currently inspected template
    var currentTemplate: Template?

    var result: [[PageRegion]?] = []

    var jwt: String?

    init() {
        self.routes = RoutingState()
        self.newTemplateState = NewTemplateState()
    }

    init(template: Template) {
        self.routes = RoutingState()
        self.newTemplateState = NewTemplateState()
        self.teamplates.append(template)
    }
}

/// The reducer the handle the functionality of the app state actions
func appReducer(
    states: inout AppStates,
    action: AppAction,
    enviorment: AppEnviorment
) -> AnyPublisher<AppAction, Never>? {
    switch action {
        case let .routing(action: action):
            routingReducer(state: &states.routes, action: action)
        case let .newTemplate(action: action):
            newTemplateReducer(state: &states.newTemplateState, action: action)
        case let .addNewTemplate(template: template):
            states.teamplates.append(template)
//            for page in template.pages {
//                UIImageWriteToSavedPhotosAlbum(page.image, nil, nil, nil)
//            }
        case let .setCurrentTemplate(id: id):
            states.currentTemplate = states.teamplates.first(where: { template -> Bool in
                template.id == id
            })
        case .clearCurrentTemplate:
            states.currentTemplate = nil
        case let .sendResult(pageNumber: number, result: pageRegions):
            states.result[number] = pageRegions
        case let .appendResult(at: pageNumber):
            states.result[pageNumber] = []
        case let .initResult(array: nilPages):
            states.result = nilPages
        case .clearResult:
            states.result = []
        case let .setResult(page: page, region: region, text: text):
            states.result[page]![region].textResult = text
        case let .login(email: email, password: password):
            return enviorment.auth.login(email: email, password: password)
        case .test(text: let text):
            print(text)
        case let .loginResult(result: result):
            switch result {
                case let .success(answer):
                    print(answer.jwt)
                case let .failure(error):
                    print(error.localizedDescription)
        }
    }
    return Empty().eraseToAnyPublisher()
}

typealias AppStore = Store<AppStates, AppAction, AppEnviorment>
