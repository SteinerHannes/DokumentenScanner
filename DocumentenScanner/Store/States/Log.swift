//
//  Log.swift
//  DokumentenScanner
//
//  Created by Hannes Steiner on 29.07.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import Combine

struct NavigationLog {
    var text: String
    var date: Date = Date()

    init(_ text: String) {
        self.text = text
    }
}

struct LogState {
    var navigationLog: [NavigationLog] = []
    var isLoggin: Bool = true
}

enum LogAction {
    case navigation(String)
    case start
    case stop
}

func logReducer(state: inout LogState, action: LogAction, enviorment: AppEnviorment)
-> AnyPublisher<AppAction, Never>? {
    switch action {
        case .navigation( let text):
            print("LOG:" + text)
            state.navigationLog.append(.init(text))
        case .start:
            state.isLoggin = true
        case .stop:
            state.isLoggin = false
    }
    return Empty().eraseToAnyPublisher()
}
