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

typealias Reducer<State, Action, Environment> =
    (inout State, Action, Environment) -> AnyPublisher<Action, Never>?

func lift<State, Action, Environment, LiftedState, LiftedAction, LiftedEnvironment>(
    reducer: @escaping Reducer<LiftedState, LiftedAction, LiftedEnvironment>,
    keyPath: WritableKeyPath<State, LiftedState>,
    extractAction: @escaping (Action) -> LiftedAction?,
    embedAction: @escaping (LiftedAction) -> Action,
    extractEnvironment: @escaping (Environment) -> LiftedEnvironment
) -> Reducer<State, Action, Environment> {
    return { state, action, environment in
        let environment = extractEnvironment(environment)
        guard let action = extractAction(action) else {
            return nil
        }
        let effect = reducer(&state[keyPath: keyPath], action, environment)
        return effect.map { $0.map(embedAction).eraseToAnyPublisher() }
    }
}

func combine<State, Action, Environment>(
    _ reducers: Reducer<State, Action, Environment>...
) -> Reducer<State, Action, Environment> {
    return { state, action, environment -> AnyPublisher<Action, Never>? in
        let effects = reducers.compactMap { $0(&state, action, environment) }
        return Publishers
            .Sequence(sequence: effects)
            .flatMap { $0 }
            .eraseToAnyPublisher()
    }
}

/// The new store as single source of truth for every view
final class Store<State, Action, Environment>: ObservableObject {
    /// The read-only state
    @Published private(set) var states: State
    /// The reducer off the state
    private let reducer: Reducer<State, Action, Environment>
    /// The enviorment of the state
    private let environment: Environment

    private var effectCancellables: Set<AnyCancellable> = []
    private var projectionCancellable: AnyCancellable?

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

    func projection<ProjectedState, ProjectedAction>(
        projectState: @escaping (State) -> ProjectedState,
        projectAction: @escaping (ProjectedAction) -> Action
    ) -> Store<ProjectedState, ProjectedAction, Void> {
        let store = Store<ProjectedState, ProjectedAction, Void>(
            initialState: projectState(states),
            reducer: { _, action, _ in
                self.send(projectAction(action))
                return nil
        },
            environment: ()
        )

        store.projectionCancellable = $states
            .map(projectState)
            .assign(to: \.states, on: store)

        return store
    }
}

extension Store {
    func binding<Value>(
        for keyPath: KeyPath<State, Value>,
        toAction: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding<Value>(
            get: { self.states[keyPath: keyPath] },
            set: { self.send(toAction($0)) }
        )
    }
}
