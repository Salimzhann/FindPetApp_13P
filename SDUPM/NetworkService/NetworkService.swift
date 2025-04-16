//
//  NetworkService.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 20.10.2024.
//

// File path: SDUPM/NetworkService/NetworkService.swift

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
    private let authToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzYXJzZW5iYXltZXlpcm1hbkBnbWFpbC5jb20iLCJleHAiOjE3NDkwMTYzNjd9.YX4RwMG6BkFR6LkVMl3JUDerJcJLmZyD1gTBHGTjH_E" // Temporary token for testing
    
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
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
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
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        // Create multipart form data request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
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
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                return
            }
            
            print("Create pet status code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode), let data = data else {
                if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                    completion(.failure(NSError(domain: errorMessage, code: httpResponse.statusCode, userInfo: nil)))
                } else {
                    completion(.failure(NSError(domain: "Server error", code: httpResponse.statusCode, userInfo: nil)))
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
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Search Pet API Requests
    
    func searchPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?, completion: @escaping (Result<PetSearchResponse, Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/pets/search") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        // Create multipart form data request
                 var request = URLRequest(url: url)
                 request.httpMethod = "POST"
                 
                 // Add authentication token to the header
                 request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
                 
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
                return
            }
            
            // HTTP response handling
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.requestFailed(statusCode: 0)))
                return
            }
            
            // Status code handling
            switch httpResponse.statusCode {
            case 200...299:
                // Success case
                break
            case 401:
                completion(.failure(NetworkError.authenticationRequired))
                return
            case 400...499:
                let message = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Client error"
                completion(.failure(NetworkError.requestFailed(statusCode: httpResponse.statusCode)))
                return
            case 500...599:
                let message = data.flatMap { String(data: $0, encoding: .utf8) } ?? "Server error"
                completion(.failure(NetworkError.serverError(message)))
                return
            default:
                completion(.failure(NetworkError.requestFailed(statusCode: httpResponse.statusCode)))
                return
            }
            
            // Data handling
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            // Decoding
            do {
                let searchResponse = try JSONDecoder().decode(PetSearchResponse.self, from: data)
                completion(.success(searchResponse))
            } catch {
                print("❌ JSON Decoding error: \(error)")
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Response data: \(jsonString)")
                }
                completion(.failure(NetworkError.decodingFailed(error)))
            }
        }
        
        task.resume()
    }
    // MARK: - User Profile
    
    func fetchUserProfile(completion: @escaping (UserProfile?) -> Void) {
        guard let url = URL(string: "\(api)/users/me") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Get token from UserDefaults or use the temporary one
        let token = UserDefaults.standard.string(forKey: LoginInViewModel.tokenIdentifier) ?? authToken
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status Code: \(httpResponse.statusCode)")
                
                if let data = data, httpResponse.statusCode == 200 {
                    do {
                        let decoder = JSONDecoder()
                        let userProfile = try decoder.decode(UserProfile.self, from: data)
                        completion(userProfile)
                    } catch {
                        print("Failed to decode JSON: \(error.localizedDescription)")
                        completion(nil)
                    }
                } else {
                    let errorString = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                    print("Server error: \(errorString)")
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
    
    // File path: SDUPM/NetworkService/NetworkService.swift
    // Add the following method to your NetworkServiceProvider class

    func fetchLostPets(completion: @escaping ([LostPet]) -> Void) {
        let urlString = "\(api)/api/v1/pets"
        var urlComponents = URLComponents(string: urlString)!
        urlComponents.queryItems = [
            URLQueryItem(name: "status", value: "lost"),
            URLQueryItem(name: "limit", value: "100")
        ]
        
        guard let url = urlComponents.url else {
            print("❌ Cannot form URL")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // Add the auth token
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error fetching data: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("❌ Server error")
                completion([])
                return
            }

            guard let data = data else {
                print("❌ No data received")
                completion([])
                return
            }

            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(LostPetResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(response.items)
                }
            } catch {
                print("❌ Decoding error: \(error)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response: \(responseString)")
                }
                completion([])
            }
        }

        task.resume()
    }
}
