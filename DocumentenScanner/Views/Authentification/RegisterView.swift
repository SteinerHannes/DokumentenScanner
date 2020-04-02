//
//  RegisterView.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 01.04.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import SwiftUI

//swiftlint:disable multiple_closures_with_trailing_closure
struct RegisterView: View {
    @EnvironmentObject var store: AppStore

    @State var mail: String = ""
    @State var name: String = ""
    @State var password: String = ""
    @State var tempPassword: String = ""

    var isEmailValid: Bool {
        validateEmail(email: self.mail)
    }

    var isPasswordValid: Bool {
        validatePassword(password: self.password)
    }

    var arePasswordSame: Bool {
        self.password == self.tempPassword && !self.tempPassword.isEmpty
    }

    var isNameValid: Bool {
        validateName(name: self.name)
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
                ErrorTextField(title: "Name",
                               placeholder: "Max Mustermann",
                               iconName: "person.circle",
                               text: self.$name,
                               isFirstResponder: false,
                               keyboardType: .alphabet,
                               isSecure: false,
                               textContentType: .name,
                               isValid: validateName)
                    .frame(height: 70)
                Group {
                    ErrorTextField(title: "Passwort",
                                   placeholder: "Passwort",
                                   iconName: "",
                                   text: self.$password,
                                   isFirstResponder: false,
                                   keyboardType: .alphabet,
                                   isSecure: true,
                                   textContentType: .newPassword,
                                   isValid: validatePassword)
                        .frame(height: 70)
                    ErrorTextField(title: "Passwort wiederholen",
                                   placeholder: "Passwort",
                                   iconName: "",
                                   text: self.$tempPassword,
                                   isFirstResponder: false,
                                   keyboardType: .alphabet,
                                   isSecure: true,
                                   textContentType: .newPassword,
                                   isValid: { _ in self.arePasswordSame })
                        .frame(height: 70)
                }
                .offset(x: 0, y: isNameValid && isEmailValid ? 0 : UIScreen.main.bounds.height)
                .animation(.spring())
                Button(action: {
                    UIApplication.shared.endEditing(true)
//                    self.store.send(.login(email: self.mail, password: self.password))
                }) {
                    PrimaryButton(title: "Registrieren")
                }
                .disabled(!(isEmailValid && isNameValid && isPasswordValid))
                .offset(x: 0, y: arePasswordSame ? 0 : UIScreen.main.bounds.height)
                .animation(.spring())
                Spacer()
            }.padding(.horizontal)
        }
        .navigationBarTitle("Registrieren", displayMode: .large)
        .alert(item:
            Binding<AuthServiceError?>(
                get: {
                    return self.store.states.authState.showAlert
            }, set: { _ in
                self.store.send(.auth(action: .dismissAlert))
            })) { (error) -> Alert in
                error.alert
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegisterView().environmentObject(AppStoreMock.getAppStore())
        }
    }
}
