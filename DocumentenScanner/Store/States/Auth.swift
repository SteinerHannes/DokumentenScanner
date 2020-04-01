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
}

enum AuthAction {
    case logout
    case dismissAlert
}

func authReducer(state: inout AuthState, action: AuthAction) {
    switch action {
        case .logout:
            state.isLoggedin = false
            state.jwt = nil
        case .dismissAlert:
            state.showAlert = nil
    }
}
