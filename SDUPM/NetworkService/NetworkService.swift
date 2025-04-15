//
//  NetworkService.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 20.10.2024.
//

// File path: SDUPM/NetworkService/NetworkService.swift

import Foundation
import UIKit

struct NetworkService {
    static let api: String = "https://lost-found-for-pets-production.up.railway.app"
}

class NetworkServiceProvider {
    
    let api: String = NetworkService.api
    
    func searchPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?, completion: @escaping (Result<PetSearchResponse, Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/pets/search") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        // Create multipart form data request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Add authentication token to the header
        request.setValue("Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJzYXJzZW5iYXltZXlpcm1hbkBnbWFpbC5jb20iLCJleHAiOjE3NDQ2OTA3OTB9.rJPt-SgXRBCakVft_z3VUUCABZXfRCq7IdbYa_s67hg", forHTTPHeaderField: "Authorization")
        
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
        
        // Create and start task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let searchResponse = try JSONDecoder().decode(PetSearchResponse.self, from: data)
                completion(.success(searchResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func fetchUserProfile(completion: @escaping (UserProfile?) -> Void) {
        guard let url = URL(string: "https://petradar.up.railway.app/users/me") else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        // Получаем токен из UserDefaults
        guard let token = UserDefaults.standard.string(forKey: LoginInViewModel.tokenIdentifier) else {
            print("No token found")
            completion(nil)
            return
        }
        
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
                        // Декодируем ответ в UserProfile
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
    
    func uploadPetData(name: String, age: String, breed: String, category: String, isLost: Bool, images: [UIImage], completion: @escaping (_ success: Bool) -> Void) {
        completion(true)
    }
    
    func petDetailInfo(id: Int, completion: @escaping (PetDetailInfoModel) -> Void) {
        let urlString = "https://example.com/api/pets/\(id)" // Замените на реальный API
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Ошибка: данные отсутствуют")
                return
            }
            
            do {
                let petDetail = try JSONDecoder().decode(PetDetailInfoModel.self, from: data)
                DispatchQueue.main.async {
                    print("Полученные данные: \(petDetail)")
                }
            } catch {
                print("Ошибка декодирования JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func receivePetsList(completion: @escaping ([LostPetResponse]) -> Void) {
        guard let url = URL(string: "https://example.com/api/pets") else {
            print("❌ Invalid URL")
            completion([])
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error fetching data: \(error.localizedDescription)")
                completion([])
                return
            }
            
            guard let data = data else {
                print("❌ No data received")
                completion([])
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode([LostPetResponse].self, from: data)
                DispatchQueue.main.async {
                    completion(decodedData)
                }
            } catch {
                print("❌ JSON Decoding error: \(error)")
                completion([])
            }
        }
        
        task.resume()
    }
    
    
    func fetchLostPets(page: Int = 5, limit: Int = 100) {
        var urlComponents = URLComponents(string: "https://petradar.up.railway.app/pets/lost")!
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        
        guard let url = urlComponents.url else {
            print("Невозможно сформировать URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Ошибка запроса: \(error.localizedDescription)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Ошибка ответа от сервера")
                return
            }

            guard let data = data else {
                print("Нет данных")
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(LostPetResponse.self, from: data)
                print("✅ Успешно: \(result.items)")
            } catch {
                print("❌ Ошибка декодирования: \(error)")
            }
        }

        task.resume()
    }
}
