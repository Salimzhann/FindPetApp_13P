//
//  ApiManager.swift
//  SDUCanteenApp
//
//  Created by Manas Salimzhan on 13.09.2024.
//

import UIKit

class SignInViewModel {
    
    var accountIsActive: Bool = false
    
    func sendUserData(fullname: String, email: String, password: String, phoneNumber: String, completion: @escaping (String?) -> Void) {
        
        guard let url = URL(string: "\(NetworkService.api)/auth/signup") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "fullName": fullname,
            "email": email,
            "password": password,
            "phoneNumber": phoneNumber
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
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    print(responseString)
                    completion(responseString)
                }
                if httpResponse.statusCode == 200 { completion("Success") }
            }
        }
        
        task.resume()
    }
}
