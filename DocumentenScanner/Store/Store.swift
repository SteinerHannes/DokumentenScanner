//
//  Store.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 15.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import UserNotifications
/// A typealias for the reducer function
typealias Reducer<State, Action, Environment> =
    (inout State, Action, Environment) -> AnyPublisher<Action, Never>?

/// The new store as single source of truth for every view
final class Store<State, Action, Environment>: ObservableObject {
    /// The read-only state
    @Published private(set) var states: State
    /// The reducer off the state
    private let reducer: Reducer<State, Action, Environment>
    /// The enviorment of the state
    private let environment: Environment
    private var effectCancellables: Set<AnyCancellable> = []

    init(
        initialState: State,
        reducer: @escaping Reducer<State, Action, Environment>,
        environment: Environment
    ) {
        self.states = initialState
        self.reducer = reducer
        self.environment = environment
    }

    /// The function for sending actions into the app store, for mutating the states
    func send(_ action: Action) {
        guard let effect = reducer(&states, action, environment) else {
            return
        }

        effect
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: send)
            .store(in: &effectCancellables)
    }
}

func sendNotification(titel: String, description: String) {

    let center = UNUserNotificationCenter.current()

    let addRequest = {
        let content = UNMutableNotificationContent()
        content.title = titel
        content.body = description
        let date = Date().addingTimeInterval(1)
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second],
                                                          from: date)

        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        center.add(request, withCompletionHandler: nil)
    }

    center.getNotificationSettings { settings in
        if settings.authorizationStatus == .authorized {
            print("go")
            addRequest()
        } else {
            center.requestAuthorization(options: [.alert, .badge, .sound]) { (success, _) in
                if success {
                    addRequest()
                } else {
                    print("...")
                }
            }
        }
    }
}
