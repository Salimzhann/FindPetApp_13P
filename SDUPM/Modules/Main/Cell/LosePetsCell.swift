import UIKit
import SnapKit

class LosePetsCell: UICollectionViewCell {
    
    static let identifier: String = "LosePetsCell"

    private let imageView: UIImageView = {
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

    var item: LosePetsModel = LosePetsModel(id: 0, image: "", name: "", species: "", breed: "", age: "", sex: "") {
        didSet {
            loadImage(from: item.image, into: imageView)
            infoLabel.text = "\(item.name), \(item.age) лет"
            breedLabel.text = "\(item.species): \(item.breed)"
            sexLabel.text = item.sex
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
        imageView.image = nil
        infoLabel.text = nil
        breedLabel.text = nil
    }

    private func setupView() {
        backgroundColor = UIColor.systemGray6
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.4
        self.layer.borderColor = UIColor.black.cgColor
        
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
        addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(10)
        }
        
        addSubview(breedLabel)
        breedLabel.snp.makeConstraints { make in
            make.top.equalTo(infoLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().inset(10)
        }
        
        addSubview(sexLabel)
        sexLabel.snp.makeConstraints { make in
            make.top.equalTo(breedLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().inset(10)
            make.bottom.equalToSuperview().offset(-5)
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
