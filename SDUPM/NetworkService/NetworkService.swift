//
//  NetworkService.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 20.10.2024.
//

import Foundation
import UIKit

struct NetworkService {
    static let api: String = "https://ce4affaee8835ddf09e54c5623434512.serveo.net"
}

class NetworkServiceProvider {
    
    let api: String = NetworkService.api
    
    
//    func fetchUserPets(completion: @escaping ([MyPetModel]?) -> Void) {
//        guard let url = URL(string: "https://petradar.up.railway.app/users/me/pets") else {
//            print("Неверный URL")
//            completion(nil)
//            return
//        }
//
//        guard let token = UserDefaults.standard.string(forKey: LoginInViewModel.tokenIdentifier) else {
//            print("Токен не найден")
//            completion(nil)
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Ошибка: \(error.localizedDescription)")
//                completion(nil)
//                return
//            }
//
//            guard let httpResponse = response as? HTTPURLResponse,
//                  (200...299).contains(httpResponse.statusCode) else {
//                print("Ошибка HTTP ответа")
//                completion(nil)
//                return
//            }
//
//            guard let data = data else {
//                print("Нет данных")
//                completion(nil)
//                return
//            }
//
//            do {
//                let pets = try JSONDecoder().decode([MyPetModel].self, from: data)
//                completion(pets)
//            } catch {
//                print("Ошибка декодирования: \(error)")
//                completion(nil)
//            }
//        }
//        task.resume()
//    }
    
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
//        guard let url = URL(string: "https://example.com/api/pets") else { return }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        let boundary = "Boundary-\(UUID().uuidString)"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        var body = Data()
//
//        // Добавляем текстовые данные
//        let params: [String: Any] = [
//            "name": name,
//            "age": age,
//            "breed": breed,
//            "category": category,
//            "isLost": isLost ? "true" : "false"
//        ]
//
//        for (key, value) in params {
//            body.append("--\(boundary)\r\n".data(using: .utf8)!)
//            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
//            body.append("\(value)\r\n".data(using: .utf8)!)
//        }
//
//        // Добавляем изображения
//        for (index, image) in images.enumerated() {
//            if let imageData = image.jpegData(compressionQuality: 0.7) {
//                let filename = "image\(index).jpg"
//                body.append("--\(boundary)\r\n".data(using: .utf8)!)
//                body.append("Content-Disposition: form-data; name=\"images[]\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
//                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
//                body.append(imageData)
//                body.append("\r\n".data(using: .utf8)!)
//            }
//        }
//
//        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
//        request.httpBody = body
//
//        // Отправка запроса
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("❌ Ошибка отправки: \(error.localizedDescription)")
//                completion(false)
//                return
//            }
//            completion(true)
//            print("✅ Данные успешно отправлены")
//        }
//
//        task.resume()
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
