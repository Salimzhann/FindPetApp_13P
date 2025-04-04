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
    
    func takeMyPets(completion: @escaping ([MyPetModel]?) -> Void) {
        
//        let urlString = "https://your-api.com/user/pets"
//        guard let url = URL(string: urlString) else {
//            completion(nil)
//            return
//        }
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        // Если нужен токен авторизации, добавь:
//        // request.setValue("Bearer YOUR_ACCESS_TOKEN", forHTTPHeaderField: "Authorization")
//
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Ошибка при загрузке данных: \(error.localizedDescription)")
//                completion(nil)
//                return
//            }
//
//            guard let data = data else {
//                completion(nil)
//                return
//            }
//
//            do {
//                let pets = try JSONDecoder().decode([MyPetModel].self, from: data)
//                self.view.activityIndicator.stopAnimating()
//
//                completion(pets)
//            } catch {
//                print("Ошибка при декодировании JSON: \(error.localizedDescription)")
//                completion(nil)
//            }
//        }
//
//        task.resume()
        completion(nil)
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
    
    func receivePetsList(completion: @escaping ([LosePetsModel]) -> Void) {
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
                    let decodedData = try JSONDecoder().decode([LosePetsModel].self, from: data)
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
}
