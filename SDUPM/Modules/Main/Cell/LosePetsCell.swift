import UIKit
import SnapKit

class LosePetsCell: UICollectionViewCell {
    
    static let identifier: String = "LosePetsCell"

    private let petImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        imageView.backgroundColor = .systemGray6
        imageView.image = UIImage(systemName: "pawprint.fill")
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
    private let infoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let breedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .systemRed
        return label
    }()

    var pet: LostPet? {
        didSet {
            if let pet = pet {
                // Загрузка изображения, если оно доступно
                if let mainPhotoURL = pet.mainPhotoURL?.absoluteString {
                    loadImage(from: mainPhotoURL, into: petImageView)
                } else {
                    petImageView.image = UIImage(systemName: "pawprint.fill")
                    petImageView.tintColor = .systemGray3
                }
                
                infoLabel.text = pet.name
                breedLabel.text = "Вид: \(pet.species), Порода: \(pet.breed.isEmpty ? "Не указана" : pet.breed)"
                
                if let lostDate = pet.lost_date {
                    statusLabel.text = "Потерян: \(formattedDate(from: lostDate))"
                } else {
                    statusLabel.text = "Статус: \(pet.status)"
                }
            }
            
            setupView()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        petImageView.image = UIImage(systemName: "pawprint.fill")
        petImageView.tintColor = .systemGray3
        infoLabel.text = nil
        breedLabel.text = nil
        statusLabel.text = nil
    }

    private func setupView() {
        backgroundColor = UIColor(red: 0.8, green: 1.0, blue: 0.8, alpha: 1.0)
        self.layer.cornerRadius = 12
        
        addSubview(petImageView)
        petImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(10)
            make.width.equalTo(70)
            make.height.equalTo(70)
        }
        
        addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(petImageView.snp.trailing).offset(10)
        }
        
        addSubview(breedLabel)
        breedLabel.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(5)
            make.leading.equalTo(infoLabel)
        }
        
        addSubview(statusLabel)
        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(breedLabel.snp.bottom).offset(5)
            make.leading.equalTo(breedLabel)
        }
    }

    func loadImage(from url: String, into imageView: UIImageView) {
        guard let imageURL = URL(string: url) else { return }

        let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                imageView.image = image
            }
        }
        task.resume()
    }
    
    private func formattedDate(from dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd.MM.yyyy"
        return outputFormatter.string(from: date)
    }
}
