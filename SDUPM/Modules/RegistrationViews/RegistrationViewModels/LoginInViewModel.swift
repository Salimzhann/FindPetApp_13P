//
//  LoginAPI.swift
//  SDUCanteenApp
//
//  Created by Manas Salimzhan on 13.09.2024.
//

import UIKit

class LoginInViewModel {
    
    static let tokenIdentifier: String = "TokenIdentifier"
    
    func sendUserData(email: String, password: String, completion: @escaping (String?) -> Void) {
        
        guard let url = URL(string: "https://petradar.up.railway.app/auth/login") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let parameters = [
            "grant_type": "password",
            "username": email,
            "password": password,
            "scope": "",
            "client_id": "string",
            "client_secret": "string"
        ]
        
        // Формируем тело запроса в виде строки "key=value&key2=value2"
        let bodyString = parameters
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")" }
            .joined(separator: "&")
        
        request.httpBody = bodyString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
                if let data = data {
                    if httpResponse.statusCode == 200 {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let token = json["access_token"] as? String {
                                UserDefaults.standard.setValue(token, forKey: LoginInViewModel.tokenIdentifier)
                                completion("Success")
                            } else {
                                print("Token not found in response")
                                completion(nil)
                            }
                        } catch {
                            print("Failed to parse JSON: \(error.localizedDescription)")
                            completion(nil)
                        }
                    } else {
                        let responseString = String(data: data, encoding: .utf8) ?? "Unknown error"
                        print("Server response: \(responseString)")
                        completion(responseString)
                    }
                }
            }
        }
        
        task.resume()
    }
}


