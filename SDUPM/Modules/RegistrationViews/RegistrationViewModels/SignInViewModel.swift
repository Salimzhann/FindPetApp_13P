//
//  ApiManager.swift
//  SDUCanteenApp
//
//  Created by Manas Salimzhan on 13.09.2024.
//

import UIKit

class SignInViewModel {
    
    var accountIsActive: Bool = false
    
    func sendUserData(name: String, surname: String, email: String, password: String, phoneNumber: String, completion: @escaping (String?) -> Void) {
        guard let url = URL(string: "https://petradar.up.railway.app/auth/register") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "first_name": name,
            "last_name": surname,
            "phone": phoneNumber,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            print("Failed to serialize JSON")
            completion(nil)
            return
        }
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print(responseString)
                        completion("Success")
                    }
                } else {
                    completion("Failed with status code: \(httpResponse.statusCode)")
                }
            }
        }
        
        task.resume()
    }
    
    func verifyEmail(verificationCode: String, newEmail: String, completion: @escaping (String?) -> Void) {
        
        guard let url = URL(string: "https://petradar.up.railway.app/auth/verify-email") else {
            print("Неверный URL")
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "verification_code": verificationCode,
            "new_email": newEmail
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            print("Ошибка сериализации JSON")
            completion(nil)
            return
        }

        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Некорректный ответ")
                completion(nil)
                return
            }

            if (200...299).contains(httpResponse.statusCode) {
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print("Успешно: \(responseString)")
                    completion("Success")
                } else {
                    completion("Success without body")
                }
            } else {
                print("Ошибка: статус код \(httpResponse.statusCode)")
                if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Ответ сервера: \(errorMessage)")
                    completion(errorMessage)
                } else {
                    completion("Ошибка без тела ответа")
                }
            }
        }

        task.resume()
    }

}
