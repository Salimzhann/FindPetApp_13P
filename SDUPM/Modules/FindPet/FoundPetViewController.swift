//
//  FoundPetViewController.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 11.04.2025.
//

// File path: SDUPM/Modules/FindPet/FoundPetViewController.swift

import UIKit
import SnapKit

class FoundPetViewController: UIViewController {
    
    private let searchResponse: PetSearchResponse
    private var matches: [PetMatch] {
        return searchResponse.matches
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 120
        return tableView
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let emptyStateImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "pawprint.circle"))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No matching pets found"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = .systemGray
        return label
    }()
    
    private let sheltersLabel: UILabel = {
        let label = UILabel()
        label.text = "Nearby Animal Shelters"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let shelterView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        return view
    }()
    
    private let shelterName: UILabel = {
        let label = UILabel()
        label.text = "Сказка живой природы"
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let shelterDescription: UILabel = {
        let label = UILabel()
        label.text = "Реабилитационный центр для диких животных"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let shelterRating: UILabel = {
        let label = UILabel()
        label.text = "4.6 ★"
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = .systemYellow
        return label
    }()
    
    private let shelterAddress: UILabel = {
        let label = UILabel()
        label.text = "Улица Учетный квартал 152, 1, с. Болек, Енбекшиказахский район, Алматинская область"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.numberOfLines = 0
        return label
    }()
    
    private let shelterHours: UILabel = {
        let label = UILabel()
        label.text = "Ежедневно с 09:00 до 18:00"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let shelterInstagram: UILabel = {
        let label = UILabel()
        label.text = "Instagram: https://go.2gis.com/7bBCG"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemBlue
        return label
    }()
    
    init(searchResponse: PetSearchResponse) {
        self.searchResponse = searchResponse
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupTableView()
        updateEmptyState()
    }
    
    private func setupView() {
        title = "Search Results"
        view.backgroundColor = .systemBackground
        
        // Table View
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Empty State View
        view.addSubview(emptyStateView)
        emptyStateView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        emptyStateView.addSubview(emptyStateImage)
        emptyStateImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(100)
            make.width.height.equalTo(80)
        }
        
        emptyStateView.addSubview(emptyStateLabel)
        emptyStateLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyStateImage.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        emptyStateView.addSubview(sheltersLabel)
        sheltersLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(emptyStateLabel.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        emptyStateView.addSubview(shelterView)
        shelterView.snp.makeConstraints { make in
            make.top.equalTo(sheltersLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        shelterView.addSubview(shelterName)
        shelterName.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
        }
        
        shelterView.addSubview(shelterDescription)
        shelterDescription.snp.makeConstraints { make in
            make.top.equalTo(shelterName.snp.bottom).offset(4)
            make.leading.equalToSuperview().inset(16)
        }
        
        shelterView.addSubview(shelterRating)
        shelterRating.snp.makeConstraints { make in
            make.top.equalTo(shelterDescription.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        shelterView.addSubview(shelterAddress)
        shelterAddress.snp.makeConstraints { make in
            make.top.equalTo(shelterRating.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        shelterView.addSubview(shelterHours)
        shelterHours.snp.makeConstraints { make in
            make.top.equalTo(shelterAddress.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
        }
        
        shelterView.addSubview(shelterInstagram)
        shelterInstagram.snp.makeConstraints { make in
            make.top.equalTo(shelterHours.snp.bottom).offset(8)
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
        // Add tap gesture to the Instagram link
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openInstagramLink))
        shelterInstagram.isUserInteractionEnabled = true
        shelterInstagram.addGestureRecognizer(tapGesture)
    }
    
    private func setupTableView() {
        tableView.register(PetMatchCell.self, forCellReuseIdentifier: "PetMatchCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func updateEmptyState() {
        if matches.isEmpty {
            emptyStateView.isHidden = false
            tableView.isHidden = true
        } else {
            emptyStateView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    @objc private func openInstagramLink() {
        if let url = URL(string: "https://go.2gis.com/7bBCG") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension FoundPetViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matches.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PetMatchCell", for: indexPath) as! PetMatchCell
        let match = matches[indexPath.row]
        cell.configure(with: match)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let match = matches[indexPath.row]
        let detailVC = PetDetailViewController(pet: match.pet)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Custom Cell for Pet Matches
class PetMatchCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.95, green: 0.98, blue: 0.95, alpha: 1.0)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let petImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()
    
    private let speciesLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let breedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let similarityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGreen
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        containerView.addSubview(petImageView)
        petImageView.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview().inset(12)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.leading.equalTo(petImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12).priority(.high)
        }
        
        containerView.addSubview(speciesLabel)
        speciesLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(petImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12).priority(.high)
        }
        
        containerView.addSubview(breedLabel)
        breedLabel.snp.makeConstraints { make in
            make.top.equalTo(speciesLabel.snp.bottom).offset(4)
            make.leading.equalTo(petImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12).priority(.high)
        }
        
        containerView.addSubview(similarityLabel)
        similarityLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview().inset(12)
            make.leading.equalTo(petImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(12).priority(.high)
        }
    }
    
    func configure(with match: PetMatch) {
        let pet = match.pet
        
        nameLabel.text = pet.name
        speciesLabel.text = "Species: \(pet.species.capitalized)"
        breedLabel.text = "Breed: \(pet.breed)"
        similarityLabel.text = "Match: \(match.similarityPercentage)%"
        
        // Load image
        if let imageURL = pet.mainPhotoURL {
            loadImage(from: imageURL)
        } else {
            petImageView.image = UIImage(systemName: "pawprint.fill")
            petImageView.tintColor = .systemGray3
        }
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                return
            }
            
            DispatchQueue.main.async {
                self?.petImageView.image = image
            }
        }.resume()
    }
}
