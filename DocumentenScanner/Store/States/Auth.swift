//
//  Auth.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 01.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

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
}

func authReducer(state: inout AuthState, action: AuthAction) {
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
    }
}

enum AuthView: Int, Hashable {
    var id: Int {
        return self.rawValue
    }

    case register = 0
    case login = 1
}
