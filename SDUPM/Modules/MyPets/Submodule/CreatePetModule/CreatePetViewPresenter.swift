//
//  CreatePetViewPresenter.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 02.04.2025.
//

import UIKit

class CreatePetViewPresenter {
    
    private let provider = NetworkServiceProvider()
    
    func uploadPetData(name: String, age: String, breed: String, category: String, isLost: Bool, images: [UIImage], completion: @escaping (_ success: Bool) -> Void) {
//        provider.uploadPetData(
//            name: name,
//            age: age,
//            breed: breed,
//            category: category,
//            isLost: isLost,
//            images: images,
//            completion: completion
//        )
        
        completion(true)
    }
}
