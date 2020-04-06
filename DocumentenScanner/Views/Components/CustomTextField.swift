//
//  CustomTextField.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 23.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation
import SwiftUI

struct CustomTextField: UIViewRepresentable {

    class Coordinator: NSObject, UITextFieldDelegate {

        @Binding var text: String
        var didBecomeFirstResponder = false

        init(text: Binding<String>) {
            _text = text
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }
    }
    var placeholder: String?
    @Binding var text: String
    var isFirstResponder: Bool = false
    var configuration = { (view: UITextField) in }

    init(_ placeholder: String,
         text: Binding<String>,
         isFirstResponder: Bool,
         configuration: @escaping (UITextField) -> Void) {
        self.placeholder = placeholder
        self._text = text
        self.isFirstResponder = isFirstResponder
        self.configuration = configuration
    }

    init(_ placeholder: String, text: Binding<String>, isFirstResponder: Bool) {
        self.placeholder = placeholder
        self._text = text
        self.isFirstResponder = isFirstResponder
    }

    func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.delegate = context.coordinator
        textField.placeholder = placeholder
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.text = self.text
        textField.adjustsFontSizeToFitWidth = true
        return textField
    }

    func makeCoordinator() -> CustomTextField.Coordinator {
        return Coordinator(text: $text)
    }

    func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<CustomTextField>) {
        if isFirstResponder && !context.coordinator.didBecomeFirstResponder {
            uiView.becomeFirstResponder()
            context.coordinator.didBecomeFirstResponder = true
        }
        configuration(uiView)
    }
}
