//
//  Auth.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 01.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

//swiftlint:disable switch_case_alignment cyclomatic_complexity
import Foundation
import Combine

struct AuthState {
    var jwt: String?
    var isLoggedin: Bool = false
    var showAlert: AuthServiceError?
    var authView: AuthView?
}

enum AuthAction {
    case logout
    case dismissAlert
    case setView(view: AuthView?)
    case clearView
    case login(email: String, password: String)
    case loginResult(result: Result<LoginAnswer, AuthServiceError>)
    case register(email: String, name: String, password: String)
    case registerResult(result: Result<StatusCode, AuthServiceError>)
}

func authReducer(state: inout AuthState, action: AuthAction, enviorment: AppEnviorment)
    -> AnyPublisher<AppAction, Never>? {
    switch action {
        case .logout:
            state.isLoggedin = false
            state.jwt = nil
            state.authView = nil
        case .dismissAlert:
            state.showAlert = nil
        case let .setView(view: view):
            state.authView = view
        case .clearView:
            state.authView = nil
        case let .login(email: email, password: password):
            // returns an AppAction, which will get called
            return enviorment.auth.login(email: email, password: password)
        case let .loginResult(result: result):
            switch result {
                case let .success(answer):
                    print(answer.jwt)
                    state.isLoggedin = true
                    state.jwt = answer.jwt
                    enviorment.setJWT(token: answer.jwt)
                case let .failure(error):
                    state.showAlert = error
        }
        case let .register(email: email, name: name, password: password):
            return enviorment.auth.register(email: email, name: name, password: password)
        case let .registerResult(result: result):
            switch result {
                case let .success(code):
                    if code == 200 {
                        print("Registriert!")
                        return AnyPublisher(Just<AppAction>(.auth(action: .setView(view: .login))))
                }
                case let .failure(error):
                    state.showAlert = error
        }
    }

    return Empty().eraseToAnyPublisher()
}

enum AuthView: Int, Hashable {
    var id: Int {
        return self.rawValue
    }

    case register = 0
    case login = 1
}
