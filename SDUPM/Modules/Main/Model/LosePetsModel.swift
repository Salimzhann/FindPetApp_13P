//
//  LosePetsModel.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 01.04.2025.
//

import Foundation

struct LosePetsModel: Codable {
    let id: Int
    let image: String
    let name: String
    let species: String
    let breed: String
    let age: String
    let sex: String
}

struct LosePetsResponse {
    let array: [LosePetsModel] = [
        LosePetsModel(
            id: 1,
            image: "https://media.4-paws.org/d/2/5/f/d25ff020556e4b5eae747c55576f3b50886c0b90/cut%20cat%20serhio%2002-1813x1811-720x719.jpg",
            name: "Banderas",
            species: "Cat",
            breed: "Britan",
            age: "2",
            sex: "Female"
        ),
        LosePetsModel(
            id: 1,
            image: "https://media.4-paws.org/d/2/5/f/d25ff020556e4b5eae747c55576f3b50886c0b90/cut%20cat%20serhio%2002-1813x1811-720x719.jpg",
            name: "Banderas",
            species: "Cat",
            breed: "Britan",
            age: "2",
            sex: "Female"
        ),
        LosePetsModel(
            id: 1,
            image: "https://media.4-paws.org/d/2/5/f/d25ff020556e4b5eae747c55576f3b50886c0b90/cut%20cat%20serhio%2002-1813x1811-720x719.jpg",
            name: "Banderas",
            species: "Cat",
            breed: "Britan",
            age: "2",
            sex: "Female"
        ),
        LosePetsModel(
            id: 1,
            image: "https://media.4-paws.org/d/2/5/f/d25ff020556e4b5eae747c55576f3b50886c0b90/cut%20cat%20serhio%2002-1813x1811-720x719.jpg",
            name: "Banderas",
            species: "Cat",
            breed: "Britan",
            age: "2",
            sex: "Female"
        ),
        LosePetsModel(
            id: 1,
            image: "https://media.4-paws.org/d/2/5/f/d25ff020556e4b5eae747c55576f3b50886c0b90/cut%20cat%20serhio%2002-1813x1811-720x719.jpg",
            name: "Banderas",
            species: "Cat",
            breed: "Britan",
            age: "2",
            sex: "Female"
        ),
        LosePetsModel(
            id: 1,
            image: "https://media.4-paws.org/d/2/5/f/d25ff020556e4b5eae747c55576f3b50886c0b90/cut%20cat%20serhio%2002-1813x1811-720x719.jpg",
            name: "Banderas",
            species: "Cat",
            breed: "Britan",
            age: "2",
            sex: "Female"
        ),
        LosePetsModel(
            id: 1,
            image: "https://media.4-paws.org/d/2/5/f/d25ff020556e4b5eae747c55576f3b50886c0b90/cut%20cat%20serhio%2002-1813x1811-720x719.jpg",
            name: "Banderas",
            species: "Cat",
            breed: "Britan",
            age: "2",
            sex: "Female"
        )
    ]
}
