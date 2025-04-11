import UIKit
import SnapKit

class LosePetsCell: UICollectionViewCell {
    
    static let identifier: String = "LosePetsCell"

    private let petImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
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
    private let sexLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()

    var item: LostPet? {
        didSet {
            loadImage(from: item?.imageUrl ?? "", into: petImageView)
            infoLabel.text = "\(item?.name), \(item?.age) лет"
            breedLabel.text = "\(item?.species)"
            sexLabel.text = item?.gender
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        petImageView.image = nil
        infoLabel.text = nil
        breedLabel.text = nil
    }

    private func setupView() {
        backgroundColor = UIColor(red: 0.8, green: 1.0, blue: 0.8, alpha: 1.0)
        self.layer.cornerRadius = 12
        
        addSubview(petImageView)
        petImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(10)
            make.width.equalTo(130)
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
        
        addSubview(sexLabel)
        sexLabel.snp.makeConstraints { make in
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
}
