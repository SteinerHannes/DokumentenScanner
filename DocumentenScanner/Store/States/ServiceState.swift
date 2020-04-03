//
//  ServiceState.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 02.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

//swiftlint:disable cyclomatic_complexity
import Foundation
import Combine

struct ServiceState {
    var templateId: Int?
    var pageId: Int?
}

enum ServiceAction {
    case createTemplate(name: String, description: String)
    case test(text: String)
    case createTeamplateResult(result: Result<TemplateDTO, TemplateServiceError>)
    case createPage(templateId: Int, number: Int, imagePath: String)
    case createPageResult(result: Result<PageDTO, TemplateServiceError>)
    case createAttribute(name: String, x: Int, y: Int, width: Int, height: Int, dataType: String, pageId: Int)
    case createAttributeResult(result: Result<AttributeDTO, TemplateServiceError>)
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
            case let .createPage(templateId: id, number: number, imagePath: imagePath):
                return enviorment.template.createPage(id: id, number: number, imagePath: imagePath)
            case .createPageResult(result: let result):
                switch result {
                    case let .success(page):
                        states.serviceState.pageId = page.id
                        print("page erstellt", page.id)
                    case let .failure(error):
                        print("page fehler:", error)
                }
            case let .createAttribute(name: name, x: x, y: y, width: width,
                                      height: height, dataType: dataType, pageId: pageId):
                return enviorment.template.createAttribute(name: name, x: x, y: y, width: width,
                                                    height: height, dataType: dataType, pageId: pageId)
            case let .createAttributeResult(result: result):
                switch result {
                    case let .success(attribute):
                        print("attribute erstellt:", attribute.name)
                    case let .failure(error):
                        print("attribute fehler:", error)
                }
        }
        return Empty().eraseToAnyPublisher()
}
