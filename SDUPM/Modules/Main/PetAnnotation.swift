//
//  PetAnnotation.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 18.04.2025.
//

import MapKit

class PetAnnotation: NSObject, MKAnnotation {
    let pet: LostPet
    var coordinate: CLLocationCoordinate2D
    
    init(pet: LostPet, coordinate: CLLocationCoordinate2D) {
        self.pet = pet
        self.coordinate = coordinate
        super.init()
    }
    
    var title: String? {
        return pet.name
    }
    
    var subtitle: String? {
        return "\(pet.species), \(pet.breed)"
    }
}
