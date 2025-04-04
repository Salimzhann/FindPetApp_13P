//
//  MyPetCell.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 02.04.2025.
//

import UIKit

class MyPetCell: UITableViewCell {
    private let petImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .medium)
        return label
    }()
    private let breedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    static let identifier = "MyPetCell"
    
    var item: MyPetModel? {
        didSet {
            nameLabel.text = item?.name
            breedLabel.text = item?.breed
            categoryLabel.text = item?.category
            ageLabel.text = item?.age
            genderLabel.text = item?.gender
            statusLabel.text = item!.status ? "Lost" : "Save"
        }
    }
}
