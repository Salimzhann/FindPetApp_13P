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
            categoryLabel.text = item?.species
            genderLabel.text = "\(item?.lostDate)"
            statusLabel.text = item?.status
            setupView()
        }
    }
    
    private func setupView() {
        
        addSubview(petImageView)
        petImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().inset(8)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(60)
            make.width.equalTo(100)
        }
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalTo(petImageView.snp.trailing).offset(5)
        }
        
        addSubview(genderLabel)
        genderLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.leading.equalTo(nameLabel)
        }
        
    }
}
