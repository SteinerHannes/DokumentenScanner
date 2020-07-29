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
}

enum LogAction {
    case navigation(String)
}

func logReducer(state: inout LogState, action: LogAction, enviorment: AppEnviorment) -> AnyPublisher<AppAction, Never>? {
    switch action {
        case .navigation( let text):
            print("LOG:" + text)
            state.navigationLog.append(.init(text))
    }
    return Empty().eraseToAnyPublisher()
}
