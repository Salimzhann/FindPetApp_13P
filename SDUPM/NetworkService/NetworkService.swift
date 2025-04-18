//
//  NetworkService.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 20.10.2024.
//

// File path: SDUPM/NetworkService/NetworkService.swift

import Foundation
import UIKit


enum NetworkError: Error, LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int)
    case noData
    case decodingFailed(Error)
    case networkUnavailable
    case authenticationRequired
    case serverError(String)
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let statusCode):
            return "Request failed with status code: \(statusCode)"
        case .noData:
            return "No data received from server"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkUnavailable:
            return "Network connection appears to be offline"
        case .authenticationRequired:
            return "Authentication required"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknownError(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

struct NetworkService {
    static let api: String = "https://lost-found-for-pets-production.up.railway.app"
}

class NetworkServiceProvider {
    
    let api: String = NetworkService.api
    
    // MARK: - Authentication API Requests
    
    func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/auth/login") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.unknownError(NSError(domain: "JSONSerializationError", code: 0, userInfo: nil))))
            }
            return
        }
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.unknownError(error)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.requestFailed(statusCode: 0)))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.requestFailed(statusCode: httpResponse.statusCode)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let accessToken = json["access_token"] as? String {
                    UserDefaults.standard.setValue(accessToken, forKey: LoginInViewModel.tokenIdentifier)
                    DispatchQueue.main.async {
                        completion(.success(accessToken))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.decodingFailed(NSError(domain: "InvalidResponse", code: 0, userInfo: nil))))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingFailed(error)))
                }
            }
        }
        
        task.resume()
    }
    
    func register(email: String, firstName: String, lastName: String, phone: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/auth/register") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "first_name": firstName,
            "last_name": lastName,
            "phone": phone,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.unknownError(NSError(domain: "JSONSerializationError", code: 0, userInfo: nil))))
            }
            return
        }
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.unknownError(error)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.requestFailed(statusCode: 0)))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.requestFailed(statusCode: httpResponse.statusCode)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    DispatchQueue.main.async {
                        completion(.success(message))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.decodingFailed(NSError(domain: "InvalidResponse", code: 0, userInfo: nil))))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingFailed(error)))
                }
            }
        }
        
        task.resume()
    }
    
    func verifyEmail(email: String, code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/auth/verify") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "code": code
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.unknownError(NSError(domain: "JSONSerializationError", code: 0, userInfo: nil))))
            }
            return
        }
        
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.unknownError(error)))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.requestFailed(statusCode: 0)))
                }
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.requestFailed(statusCode: httpResponse.statusCode)))
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let message = json["message"] as? String {
                    DispatchQueue.main.async {
                        completion(.success(message))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.decodingFailed(NSError(domain: "InvalidResponse", code: 0, userInfo: nil))))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingFailed(error)))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - My Pets API Requests
    
    func fetchUserPets(completion: @escaping ([MyPetResponse]?) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/pets/my") else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: LoginInViewModel.tokenIdentifier) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching pets: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            if let data = data, let pets = try? JSONDecoder().decode([MyPetResponse].self, from: data) {
                // Success - ensure we call completion on the main thread
                DispatchQueue.main.async {
                    completion(pets)
                }
            } else {
                // Error - also ensure we call completion on the main thread
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
    
    func createPet(name: String, species: String, breed: String?, age: Int?, color: String?,
                   gender: String?, distinctiveFeatures: String?, photos: [UIImage],
                   completion: @escaping (Result<MyPetResponse, Error>) -> Void) {
        
        guard let url = URL(string: "\(api)/api/v1/pets") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        // Create multipart form data request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        if let token = UserDefaults.standard.string(forKey: LoginInViewModel.tokenIdentifier) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add text fields
        let textFields: [String: String?] = [
            "name": name,
            "species": species,
            "breed": breed,
            "age": age != nil ? String(age!) : nil,
            "color": color,
            "gender": gender,
            "distinctive_features": distinctiveFeatures
        ]
        
        for (key, value) in textFields {
            if let value = value {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }
        
        // Add photos
        for (index, photo) in photos.enumerated() {
            if let imageData = photo.jpegData(compressionQuality: 0.7) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"photos\"; filename=\"photo\(index).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
        }
        
        // End of form data
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        // Create and start task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                }
                return
            }
            
            print("Create pet status code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                DispatchQueue.main.async {
                    if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                        completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode, userInfo: nil)))
                    } else {
                        completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: nil)))
                    }
                }
                return
            }
            
            do {
                let pet = try JSONDecoder().decode(MyPetResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(pet))
                }
            } catch {
                print("❌ JSON Decoding error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response: \(jsonString)")
                }
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Search Pet API Requests
    
    func searchPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?, completion: @escaping (Result<PetSearchResponse, Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/pets/search") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        // Create multipart form data request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add authentication token to the header
        if let token = UserDefaults.standard.string(forKey: LoginInViewModel.tokenIdentifier) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add photo
        if let imageData = photo.jpegData(compressionQuality: 0.7) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Add species (required)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"species\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(species)\r\n".data(using: .utf8)!)
        
        // Add color (required)
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"color\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(color)\r\n".data(using: .utf8)!)
        
        // Add gender (optional)
        if let gender = gender, !gender.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"gender\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(gender)\r\n".data(using: .utf8)!)
        }
        
        // Add breed (optional)
        if let breed = breed, !breed.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"breed\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(breed)\r\n".data(using: .utf8)!)
        }
        
        // End of form data
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Network error handling
            if let error = error {
                DispatchQueue.main.async {
                    if (error as NSError).domain == NSURLErrorDomain {
                        switch (error as NSError).code {
                        case NSURLErrorNotConnectedToInternet:
                            completion(.failure(NetworkError.networkUnavailable))
                        default:
                            completion(.failure(NetworkError.unknownError(error)))
                        }
                    } else {
                        completion(.failure(NetworkError.unknownError(error)))
                    }
                }
                return
            }
            
            // HTTP response handling
            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.requestFailed(statusCode: 0)))
                }
                return
            }
            
            // Status code handling
            switch httpResponse.statusCode {
            case 200...299:
                // Success case
                break
            case 401:
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.authenticationRequired))
                }
                return
            case 400...499:
                let message = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Client error"
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.requestFailed(statusCode: httpResponse.statusCode)))
                }
                return
            case 500...599:
                let message = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Server error"
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.serverError(message)))
                }
                return
            default:
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.requestFailed(statusCode: httpResponse.statusCode)))
                }
                return
            }
            
            // Data handling
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            // Decoding
            do {
                let searchResponse = try JSONDecoder().decode(PetSearchResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(searchResponse))
                }
            } catch {
                print("❌ JSON Decoding error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response data: \(jsonString)")
                }
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingFailed(error)))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - User Profile
    
    func fetchUserProfile(completion: @escaping (UserProfile?) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/users/me") else {
            DispatchQueue.main.async {
                print("Invalid URL")
                completion(nil)
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        guard let token = UserDefaults.standard.string(forKey: LoginInViewModel.tokenIdentifier) else {
            DispatchQueue.main.async {
                print("No token found")
                completion(nil)
            }
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
                
                if let data = data, httpResponse.statusCode == 200 {
                    do {
                        let decoder = JSONDecoder()
                        let userProfile = try decoder.decode(UserProfile.self, from: data)
                        DispatchQueue.main.async {
                            completion(userProfile)
                        }
                    } catch {
                        print("Failed to decode JSON: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                } else {
                    let errorString = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                    print("Server error: \(errorString)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Upload Pet Data
    
    func uploadPetData(name: String, age: String, breed: String, category: String, isLost: Bool, images: [UIImage], completion: @escaping (_ success: Bool) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/pets") else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        guard let token = UserDefaults.standard.string(forKey: LoginInViewModel.tokenIdentifier) else {
            DispatchQueue.main.async {
                completion(false)
            }
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add name
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(name)\r\n".data(using: .utf8)!)
        
        // Add age
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"age\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(age)\r\n".data(using: .utf8)!)
        
        // Add breed
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"breed\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(breed)\r\n".data(using: .utf8)!)
        
        // Add species
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"species\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(category)\r\n".data(using: .utf8)!)
        
        // Add status
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"status\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(isLost ? "lost" : "not_lost")\r\n".data(using: .utf8)!)
        
        // Add photos
        for (index, image) in images.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.7) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"photos\"; filename=\"photo\(index).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
        }
        
        // End of form data
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    completion(httpResponse.statusCode >= 200 && httpResponse.statusCode < 300)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Fetch Lost Pets
    
    func fetchLostPets(page: Int = 1, limit: Int = 10, completion: @escaping (LostPetResponse?) -> Void) {
        var urlComponents = URLComponents(string: "\(api)/api/v1/pets/lost")!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        guard let url = urlComponents.url else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: LoginInViewModel.tokenIdentifier) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server error")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            guard let data = data else {
                print("No data")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(LostPetResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(result)
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }

        task.resume()
    }
    
    // Обратная совместимость с оригинальной версией
    func fetchLostPets(completion: @escaping ([LostPet]) -> Void) {
        fetchLostPets { response in
            if let items = response?.items {
                completion(items)
            } else {
                completion([])
            }
        }
    }
}
