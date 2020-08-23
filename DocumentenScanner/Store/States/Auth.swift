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
    /// Triggers the WelcomeView if not logged in
    var isLoggedin: Bool = false
    /// Shows an Alert, when set
    var showAlert: AuthServiceError?
    /// Variable to trigger LoginView oder RegiserView
    var authView: AuthView?
}

enum AuthAction {
    /// Reset session and return to WelcomeView
    case logout
    /// Sets the showAlert to nil
    case dismissAlert
    /// Sets the view in the WelcomeView to Login or RegisterView
    case setView(view: AuthView?)
    /// Resets the authView to nil and therfore to the WelcomeView
    case clearView
    /// Is triggered, when the login button is pressed
    case login(email: String, password: String)
    /// Handels the result from the login function in auth service
    case loginResult(result: Result<LoginAnswer, AuthServiceError>)
    /// Is triggered, when the register button is pressed
    case register(email: String, name: String, password: String)
    /// Handels the result from the register function in auth service
    case registerResult(result: Result<StatusCode, AuthServiceError>)
}

/// The reducer of the auth state
/// for login, register and logout
func authReducer(state: inout AuthState, action: AuthAction, enviorment: AppEnviorment)
    -> AnyPublisher<AppAction, Never>? {
    switch action {
        case .logout:
            enviorment.deleteJWT()
            state.isLoggedin = false
            state.authView = nil
        case .dismissAlert:
            state.showAlert = nil
        case let .setView(view: view):
            state.authView = view
        case .clearView:
            state.authView = nil
        case let .login(email: email, password: password):
            return enviorment.auth.login(email: email, password: password)
        case let .loginResult(result: result):
            switch result {
                case let .success(answer):
                    state.isLoggedin = true
                    enviorment.setJWT(token: answer.jwt)
                    //print(answer.jwt)
                case let .failure(error):
                    state.showAlert = error
        }
        case let .register(email: email, name: name, password: password):
            return enviorment.auth.register(email: email, name: name, password: password)
        case let .registerResult(result: result):
            switch result {
                case let .success(code):
                    if code == 200 {
                        return Just<AppAction>(.auth(action: .setView(view: .login))).eraseToAnyPublisher()
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
