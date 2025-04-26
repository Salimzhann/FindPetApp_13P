import Foundation
import UIKit
import CoreLocation
/// Ошибки, которые могут возникнуть при сетевых запросах
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

/// Базовая структура для хранения API-endpoint
struct NetworkService {
    static let api: String = "https://lost-found-for-pets-production.up.railway.app"
}

/// Основной класс для работы с сетевыми запросами
class NetworkServiceProvider {
    
    // MARK: - Properties
    
    let api: String = NetworkService.api
    private let sessionTimeout: TimeInterval = 30.0
    
    // MARK: - Helper Methods
    
    /// Получение токена авторизации из UserDefaults
    private func getToken() -> String? {
        return UserDefaults.standard.string(forKey: LoginViewModel.tokenIdentifier)
    }
    
    /// Создание общего URL запроса с авторизацией
    private func createAuthorizedRequest(url: URL, method: String) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = sessionTimeout
        
        if let token = getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return request
    }
    
    /// Обработка сетевой ошибки
    private func handleNetworkError<T>(_ error: Error, completion: @escaping (Result<T, Error>) -> Void) {
        DispatchQueue.main.async {
            if (error as NSError).domain == NSURLErrorDomain {
                switch (error as NSError).code {
                case NSURLErrorNotConnectedToInternet:
                    completion(.failure(NetworkError.networkUnavailable))
                case NSURLErrorTimedOut:
                    completion(.failure(NetworkError.requestFailed(statusCode: -1)))
                default:
                    completion(.failure(NetworkError.unknownError(error)))
                }
            } else {
                completion(.failure(NetworkError.unknownError(error)))
            }
        }
    }
    
    /// Обработка HTTP ответа
    private func handleHTTPResponse<T>(response: URLResponse?, statusCode: Int? = nil, completion: @escaping (Result<T, Error>) -> Void) -> Bool {
        guard let httpResponse = response as? HTTPURLResponse else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.requestFailed(statusCode: 0)))
            }
            return false
        }
        
        let code = statusCode ?? httpResponse.statusCode
        
        switch code {
        case 200...299:
            return true
        case 401:
            DispatchQueue.main.async {
                completion(.failure(NetworkError.authenticationRequired))
            }
            return false
        case 400...499:
            DispatchQueue.main.async {
                completion(.failure(NetworkError.requestFailed(statusCode: code)))
            }
            return false
        case 500...599:
            DispatchQueue.main.async {
                completion(.failure(NetworkError.serverError("Server error \(code)")))
            }
            return false
        default:
            DispatchQueue.main.async {
                completion(.failure(NetworkError.requestFailed(statusCode: code)))
            }
            return false
        }
    }
    
    // MARK: - Search Pet API Requests
    
    /// Поиск домашнего животного по фотографии и критериям
    func searchPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?, completion: @escaping (Result<PetSearchResponse, Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/pets/search") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        // Создаем multipart/form-data запрос
        var request = createAuthorizedRequest(url: url, method: "POST")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Добавляем фото
        if let imageData = photo.jpegData(compressionQuality: 0.7) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Добавляем обязательные поля
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"species\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(species)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"color\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(color)\r\n".data(using: .utf8)!)
        
        // Добавляем опциональные поля
        if let gender = gender, !gender.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"gender\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(gender)\r\n".data(using: .utf8)!)
        }
        
        if let breed = breed, !breed.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"breed\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(breed)\r\n".data(using: .utf8)!)
        }
        
        // Закрываем multipart форму
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Обработка сетевой ошибки
            if let error = error {
                self.handleNetworkError(error, completion: completion)
                return
            }
            
            // Обработка HTTP ответа
            if !self.handleHTTPResponse(response: response, completion: completion) {
                return
            }
            
            // Проверка наличия данных
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            // Декодирование ответа
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
    
    /// Получение информации о профиле пользователя
    func fetchUserProfile(completion: @escaping (UserProfile?) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/users/me") else {
            DispatchQueue.main.async {
                print("Invalid URL")
                completion(nil)
            }
            return
        }
        
        var request = createAuthorizedRequest(url: url, method: "GET")
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
    
    /// Обновление информации о профиле пользователя
    func updateUserProfile(fullName: String, phone: String, password: String?, completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/users/me") else {
            DispatchQueue.main.async {
                completion(false, "Invalid URL")
            }
            return
        }
        
        var request = createAuthorizedRequest(url: url, method: "PUT")
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
    
    /// Удаление учетной записи пользователя
    func deleteUserAccount(completion: @escaping (Bool, String?) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/users/me") else {
            DispatchQueue.main.async {
                completion(false, "Invalid URL")
            }
            return
        }
        
        let request = createAuthorizedRequest(url: url, method: "DELETE")
        
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
    
    /// Получение списка питомцев пользователя
    func fetchUserPets(completion: @escaping ([MyPetResponse]?) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/pets/my") else {
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        var request = createAuthorizedRequest(url: url, method: "GET")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching pets: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            if let data = data {
                do {
                    let pets = try JSONDecoder().decode([MyPetResponse].self, from: data)
                    DispatchQueue.main.async {
                        completion(pets)
                    }
                } catch {
                    print("Error decoding pets: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Create Pet
    
    /// Создание нового питомца
    func createPet(name: String, species: String, breed: String?, age: Int?, color: String?, gender: String?, distinctiveFeatures: String?, photos: [UIImage], completion: @escaping (Result<MyPetResponse, Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/pets") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        var request = createAuthorizedRequest(url: url, method: "POST")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Добавляем обязательные поля
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(name)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"species\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(species)\r\n".data(using: .utf8)!)
        
        // Добавляем опциональные поля
        if let age = age {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"age\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(age)\r\n".data(using: .utf8)!)
        }
        
        if let breed = breed, !breed.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"breed\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(breed)\r\n".data(using: .utf8)!)
        }
        
        if let color = color, !color.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"color\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(color)\r\n".data(using: .utf8)!)
        }
        
        if let gender = gender, !gender.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"gender\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(gender)\r\n".data(using: .utf8)!)
        }
        
        if let distinctiveFeatures = distinctiveFeatures, !distinctiveFeatures.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"distinctive_features\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(distinctiveFeatures)\r\n".data(using: .utf8)!)
        }
        
        // Добавляем фотографии
        for (index, image) in photos.enumerated() {
            if let imageData = image.jpegData(compressionQuality: 0.7) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"photos\"; filename=\"photo\(index).jpg\"\r\n".data(using: .utf8)!)
                body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
                body.append(imageData)
                body.append("\r\n".data(using: .utf8)!)
            }
        }
        
        // Закрываем multipart форму
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
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
                let pet = try JSONDecoder().decode(MyPetResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(pet))
                }
            } catch {
                print("❌ Decoding error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingFailed(error)))
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Fetch Lost Pets
    func fetchLostPets(page: Int = 1, limit: Int = 10, completion: @escaping (Result<APILostPetResponse, Error>) -> Void) {
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
        
        let request = createAuthorizedRequest(url: url, method: "GET")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.handleNetworkError(error, completion: completion)
                return
            }
            
            if !self.handleHTTPResponse(response: response, completion: completion) {
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                // First try decoding as a standard array of Pet objects
                let pets = try JSONDecoder().decode([Pet].self, from: data)
                
                // Convert Pet objects to APILostPet objects
                let apiPets = pets.map { pet -> APILostPet in
                    let photoUrl = pet.photos.first?.photo_url
                    
                    return APILostPet(
                        id: String(pet.id),
                        name: pet.name,
                        species: pet.species,
                        breed: pet.breed,
                        photo_url: photoUrl,
                        status: pet.status,
                        lost_date: pet.lost_date
                    )
                }
                
                // Create a response object with the converted pets and pagination info
                let response = APILostPetResponse(
                    items: apiPets,
                    total: pets.count,
                    page: page,
                    limit: limit,
                    pages: max(1, (pets.count + limit - 1) / limit)
                )
                print(response, "oiefnonieis")
                DispatchQueue.main.async {
                    completion(.success(response))
                }
                
            } catch {
                print("Decoding error: \(error)")
                
                // If you want to see the raw JSON for debugging
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
    func updatePet(
        petId: Int,
        name: String? = nil,
        species: String? = nil,
        breed: String? = nil,
        age: Int? = nil,
        color: String? = nil,
        gender: String? = nil,
        distinctiveFeatures: String? = nil,
        status: String? = nil,
        lastSeenLocation: String? = nil,
        completion: @escaping (Result<Pet, Error>) -> Void
    ) {
        guard let url = URL(string: "\(api)/api/v1/pets/\(petId)") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        var request = createAuthorizedRequest(url: url, method: "PATCH")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Строим тело запроса только с предоставленными полями
        var body: [String: Any] = [:]
        
        if let name = name { body["name"] = name }
        if let species = species { body["species"] = species }
        if let breed = breed { body["breed"] = breed }
        if let age = age { body["age"] = age }
        if let color = color { body["color"] = color }
        if let gender = gender { body["gender"] = gender }
        if let distinctiveFeatures = distinctiveFeatures { body["distinctive_features"] = distinctiveFeatures }
        if let status = status { body["status"] = status }
        if let lastSeenLocation = lastSeenLocation { body["last_seen_location"] = lastSeenLocation }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body)
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
                    let pet = try JSONDecoder().decode(Pet.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(pet))
                    }
                } catch {
                    print("Decoding error: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.decodingFailed(error)))
                    }
                }
            }
            
            task.resume()
        } catch {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.unknownError(error)))
            }
        }
    }
    func getPetDetails(petId: Int, completion: @escaping (Result<Pet, Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/pets/lost/\(petId)") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        let request = createAuthorizedRequest(url: url, method: "GET")
        
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
                let decoder = JSONDecoder()
                let pet = try decoder.decode(Pet.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(pet))
                }
            } catch {
                print("Decoding error: \(error)")
                
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
    /// Функция для обратной совместимости - получает потерянных питомцев и преобразует их для презентера
    func fetchLostPets(completion: @escaping (Result<LostPetResponse, Error>) -> Void) {
        fetchLostPets { result in
            switch result {
            case .success(let apiResponse):
                // Преобразуем APILostPetResponse в LostPetResponse
                // Примечание: здесь используется простой мок, в реальной имплементации нужно преобразовать данные
                let mockPets: [Pet] = apiResponse.items.compactMap { apiPet in
                    guard let id = Int(apiPet.id) else { return nil }
                    
                    return Pet(
                        id: id,
                        name: apiPet.name,
                        species: apiPet.species,
                        breed: apiPet.breed,
                        age: nil,
                        color: "",
                        gender: nil,
                        distinctive_features: nil,
                        last_seen_location: nil,
                        photos: [
                            PetPhoto(
                                id: 0,
                                pet_id: id,
                                photo_url: apiPet.photo_url ?? "",
                                is_primary: true,
                                created_at: ""
                            )
                        ],
                        status: apiPet.status,
                        created_at: "",
                        updated_at: "",
                        lost_date: apiPet.lost_date,
                        owner_id: 0
                    )
                }
                
                let response = LostPetResponse(
                    items: mockPets,
                    total: apiResponse.total
                )
                
                completion(.success(response))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Fetch Found Pets (Mock Implementation)
    
    /// Получение списка найденных питомцев (мок-данные)
    func fetchFoundPets(page: Int = 1, limit: Int = 20, completion: @escaping ([Pet]?, Error?) -> Void) {
        // Моковые данные для найденных питомцев
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
    
    /// Вход в систему
    // Обновите метод login в NetworkServiceProvider так, чтобы он возвращал данные в нужном формате:
    // SDUPM/NetworkService/NetworkService.swift (Partial update - only the searchPet method)
    // Path: SDUPM/NetworkService/NetworkService.swift (Add or update this method)

    func reportFoundPet(
        photo: UIImage,
        species: String,
        color: String,
        gender: String?,
        breed: String?,
        coordinates: CLLocationCoordinate2D?,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let url = URL(string: "\(api)/api/v1/pets/found") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        // Create multipart/form-data request
        var request = createAuthorizedRequest(url: url, method: "POST")
        
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
        
        // Add required fields
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"species\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(species)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"color\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(color)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"status\"\r\n\r\n".data(using: .utf8)!)
        body.append("found\r\n".data(using: .utf8)!)
        
        // Add optional fields
        if let gender = gender, !gender.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"gender\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(gender)\r\n".data(using: .utf8)!)
        }
        
        if let breed = breed, !breed.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"breed\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(breed)\r\n".data(using: .utf8)!)
        }
        
        // Add coordinates if available
        if let coordinates = coordinates {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"coordX\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(coordinates.longitude)\r\n".data(using: .utf8)!)
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"coordY\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(coordinates.latitude)\r\n".data(using: .utf8)!)
        }
        
        // Close the multipart form
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
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
            
            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } else {
                DispatchQueue.main.async {
                    let message = data != nil ? String(data: data!, encoding: .utf8) ?? "Unknown error" : "Unknown error"
                    completion(.failure(NetworkError.requestFailed(statusCode: httpResponse.statusCode)))
                }
            }
        }
        
        task.resume()
    }
    func searchPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?, coordinates: CLLocationCoordinate2D?, completion: @escaping (Result<PetSearchResponse, Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/pets/search") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        // Create multipart/form-data request
        var request = createAuthorizedRequest(url: url, method: "POST")
        
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
        
        // Add required fields
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"species\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(species)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"color\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(color)\r\n".data(using: .utf8)!)
        
        // Add optional fields
        if let gender = gender, !gender.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"gender\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(gender)\r\n".data(using: .utf8)!)
        }
        
        if let breed = breed, !breed.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"breed\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(breed)\r\n".data(using: .utf8)!)
        }
        
        // Add coordinates if available
        if let coordinates = coordinates {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"coordX\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(coordinates.longitude)\r\n".data(using: .utf8)!)
            
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"coordY\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(coordinates.latitude)\r\n".data(using: .utf8)!)
        }
        
        // Close the multipart form
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                self.handleNetworkError(error, completion: completion)
                return
            }
            
            // Handle HTTP response
            if !self.handleHTTPResponse(response: response, completion: completion) {
                return
            }
            
            // Check for data
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            // Decode response
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
    /// Вход в систему
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
        request.timeoutInterval = sessionTimeout
        
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
                self.handleNetworkError(error, completion: completion)
                return
            }
            
            if !self.handleHTTPResponse(response: response, completion: completion) {
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                // Преобразуем данные в строку JSON для дальнейшей обработки в LoginInViewModel
                if let jsonString = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        completion(.success(jsonString))
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
    
    /// Регистрация нового пользователя
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
        request.timeoutInterval = sessionTimeout
        
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
                self.handleNetworkError(error, completion: completion)
                return
            }
            
            if !self.handleHTTPResponse(response: response, completion: completion) {
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
    
    /// Подтверждение email по коду верификации
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
        request.timeoutInterval = sessionTimeout
        
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
                self.handleNetworkError(error, completion: completion)
                return
            }
            
            if !self.handleHTTPResponse(response: response, completion: completion) {
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
    // Путь: SDUPM/NetworkService/NetworkService.swift (добавить эти методы в класс NetworkServiceProvider)
    
    func fetchChats(completion: @escaping (Result<[Chat], Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/chats") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        let request = createAuthorizedRequest(url: url, method: "GET")
        
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
                // Вывод полученных данных для отладки
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Received chat data: \(jsonString)")
                }
                
                let decoder = JSONDecoder()
                
                // Пробуем декодировать как массив
                var chats = try decoder.decode([Chat].self, from: data)
                
                // Заполняем UI-данные для каждого чата
                for i in 0..<chats.count {
                    chats[i].otherUserName = "User \(chats[i].user2_id)"
                    chats[i].petName = "Pet \(chats[i].pet_id)"
                }
                
                DispatchQueue.main.async {
                    completion(.success(chats))
                }
            } catch {
                print("❌ Decoding error: \(error)")
                
                // Более детальная информация об ошибке
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Key '\(key.stringValue)' not found: \(context.debugDescription)")
                        print("codingPath: \(context.codingPath)")
                    case .valueNotFound(let type, let context):
                        print("Value of type \(type) not found: \(context.debugDescription)")
                        print("codingPath: \(context.codingPath)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch for type \(type): \(context.debugDescription)")
                        print("codingPath: \(context.codingPath)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                        print("codingPath: \(context.codingPath)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingFailed(error)))
                }
            }
        }
        
        task.resume()
    }
    func createChat(petId: Int, userId: Int, completion: @escaping (Result<Chat, Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/chats") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        var request = createAuthorizedRequest(url: url, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let createChatRequest = CreateChatRequest(pet_id: petId, user2_id: userId)
        
        do {
            let jsonData = try JSONEncoder().encode(createChatRequest)
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
                    // Используем кастомный декодер, который обрабатывает отсутствующие поля
                    let decoder = JSONDecoder()
                    var chat = try decoder.decode(Chat.self, from: data)
                    
                    // Добавляем информативные имена для отображения
                    chat.otherUserName = "User \(chat.user2_id)"
                    chat.petName = "Pet \(chat.pet_id)"
                    
                    DispatchQueue.main.async {
                        completion(.success(chat))
                    }
                } catch {
                    print("Decoding error: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.decodingFailed(error)))
                    }
                }
            }
            
            task.resume()
        } catch {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.unknownError(error)))
            }
        }
    }
    
    func getChatMessages(chatId: Int, completion: @escaping (Result<[ChatMessage], Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/chats/\(chatId)/messages") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        let request = createAuthorizedRequest(url: url, method: "GET")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Обработка ошибок...
            
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            do {
                // Если ваш бэкенд возвращает массив сообщений, а не объект с полем messages
                let messages = try JSONDecoder().decode([ChatMessage].self, from: data)
                DispatchQueue.main.async {
                    completion(.success(messages))
                }
            } catch {
                print("Decoding error: \(error)")
                
                // Для отладки выведем фактические данные, полученные от сервера
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Raw JSON response: \(jsonString)")
                }
                
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingFailed(error)))
                }
            }
        }
        
        task.resume()
    }
    // Добавьте этот метод в класс NetworkServiceProvider в файле SDUPM/NetworkService/NetworkService.swift
    
    func getChat(chatId: Int, completion: @escaping (Result<Chat, Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/chats/\(chatId)") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        let request = createAuthorizedRequest(url: url, method: "GET")
        
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
                // Для отладки выводим полученный JSON
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("Chat API response: \(jsonString)")
                }
                
                let decoder = JSONDecoder()
                var chat = try decoder.decode(Chat.self, from: data)
                
                // Заполняем UI-данные
                let otherUserName = "User \(chat.user1_id == UserDefaults.standard.integer(forKey: "current_user_id") ? chat.user2_id : chat.user1_id)"
                chat.otherUserName = otherUserName
                chat.petName = "Pet \(chat.pet_id)"
                
                DispatchQueue.main.async {
                    completion(.success(chat))
                }
            } catch {
                print("Decoding error: \(error)")
                
                // Более подробная информация об ошибке для отладки
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Key '\(key)' not found: \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("Value '\(type)' not found: \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch for '\(type)': \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context.debugDescription)")
                    @unknown default:
                        print("Unknown decoding error")
                    }
                }
                
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.decodingFailed(error)))
                }
            }
        }
        
        task.resume()
    }
    func sendMessage(chatId: Int, content: String, completion: @escaping (Result<ChatMessage, Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/chats/\(chatId)/messages") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        var request = createAuthorizedRequest(url: url, method: "POST")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let messageRequest = SendMessageRequest(content: content)
        
        do {
            let jsonData = try JSONEncoder().encode(messageRequest)
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
                    let message = try JSONDecoder().decode(ChatMessage.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(message))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.decodingFailed(error)))
                    }
                }
            }
            
            task.resume()
        } catch {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.unknownError(error)))
            }
        }
    }
    
    // Обновление метода searchPet в NetworkServiceProvider для включения координат
    // Этот код нужно добавить в класс NetworkServiceProvider в файле NetworkService.swift

    // MARK: - Search Pet API Requests

    /// Поиск домашнего животного по фотографии и критериям
    // Обновление метода searchPet в NetworkServiceProvider для включения координат
    // Этот код нужно добавить в класс NetworkServiceProvider в файле NetworkService.swift

    // MARK: - Search Pet API Requests

    /// Поиск домашнего животного по фотографии и критериям
    func searchPet(photo: UIImage, species: String, color: String, gender: String?, breed: String?, coordX: Double? = nil, coordY: Double? = nil, completion: @escaping (Result<PetSearchResponse, Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/pets/search") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        // Создаем multipart/form-data запрос
        var request = createAuthorizedRequest(url: url, method: "POST")
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Добавляем фото
        if let imageData = photo.jpegData(compressionQuality: 0.7) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Добавляем обязательные поля
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"species\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(species)\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"color\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(color)\r\n".data(using: .utf8)!)
        
        // Добавляем опциональные поля
        if let gender = gender, !gender.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"gender\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(gender)\r\n".data(using: .utf8)!)
        }
        
        if let breed = breed, !breed.isEmpty {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"breed\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(breed)\r\n".data(using: .utf8)!)
        }
        
        // Добавляем координаты, если они предоставлены
        if let coordX = coordX {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"coordX\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(coordX)\r\n".data(using: .utf8)!)
        }
        
        if let coordY = coordY {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"coordY\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(coordY)\r\n".data(using: .utf8)!)
        }
        
        // Закрываем multipart форму
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Обработка сетевой ошибки
            if let error = error {
                self.handleNetworkError(error, completion: completion)
                return
            }
            
            // Обработка HTTP ответа
            if !self.handleHTTPResponse(response: response, completion: completion) {
                return
            }
            
            // Проверка наличия данных
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.noData))
                }
                return
            }
            
            // Декодирование ответа
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

    // MARK: - Delete Pet
    func deletePet(petId: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(api)/api/v1/pets/\(petId)") else {
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidURL))
            }
            return
        }
        
        let request = createAuthorizedRequest(url: url, method: "DELETE")
        
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
            
            if (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } else {
                let errorMessage = data != nil ? String(data: data!, encoding: .utf8) : "Unknown error"
                DispatchQueue.main.async {
                    completion(.failure(NetworkError.requestFailed(statusCode: httpResponse.statusCode)))
                }
            }
        }
        
        task.resume()
    }
}
