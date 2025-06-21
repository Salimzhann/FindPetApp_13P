import UIKit
import SnapKit
import MapKit
import CoreLocation

class MainView: UIViewController, MainViewProtocol {
    
    private let presenter: MainPresenterProtocol = MainPresenter()
    
    // MARK: - UI Components
    
    private let segmentedControl: UISegmentedControl = {
        let items = ["Lost", "Found"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.selectedSegmentTintColor = .systemGreen
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        return segmentedControl
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 10
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.showsVerticalScrollIndicator = false
        cv.register(LosePetsCell.self, forCellWithReuseIdentifier: LosePetsCell.identifier)
        return cv
    }()
    
    private let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .systemGreen
        
        // Add custom text
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.systemGreen]
        refreshControl.attributedTitle = NSAttributedString(
            string: "Pull to refresh pets",
            attributes: attributes
        )
        
        return refreshControl
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.color = .systemGreen
        return indicator
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let emptyView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    private let emptyImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "pawprint.circle"))
        imageView.tintColor = .systemGray3
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No pets found"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        return label
    }()
    
    private let viewModeSegmentedControl: UISegmentedControl = {
        let items = ["List", "Map"]
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = 0
        control.isHidden = true
        return control
    }()
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.isHidden = true
        return map
    }()
    
    private var petsArray: [LostPet] = []
    private var isMapViewActive = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        (presenter as? MainPresenter)?.view = self
        
        fetchLostPets()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        navigationItem.title = "Pets"
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        view.backgroundColor = .systemBackground
        
        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        
        view.addSubview(viewModeSegmentedControl)
        viewModeSegmentedControl.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(40)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(viewModeSegmentedControl.snp.top).offset(-16)
        }
        
        // Add refresh control to collection view
        collectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        
        view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(viewModeSegmentedControl.snp.top).offset(-16)
        }
        
        // Set the map delegate
        mapView.delegate = self
        
        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { make in
            make.center.equalTo(collectionView)
            make.width.equalToSuperview()
        }
        
        emptyView.addSubview(emptyImageView)
        emptyImageView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.height.equalTo(80)
        }
        
        emptyView.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { make in
            make.top.equalTo(emptyImageView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
        
        view.addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        view.addSubview(errorLabel)
        errorLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        viewModeSegmentedControl.addTarget(self, action: #selector(viewModeChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc private func segmentedControlChanged() {
        if segmentedControl.selectedSegmentIndex == 0 {
            viewModeSegmentedControl.isHidden = true
            mapView.isHidden = true
            collectionView.isHidden = false
            isMapViewActive = false
            fetchLostPets()
        } else {
            viewModeSegmentedControl.isHidden = false
            if viewModeSegmentedControl.selectedSegmentIndex == 1 {
                mapView.isHidden = false
                collectionView.isHidden = true
                isMapViewActive = true
            } else {
                mapView.isHidden = true
                collectionView.isHidden = false
                isMapViewActive = false
            }
            fetchFoundPets()
        }
    }
    
    @objc private func viewModeChanged() {
        if viewModeSegmentedControl.selectedSegmentIndex == 0 {
            mapView.isHidden = true
            collectionView.isHidden = false
            isMapViewActive = false
        } else {
            mapView.isHidden = false
            collectionView.isHidden = true
            isMapViewActive = true
            updateMapAnnotations()
        }
    }
    
    @objc private func handleRefresh() {
        // Fetch data based on current segment selection
        if segmentedControl.selectedSegmentIndex == 0 {
            fetchLostPets()
        } else {
            fetchFoundPets()
        }
    }
    
    // MARK: - Data Fetching
    
    private func fetchLostPets() {
        presenter.fetchLostPets()
    }
    
    private func fetchFoundPets() {
        presenter.fetchFoundPets()
    }
    
    // MARK: - Map Annotations
    
    private func updateMapAnnotations() {
        mapView.removeAnnotations(mapView.annotations)
        
        var annotations: [PetAnnotation] = []
        var validCoordinates: [CLLocationCoordinate2D] = []
        
        for pet in petsArray {
            // Используем реальные координаты из данных бэкенда
            if let coordinate = pet.coordinate {
                let annotation = PetAnnotation(pet: pet, coordinate: coordinate)
                annotations.append(annotation)
                validCoordinates.append(coordinate)
            } else {
                // Fallback на дефолтные координаты Алматы, если координаты отсутствуют
                let latitude = 43.222
                let longitude = 76.851
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let annotation = PetAnnotation(pet: pet, coordinate: coordinate)
                annotations.append(annotation)
            }
        }
        
        mapView.addAnnotations(annotations)
        
        // Центрируем карту на всех аннотациях
        if !validCoordinates.isEmpty {
            // Вычисляем регион, который покрывает все точки
            var minLat = validCoordinates[0].latitude
            var maxLat = validCoordinates[0].latitude
            var minLon = validCoordinates[0].longitude
            var maxLon = validCoordinates[0].longitude
            
            for coordinate in validCoordinates {
                minLat = min(minLat, coordinate.latitude)
                maxLat = max(maxLat, coordinate.latitude)
                minLon = min(minLon, coordinate.longitude)
                maxLon = max(maxLon, coordinate.longitude)
            }
            
            let centerLat = (minLat + maxLat) / 2
            let centerLon = (minLon + maxLon) / 2
            let spanLat = (maxLat - minLat) * 1.2 // Добавляем 20% отступа
            let spanLon = (maxLon - minLon) * 1.2
            
            // Минимальный размер региона
            let minSpan = 0.01
            
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                span: MKCoordinateSpan(
                    latitudeDelta: max(spanLat, minSpan),
                    longitudeDelta: max(spanLon, minSpan)
                )
            )
            mapView.setRegion(region, animated: true)
        } else if let firstAnnotation = annotations.first {
            // Если нет валидных координат, используем первую аннотацию
            let region = MKCoordinateRegion(
                center: firstAnnotation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
            mapView.setRegion(region, animated: true)
        }
    }
    
    // MARK: - MainViewProtocol
    
    func updatePets(_ pets: [LostPet]) {
        petsArray = pets
        
        if pets.isEmpty {
            collectionView.isHidden = true
            emptyView.isHidden = false
        } else {
            collectionView.isHidden = isMapViewActive
            emptyView.isHidden = true
            collectionView.reloadData()
            
            if isMapViewActive {
                updateMapAnnotations()
            }
        }
    }
    
    func showLoading() {
        collectionView.isHidden = true
        mapView.isHidden = true
        emptyView.isHidden = true
        errorLabel.isHidden = true
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        errorLabel.isHidden = true
        
        // End refresh control animation
        refreshControl.endRefreshing()
        
        if petsArray.isEmpty {
            emptyView.isHidden = false
            collectionView.isHidden = true
            mapView.isHidden = true
        } else {
            emptyView.isHidden = true
            collectionView.isHidden = isMapViewActive
            mapView.isHidden = !isMapViewActive
        }
    }
    
    func showError(message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        emptyView.isHidden = true
        collectionView.isHidden = true
        mapView.isHidden = true
        
        // End refresh control animation on error
        refreshControl.endRefreshing()
    }
    
    func showMapView() {
        viewModeSegmentedControl.selectedSegmentIndex = 1
        mapView.isHidden = false
        collectionView.isHidden = true
        isMapViewActive = true
        updateMapAnnotations()
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension MainView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return petsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LosePetsCell.identifier, for: indexPath) as! LosePetsCell
        cell.item = petsArray[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width
        return CGSize(width: cellWidth, height: 90)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        presenter.didTapDetail(id: petsArray[indexPath.item].id)
    }
}

// MARK: - MKMapViewDelegate

extension MainView: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't customize the user location annotation
        if annotation is MKUserLocation {
            return nil
        }
        
        // Handle our custom pet annotations
        if let petAnnotation = annotation as? PetAnnotation {
            let identifier = "PetAnnotation"
            
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? PetAnnotationView
            
            if annotationView == nil {
                annotationView = PetAnnotationView(annotation: petAnnotation, reuseIdentifier: identifier)
            } else {
                annotationView?.annotation = petAnnotation
            }
            
            // Configure the annotation view with pet data
            annotationView?.configure(with: petAnnotation)
            return annotationView
        }
        
        // For any other annotations, use the default view
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // When a pet annotation is tapped, navigate to the pet detail screen
        if let petAnnotation = view.annotation as? PetAnnotation {
            presenter.didTapDetail(id: petAnnotation.pet.id)
        }
    }
}
