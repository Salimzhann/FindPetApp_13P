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
        
        guard let url = URL(string: "\(NetworkService.api)/auth/login") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            print("Failed to serialize JSON")
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
                if let data = data {
                    if httpResponse.statusCode == 200 {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                               let token = json["token"] as? String {
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
                        completion(responseString)
                    }
                }
            }
        }
        
        task.resume()
    }
}


