import UIKit

class MainView: UIViewController {
    
    private let presenter = MainPresenter()
    
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
    
    private var petsArray: [LostPet] = [
        LostPet(id: 1, name: "Angela", age: 2, gender: "female", species: "cat", imageUrl: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg"),
        LostPet(id: 2, name: "Max", age: 3, gender: "male", species: "dog", imageUrl: "https://www.al.com/resizer/v2/https%3A%2F%2Fadvancelocal-adapter-image-uploads.s3.amazonaws.com%2Fimage.al.com%2Fhome%2Fbama-media%2Fwidth2048%2Fimg%2Fnews_impact%2Fphoto%2F22988780-standard.jpg?auth=2c452c2123ce33d2c1154e76aad2bf00012acecfd930e7d600fb032c32df7249&width=1280&quality=90"),
        LostPet(id: 3, name: "Bella", age: 1, gender: "female", species: "cat", imageUrl: "https://www.aspca.org/sites/default/files/cat-care_general-cat-care_body1-left.jpg"),
        LostPet(id: 4, name: "Charlie", age: 5, gender: "male", species: "dog", imageUrl: "https://www.nylabone.com/-/media/Project/OneWeb/Nylabone/Images/Dog101/why-does-my-dog-stare-at-me/header-cropped.jpg"),
        LostPet(id: 5, name: "Lucy", age: 4, gender: "female", species: "cat", imageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQLmPCY9C_wToejxv23H8KDQ-CdQj0hOjjiA&s"),
        LostPet(id: 6, name: "Rocky", age: 2, gender: "male", species: "dog", imageUrl: "https://cdn.britannica.com/79/232779-050-6B0411D7/German-Shepherd-dog-Alsatian.jpg"),
        LostPet(id: 7, name: "Molly", age: 6, gender: "female", species: "cat", imageUrl: "https://www.tippaws.com/cdn/shop/articles/getting-to-know-your-bengal-cat-tippaws.png?v=1729077812"),
        LostPet(id: 8, name: "Buddy", age: 3, gender: "male", species: "dog", imageUrl: "https://www.thesprucepets.com/thmb/hxWjs7evF2hP1Fb1c1HAvRi_Rw0=/2765x0/filters:no_upscale():strip_icc()/chinese-dog-breeds-4797219-hero-2a1e9c5ed2c54d00aef75b05c5db399c.jpg")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        presenter.view = self
        fetchData()
    }
    
    func setupUI() {
        navigationItem.title = "Lost Pets"
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = false
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(16)
        }
    }
    
    func fetchData() {
        collectionView.reloadData()
//        presenter.receiveData { data in
//            self.petsArray = data
//            self.collectionView.reloadData()
//        }
    }
}


extension MainView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        petsArray.count
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
