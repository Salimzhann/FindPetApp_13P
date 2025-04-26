// Путь: SDUPM/Modules/MyPets/MyPetCell.swift

import UIKit
import SnapKit

class MyPetCell: UICollectionViewCell {
    static let identifier = "MyPetCell"
    
    // MARK: - UI Components
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray5.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.clipsToBounds = false
        return view
    }()
    
    private let petImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let speciesLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let breedLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let genderLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let statusBadge: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        return view
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    // Улучшенная кнопка редактирования - компактная версия
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        
        // Настройка фона и формы - компактный круглый дизайн
        button.backgroundColor = UIColor.systemGray4
        button.layer.cornerRadius = 12
        
        // Настройка иконки с оптимальным размером
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        let image = UIImage(systemName: "pencil", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .systemGreen
        
        // Компактные отступы
        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        
        // Легкая тень для выделения, но не перегружая
        button.layer.shadowColor = UIColor.systemGreen.withAlphaComponent(0.2).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 1)
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.2
        
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash.circle.fill"), for: .normal)
        button.tintColor = .systemRed
        button.isHidden = true  // По умолчанию скрыта
        return button
    }()
    
    var onEditTapped: (() -> Void)?
    var onDeleteTapped: (() -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        contentView.addSubview(containerView)
        containerView.addSubview(petImageView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(speciesLabel)
        containerView.addSubview(breedLabel)
        containerView.addSubview(genderLabel)
        containerView.addSubview(statusBadge)
        containerView.addSubview(editButton)
        containerView.addSubview(deleteButton)
        statusBadge.addSubview(statusLabel)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        petImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(12)
            make.width.equalTo(100)
            make.height.equalTo(100)
        }
        
        // Изменена позиция кнопки редактирования - верхний правый угол
        editButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.trailing.equalToSuperview().inset(12)
            make.size.equalTo(24)
        }
        
        deleteButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(12)
            make.trailing.equalToSuperview().inset(12)
            make.width.height.equalTo(30)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(petImageView).offset(2)
            make.leading.equalTo(petImageView.snp.trailing).offset(12)
            make.trailing.equalTo(editButton.snp.leading).offset(-8)
        }
        
        statusBadge.snp.makeConstraints { make in
            make.centerY.equalTo(nameLabel)
            make.trailing.equalTo(editButton.snp.leading).offset(-12)
            make.height.equalTo(20)
        }
        
        statusLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(8)
        }
        
        speciesLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
            make.trailing.equalToSuperview().inset(12)
        }
        
        breedLabel.snp.makeConstraints { make in
            make.top.equalTo(speciesLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
            make.trailing.equalToSuperview().inset(12)
        }
        
        genderLabel.snp.makeConstraints { make in
            make.top.equalTo(breedLabel.snp.bottom).offset(4)
            make.leading.equalTo(nameLabel)
            make.trailing.equalToSuperview().inset(12)
        }
    }
    
    private func setupActions() {
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        // Добавляем эффект нажатия
        editButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        editButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    @objc private func editButtonTapped() {
        onEditTapped?()
    }
    
    @objc private func deleteButtonTapped() {
        onDeleteTapped?()
    }
    
    // Добавляем анимации для более интерактивного отклика
    @objc private func buttonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.editButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.editButton.alpha = 0.9
        }
    }
    
    @objc private func buttonTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.editButton.transform = .identity
            self.editButton.alpha = 1.0
        }
    }
    
    // MARK: - Public Methods
    
    // Метод для показа или скрытия кнопки редактирования
    func showEditButton(_ show: Bool) {
        editButton.isHidden = !show
    }
    
    // Метод для показа или скрытия кнопки удаления
    func showDeleteButton(_ show: Bool) {
        deleteButton.isHidden = !show
    }
    
    // MARK: - Configuration
    
    func configure(with pet: MyPetModel) {
        nameLabel.text = pet.name
        speciesLabel.text = "Species: \(pet.species.capitalized)"
        breedLabel.text = "Breed: \(pet.breed)"
        genderLabel.text = "Gender: \(pet.gender.capitalized)"
        
        statusLabel.text = pet.statusFormatted
        statusBadge.backgroundColor = pet.statusColor
        
        if let image = pet.images.first {
            petImageView.image = image
        } else {
            petImageView.image = UIImage(systemName: "photo")
            petImageView.tintColor = .systemGray3
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        petImageView.image = nil
        nameLabel.text = nil
        speciesLabel.text = nil
        breedLabel.text = nil
        genderLabel.text = nil
        editButton.isHidden = false
        deleteButton.isHidden = true
    }
}
