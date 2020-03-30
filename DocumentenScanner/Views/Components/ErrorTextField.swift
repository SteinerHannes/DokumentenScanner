//
//  ErrorTextField.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 30.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

//swiftlint:disable multiple_closures_with_trailing_closure
struct ErrorTextField: View {
    @State var isPasswordVisible: Bool = false

    let title: String
    let placeholder: String
    let iconName: String
    let text: Binding<String>
    let isFirstResponder: Bool
    let keyboardType: UIKeyboardType
    let isSecure: Bool
    var textContentType: UITextContentType?
    let isValid: (String) -> Bool

    init(title: String,
         placeholder: String,
         iconName: String,
         text: Binding<String>,
         isFirstResponder: Bool,
         keyboardType: UIKeyboardType = UIKeyboardType.default,
         isSecure: Bool,
         isValid: @escaping (String) -> Bool = { _ in true}) {

        self.title = title
        self.placeholder = placeholder
        self.iconName = iconName
        self.text = text
        self.isFirstResponder = isFirstResponder
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.isValid = isValid
    }

    init(title: String,
         placeholder: String,
         iconName: String,
         text: Binding<String>,
         isFirstResponder: Bool,
         keyboardType: UIKeyboardType = UIKeyboardType.default,
         isSecure: Bool,
         textContentType: UITextContentType,
         isValid: @escaping (String) -> Bool = { _ in true}) {

        self.title = title
        self.placeholder = placeholder
        self.iconName = iconName
        self.text = text
        self.isFirstResponder = isFirstResponder
        self.keyboardType = keyboardType
        self.isSecure = isSecure
        self.textContentType = textContentType
        self.isValid = isValid
    }

    var showsError: Bool {
        if text.wrappedValue.isEmpty {
            return false
        } else {
            return !isValid(text.wrappedValue)
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .foregroundColor(.secondaryLabel)
                .fontWeight(.bold)
                .font(.headline)
            HStack {
                CustomTextField(self.placeholder, text: self.text, isFirstResponder: self.isFirstResponder) {
                    $0.keyboardType = self.keyboardType
                    $0.autocapitalizationType = .none
                    if self.isSecure {
                        $0.isSecureTextEntry = !self.isPasswordVisible
                    } else {
                        $0.isSecureTextEntry = false
                    }
                    $0.autocorrectionType = .no
                    if self.textContentType != nil {
                        $0.textContentType = self.textContentType!
                    }
                }
                if isSecure {
                    Button(action: {
                        self.isPasswordVisible.toggle()
                    }) {
                        if isPasswordVisible {
                            Image(systemName: "eye.fill")
                                .frame(width: 18, height: 18)
                        } else {
                            Image(systemName: "eye.slash.fill")
                                .frame(width: 18, height: 18)
                        }
                    }
                    .frame(width: 18, height: 18)
                    .foregroundColor(.label)
                } else {
                    Image(systemName: iconName)
                        .frame(width: 18, height: 18)
                }
            }
            Rectangle()
                .frame(height: 2)
                .foregroundColor(showsError ? .red : .accentColor)
        }
    }
}

struct ErrorTextField_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ErrorTextField(
                title: "Email",
                placeholder: "test@email.com",
                iconName: "envelope",
                text: .constant(""),
                isFirstResponder: false,
                isSecure: false)
                .padding()
                .previewLayout(.fixed(width: 400, height: 100))

            ErrorTextField(
                title: "Email",
                placeholder: "test@email.com",
                iconName: "envelope",
                text: .constant("some@email.com"),
                isFirstResponder: false,
                isSecure: false)
                .padding()
                .previewLayout(.fixed(width: 400, height: 100))

            ErrorTextField(
                title: "Email",
                placeholder: "test@email.com",
                iconName: "envelope",
                text: .constant("some@email.com"),
                isFirstResponder: false,
                isSecure: false,
                isValid: { _ in false })
                .padding()
                .previewLayout(.fixed(width: 400, height: 100))
        }
    }
}
