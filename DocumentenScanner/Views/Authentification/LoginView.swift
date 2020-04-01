//
//  LoginView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 30.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

//swiftlint:disable multiple_closures_with_trailing_closure
struct LoginView: View {
    @EnvironmentObject var store: AppStore

    @State var mail: String = ""
    @State var password: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .center, spacing: 30) {
                ErrorTextField(title: "E-Mail",
                               placeholder: "max@hs-mittweida.de",
                               iconName: "envelope.fill",
                               text: self.$mail,
                               isFirstResponder: true,
                               keyboardType: .emailAddress,
                               isSecure: false,
                               textContentType: .emailAddress//,
                               //isValid: isEmailValid)
                                )
                    .frame(height: 70)
                ErrorTextField(title: "Passwort",
                               placeholder: "Passwort",
                               iconName: "",
                               text: self.$password,
                               isFirstResponder: false,
                               keyboardType: .alphabet,
                               isSecure: true,
                               textContentType: .password//,
                               //isValid: isPasswordValid)
                                )
                    .frame(height: 70)
                Button(action: {
                    UIApplication.shared.endEditing(true)
                    self.store.send(.login(email: self.mail, password: self.password))
                }) {
                    PrimaryButton(title: "Anmelden")
                }
//                .disabled(!(isEmailValid(email: self.mail) && isPasswordValid(password: self.password)))
//                .offset(x: 0, y: isEmailValid(email: self.mail) ? 0 : UIScreen.main.bounds.height)
//                .animation(.spring())
                Spacer()
            }.padding(.horizontal)
        }.navigationBarTitle("Anmelden", displayMode: .large)
    }

    private func isEmailValid(email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}(\\s*){2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: email)
    }
    //swiftlint:disable line_length
    private func isPasswordValid(password: String) -> Bool {
        let regex = "^((?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])|(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[^a-zA-Z0-9])|(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[^a-zA-Z0-9])|(?=.*?[a-z])(?=.*?[0-9])(?=.*?[^a-zA-Z0-9])).{8,}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: password)
    }
    //swiftlint:enable line_length
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView().environmentObject(AppStoreMock.getAppStore())
        }
    }
}
