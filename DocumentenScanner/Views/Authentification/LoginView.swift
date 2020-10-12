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

    @State var mail: String = "test@localhost.invalid"
    @State var password: String = "test123!"

    var isEmailValid: Bool {
        validateEmail(email: self.mail)
    }

    var isPasswordValid: Bool {
        validatePassword(password: self.password)
    }

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
                               textContentType: .emailAddress,
                               isValid: validateEmail)
                    .frame(height: 70)
                ErrorTextField(title: "Passwort",
                               placeholder: "Passwort",
                               iconName: "",
                               text: self.$password,
                               isFirstResponder: false,
                               keyboardType: .alphabet,
                               isSecure: true,
                               textContentType: .password,
                               isValid: validatePassword)
                    .frame(height: 70)
                Button(action: {
                    UIApplication.shared.endEditing(true)
                    let mail = self.mail.trimmingCharacters(in: .whitespacesAndNewlines)
                    let password = self.password.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.store.send(.auth(action: .login(email: mail, password: password)))
                }) {
                    PrimaryButton(title: "Anmelden")
                }
                .disabled(!(isEmailValid && isPasswordValid))
                .offset(x: 0, y: isEmailValid ? 0 : UIScreen.main.bounds.height)
                .animation(.spring())
                Spacer()
            }.padding(.horizontal)
        }
        .navigationBarTitle("Anmelden", displayMode: .large)
        .alert(item:
            Binding<AuthServiceError?>(
                get: {
                    return self.store.states.authState.showAlert
                }, set: { _ in
                    self.store.send(.auth(action: .dismissAlert))
                }
            )
        ) { (error) -> Alert in
            error.alert
        }
        .onAppear {
            self.store.send(.log(action: .navigation("LoginScreen")))
        }
        .navigationBarItems(trailing: StartStopButton().environmentObject(self.store))
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView().environmentObject(AppStoreMock.getAppStore())
        }
    }
}
