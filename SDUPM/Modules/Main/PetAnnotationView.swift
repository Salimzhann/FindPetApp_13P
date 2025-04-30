import MapKit
import UIKit

class PetAnnotationView: MKAnnotationView {
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private var imageTask: URLSessionDataTask?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        // Configure the main view
        frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        backgroundColor = .clear
        
        // Configure the image view
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.backgroundColor = .systemGray5
        addSubview(imageView)
        
        // Configure the callout
        canShowCallout = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageView.image = nil
    }
    
    func configure(with petAnnotation: PetAnnotation) {
        // Set the pet image
        if let photoUrl = petAnnotation.pet.imageUrl, let url = URL(string: photoUrl) {
            loadImage(from: url)
        } else {
            // Use a placeholder image if no image URL is available
            imageView.image = UIImage(systemName: "pawprint.fill")
            imageView.tintColor = .systemGray3
        }
    }
    
    private func loadImage(from url: URL) {
        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self?.imageView.image = UIImage(systemName: "pawprint.fill")
                    self?.imageView.tintColor = .systemGray3
                }
                return
            }
            
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        }
        imageTask?.resume()
    }
}
