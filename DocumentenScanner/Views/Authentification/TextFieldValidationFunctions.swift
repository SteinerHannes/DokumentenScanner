//
//  TextFieldValidationFunctions.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 02.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

public func validateEmail(email: String) -> Bool {
    let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}(\\s*){2,64}"
    let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
    return predicate.evaluate(with: email)
}
//swiftlint:disable line_length
public func validatePassword(password: String) -> Bool {
    let regex = "^((?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])|(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[^a-zA-Z0-9])|(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[^a-zA-Z0-9])|(?=.*?[a-z])(?=.*?[0-9])(?=.*?[^a-zA-Z0-9])).{8,}$"
    let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
    return predicate.evaluate(with: password)
}
//swiftlint:enable line_length
public func validateName(name: String) -> Bool {
    let regex = "[A-Za-z\\s]{3,256}"
    let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
    return predicate.evaluate(with: name)
}
