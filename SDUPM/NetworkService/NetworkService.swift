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
    
    private func getToken() -> String? {
        return UserDefaults.standard.string(forKey: LoginInViewModel.tokenIdentifier)
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
        if let token = getToken() {
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
        
        guard let token = getToken() else {
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
    
    func updateUserProfile(fullName: String, phone: String, password: String?, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/users/me") else {
            DispatchQueue.main.async {
                completion(false, "Invalid URL")
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        guard let token = getToken() else {
            DispatchQueue.main.async {
                completion(false, "No token found")
            }
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [
            "full_name": fullName,
            "phone": phone
        ]
        
        if let password = password, !password.isEmpty {
            body["password"] = password
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(false, error.localizedDescription)
                    }
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    let success = (200...299).contains(httpResponse.statusCode)
                    
                    DispatchQueue.main.async {
                        if success {
                            completion(true, nil)
                        } else {
                            let message = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                            completion(false, "Error: \(httpResponse.statusCode) - \(message)")
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(false, "Invalid response")
                    }
                }
            }
            
            task.resume()
        } catch {
            DispatchQueue.main.async {
                completion(false, "Failed to serialize request body")
            }
        }
    }
    
    func deleteUserAccount(completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/users/me") else {
            DispatchQueue.main.async {
                completion(false, "Invalid URL")
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        guard let token = getToken() else {
            DispatchQueue.main.async {
                completion(false, "No token found")
            }
            return
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                let success = (200...299).contains(httpResponse.statusCode)
                
                DispatchQueue.main.async {
                    if success {
                        completion(true, nil)
                    } else {
                        let message = String(data: data ?? Data(), encoding: .utf8) ?? "Unknown error"
                        completion(false, "Error: \(httpResponse.statusCode) - \(message)")
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(false, "Invalid response")
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
        
        if let token = getToken() {
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
        
        guard let token = getToken() else {
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
    
    func fetchLostPets(page: Int = 1, limit: Int = 10, completion: @escaping (Result<LostPetResponse, Error>) -> Void) {
        var urlComponents = URLComponents(string: "\(api)/api/v1/pets/lost")!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        guard let url = urlComponents.url else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.unknownError(error)))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.requestFailed(statusCode: statusCode)))
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
                let decoder = JSONDecoder()
                let result = try decoder.decode(LostPetResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingFailed(error)))
                }
            }
        }

        task.resume()
    }
    
    // Function for backward compatibility
    func fetchLostPets(completion: @escaping ([Pet]?, Error?) -> Void) {
        fetchLostPets { result in
            switch result {
            case .success(let response):
                completion(response.items, nil)
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    // MARK: - Fetch Found Pets (Mock Implementation)
    
    func fetchFoundPets(page: Int = 1, limit: Int = 20, completion: @escaping ([Pet]?, Error?) -> Void) {
        // Mock data for found pets since endpoint doesn't exist yet
        let mockFoundPets: [Pet] = [
            Pet(id: 20, name: "Buddy", species: "dog", breed: "Лабрадор", age: 3, color: "золотистый", gender: "male", distinctive_features: "Белое пятно на груди, синий ошейник", last_seen_location: "Парк Горького", photos: [PetPhoto(id: 101, pet_id: 20, photo_url: "https://www.thesprucepets.com/thmb/hxWjs7evF2hP1Fb1c1HAvRi_Rw0=/2765x0/filters:no_upscale():strip_icc()/chinese-dog-breeds-4797219-hero-2a1e9c5ed2c54d00aef75b05c5db399c.jpg", is_primary: true, created_at: "2025-04-15T01:42:08.087996")], status: "found", created_at: "2025-04-15T06:42:07", updated_at: "2025-04-15T06:42:07", lost_date: nil, owner_id: 1),
            Pet(id: 21, name: "Luna", species: "cat", breed: "Сиамская", age: 2, color: "кремовая с коричневыми отметинами", gender: "female", distinctive_features: "Голубые глаза, красный ошейник с бубенчиком", last_seen_location: "Район Медеу", photos: [PetPhoto(id: 102, pet_id: 21, photo_url: "https://www.tippaws.com/cdn/shop/articles/getting-to-know-your-bengal-cat-tippaws.png?v=1729077812", is_primary: true, created_at: "2025-04-15T01:43:09.349109")], status: "found", created_at: "2025-04-15T06:43:09", updated_at: "2025-04-15T06:43:09", lost_date: nil, owner_id: 2),
            Pet(id: 22, name: "Max", species: "dog", breed: "Бульдог", age: 4, color: "белый с коричневыми пятнами", gender: "male", distinctive_features: "Короткий хвост, зеленый ошейник", last_seen_location: "Проспект Достык", photos: [PetPhoto(id: 103, pet_id: 22, photo_url: "https://cdn.britannica.com/79/232779-050-6B0411D7/German-Shepherd-dog-Alsatian.jpg", is_primary: true, created_at: "2025-04-15T04:52:19.053884")], status: "found", created_at: "2025-04-15T09:52:18", updated_at: "2025-04-15T09:52:18", lost_date: nil, owner_id: 3)
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion(mockFoundPets, nil)
        }
    }
    
    // MARK: - Authentication API Methods
    
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
    
    func register(fullName: String, email: String, phone: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
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
            "full_name": fullName,
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
                        completion(.success("Registration successful"))
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
                        completion(.success("Email verified successfully"))
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
}
