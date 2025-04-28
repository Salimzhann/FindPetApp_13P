import UIKit
import SnapKit

protocol ProfileViewProtocol: AnyObject {
    func configure(with model: UserProfile)
    func showLoading()
    func hideLoading()
    func showError(message: String)
    func showSuccess(message: String)
}

class ProfileView: UIViewController, ProfileViewProtocol, EditProfileDelegate {
    
    private let presenter: ProfilePresenterProtocol = ProfilePresenter()
    
    private var userProfile: UserProfile?
    
    // MARK: - UI Components
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let profileImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.image = UIImage(systemName: "person.circle.fill")
        image.tintColor = .systemGray3
        image.clipsToBounds = true
        image.layer.cornerRadius = 50
        return image
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .gray
        return indicator
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "gear"), for: .normal)
        button.tintColor = .systemGreen
        button.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        return button
    }()
    
    private let infoView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let memberSinceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let accountStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemGray4
        button.tintColor = .white
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let deleteAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete Account", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = .systemRed
        button.tintColor = .white
        button.layer.cornerRadius = 12
        return button
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
        (presenter as? ProfilePresenter)?.view = self
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.fetchProfile()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        title = "Profile"
        view.backgroundColor = .systemBackground
        
        // Setup navigation bar with edit button
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: editButton)
        
        
        view.addSubview(loadingIndicator)
        
        view.addSubview(profileImage)
        profileImage.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(100)
        }
        
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImage.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(emailLabel)
        emailLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(phoneLabel)
        phoneLabel.snp.makeConstraints { make in
            make.top.equalTo(emailLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        view.addSubview(deleteAccountButton)
        deleteAccountButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }
        
        view.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.bottom.equalTo(deleteAccountButton.snp.top).offset(-10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(50)
        }

        // Loading Indicator
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setupActions() {
        editButton.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        deleteAccountButton.addTarget(self, action: #selector(deleteAccountTapped), for: .touchUpInside)
    }
    
    @objc private func editProfileTapped() {
        guard let profile = userProfile else { return }
        
        let editVC = EditProfileViewController(
            presenter: presenter,
            fullName: profile.fullName,
            phone: profile.phone
        )
        editVC.delegate = self
        
        let navController = UINavigationController(rootViewController: editVC)
        navController.modalPresentationStyle = .pageSheet
        
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        present(navController, animated: true)
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(
            title: "Log Out",
            message: "Are you sure you want to log out?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive) { [weak self] _ in
            self?.presenter.logout()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func deleteAccountTapped() {
        let alert = UIAlertController(
            title: "Delete Account",
            message: "Are you sure you want to delete your account? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.presenter.deleteAccount()
        })
        
        present(alert, animated: true)
    }
    
    // MARK: - EditProfileDelegate
    
    func profileUpdated(fullName: String, phone: String) {
        // Update local UI immediately while the server update is processing
        nameLabel.text = fullName
        phoneLabel.text = phone
        
        // The full profile refresh will happen in viewWillAppear
        // Optionally show a success message
        showSuccess(message: "Profile updated successfully")
    }
    
    // MARK: - ProfileViewProtocol
    
    func configure(with model: UserProfile) {
        userProfile = model
        
        nameLabel.text = model.fullName
        emailLabel.text = model.email
        phoneLabel.text = model.phone
        
        // Format and set created date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        if let date = dateFormatter.date(from: model.createdAt) {
            dateFormatter.dateFormat = "MMMM d, yyyy"
            memberSinceLabel.text = "Member since: \(dateFormatter.string(from: date))"
        } else {
            memberSinceLabel.text = "Member since: Unknown"
        }
        
        // Set account status
        let verificationStatus = model.isVerified ? "Verified" : "Not verified"
        let activeStatus = model.isActive ? "Active" : "Inactive"
        accountStatusLabel.text = "Account status: \(verificationStatus), \(activeStatus)"
    }
    
    func showLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.loadingIndicator.startAnimating()
            self?.view.isUserInteractionEnabled = false
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.loadingIndicator.stopAnimating()
            self?.view.isUserInteractionEnabled = true
        }
    }
    
    func showError(message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    func showSuccess(message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    private func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
