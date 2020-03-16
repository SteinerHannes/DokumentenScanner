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

    func send(_ action: Action) {
        guard let effect = reducer(&states, action, environment) else {
            return
        }

        var didComplete = false
        var cancellable: AnyCancellable?

        cancellable = effect
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] _ in
                    didComplete = true
                    cancellable.map { self?.effectCancellables.remove($0) }
                }, receiveValue: send)
        if !didComplete, let cancellable = cancellable {
            effectCancellables.insert(cancellable)
        }
    }
}
