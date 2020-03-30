//
//  AuthService.swift
//  DocumentenScanner
//
//  Created by Hannes Steiner on 30.03.20.
//  Copyright © 2020 Hannes Steiner. All rights reserved.
//

import Foundation

final class AuthService {
    let baseUrl: String = "https://localhost:5000/auth/"

    func login() {
        // prepare data for uplaod
        let login = LoginDTO(email: "a@a.a", password: "hsmw")

        guard let uploadData = try? JSONEncoder().encode(login) else {
            return
        }

        print(uploadData)

        // configure an uplaod request
        guard let url = URL(string: "http://localhost:5000/auth/login") else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // create and start an uplaod task

        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { data, response, error in
            if let error = error {
                print("error: ", error)
                return
            }
            guard let response = response as? HTTPURLResponse else {
                    print("server error")
                    return
            }
            print(response.statusCode)
            if (200..<300).contains(response.statusCode) {
                print("succes")
            }

            if let mimeType = response.mimeType,
                mimeType == "application/json",
                let data = data,
                let dataString = String(data: data, encoding: .utf8) {
                    print("got data", dataString)
            }
        }
        task.resume()
    }
}
