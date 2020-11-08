//
//  Log.swift
//  DokumentenScanner
//
//  Created by Hannes Steiner on 29.07.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import Combine

struct LogState {
    var isLoggin: Bool = true
    var date: Date?
    var id: Int?
}

enum LogAction {
    case changeField(name: String, from: String, to: String)
    case navigation(String)
    case start
    case stop
    case startResult(Result<Int?, LogServiceError>)
    case error(LogServiceError)
}
//swiftlint:disable cyclomatic_complexity
func logReducer(state: inout LogState, action: LogAction, enviorment: AppEnviorment)
-> AnyPublisher<AppAction, Never>? {
    switch action {
        case let .changeField(name: name, from: from, to: to):
            guard let date = state.date, let id = state.id else {
                return Empty().eraseToAnyPublisher()
            }
            let time = Int64((date.timeIntervalSinceNow * 1000.0).rounded()) * -1
            let event = Event(name: "INPUT", time: time, duration: 0, data: ["type":name,"from":from,"to":to])
            return enviorment.log.sendEvent(event, id: id)
        case .navigation(let text):
            guard let date = state.date, let id = state.id else {
                return Empty().eraseToAnyPublisher()
            }
            let time = Int64((date.timeIntervalSinceNow * 1000.0).rounded()) * -1
            let event = Event(name: "NAVIGATION", time: time, duration: 0, data: ["to":text])
            return enviorment.log.sendEvent(event, id: id)
        case .start:
            state.date = Date()
            state.isLoggin = true
            return enviorment.log.startSession(date: state.date!)
        case .stop:
            state.isLoggin = false
            state.date = nil
            guard let id = state.id else {
                return Empty().eraseToAnyPublisher()
            }
            return enviorment.log.stopSession(id: id)
        case let .startResult(result):
            switch result {
                case let .success(id):
                    if id != nil && state.id == nil {
                        sendNotification(titel: "Log gestartet", description: "SessionID: \(id!)")
                    } else if id == nil && state.id != nil {
                        sendNotification(titel: "Log beendet", description: "SessionID: \(state.id!)")
                    }
                    state.id = id
                case let .failure(error):
                    print(error)
            }
        case let .error(error):
            print(error.localizedDescription )
    }
    return Empty().eraseToAnyPublisher()
}
