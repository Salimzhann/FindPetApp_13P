//
//  PetDetailCell.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 08.04.2025.
//

import UIKit
import SnapKit

class PetDetailCell: UICollectionViewCell {
    
    static let identifier = "PetDetailCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(image: UIImage) {
        imageView.image = image
    }
    
    func configure(with imageUrlString: String) {
        guard let url = URL(string: imageUrlString) else {
            imageView.image = UIImage(named: "placeholder") // fallback
            return
        }

        // Простая загрузка без сторонних библиотек
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self, let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }.resume()
    }
}
