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
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .bold)
        label.textColor = .label
        return label
    }()
    
    private let speciesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let ageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    var item: LostPet? {
        didSet {
            if let item = item {
                nameLabel.text = item.name
                speciesLabel.text = "Type: \(item.species.capitalized)"
                
                if let age = item.age {
                    ageLabel.text = "Age: \(age) year\(age > 1 ? "s" : "")"
                } else {
                    ageLabel.text = "Age: unknown"
                }
                
                if let gender = item.gender {
                    genderLabel.text = "Gender: \(gender.capitalized)"
                } else {
                    genderLabel.text = "Gender: unknown"
                }
                
                if let imageUrl = item.imageUrl {
                    loadImage(from: imageUrl)
                } else {
                    petImageView.image = UIImage(systemName: "pawprint.fill")
                    petImageView.tintColor = .systemGray3
                }
            }
            setupView()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        petImageView.image = nil
        nameLabel.text = nil
        speciesLabel.text = nil
        genderLabel.text = nil
        ageLabel.text = nil
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
        
        addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalTo(petImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(10)
        }
        
        addSubview(speciesLabel)
        speciesLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.leading.equalTo(nameLabel)
            make.trailing.equalToSuperview().inset(10)
        }
        
        addSubview(ageLabel)
        ageLabel.snp.makeConstraints { make in
            make.top.equalTo(speciesLabel.snp.bottom).offset(5)
            make.leading.equalTo(speciesLabel)
            make.trailing.equalToSuperview().inset(10)
        }
        
        addSubview(genderLabel)
        genderLabel.snp.makeConstraints { make in
            make.top.equalTo(ageLabel.snp.bottom).offset(5)
            make.leading.equalTo(ageLabel)
            make.trailing.equalToSuperview().inset(10)
            make.bottom.lessThanOrEqualToSuperview().inset(10)
        }
    }

    func loadImage(from url: String) {
        guard let imageURL = URL(string: url) else {
            petImageView.image = UIImage(systemName: "pawprint.fill")
            petImageView.tintColor = .systemGray3
            return
        }

        let task = URLSession.shared.dataTask(with: imageURL) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.petImageView.image = UIImage(systemName: "pawprint.fill")
                    self?.petImageView.tintColor = .systemGray3
                }
                return
            }

            DispatchQueue.main.async {
                self.petImageView.image = image
            }
        }
        task.resume()
    }
}
