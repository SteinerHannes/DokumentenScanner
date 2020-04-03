//
//  ServiceState.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 02.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import Combine

struct ServiceState {
    var templateId: Int?

}

enum ServiceAction {
    case createTemplate(name: String, description: String)
    case test(text: String)
    case createTeamplateResult(result: Result<TemplateDTO, TemplateServiceError>)
}

func serviceReducer(states: inout AppStates, action: ServiceAction, enviorment: AppEnviorment)
    -> AnyPublisher<AppAction, Never>? {
        switch action {
            case let .test(text: text):
                print(text)
            case let .createTemplate(name: name, description: description):
                return enviorment.template.createTemplate(name: name, description: description)
            case let .createTeamplateResult(result: result):
                switch result {
                    case let .success(template):
                        states.serviceState.templateId = template.id
                        print("erstelltes Template hat die id:", template.id)
                    case let .failure(error):
                        print("fehler", error)
            }
        }
        return Empty().eraseToAnyPublisher()
}
