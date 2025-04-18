//
//  PetDetailInformationPresenter.swift
//  SDUPM
//
//  Created by Manas Salimzhan on 01.04.2025.
//

import UIKit

protocol IPetDetailInformationPresenter {
    func sendRequest(id: Int)
    func callTaped(id: Int)
}


class PetDetailInformationPresenter: IPetDetailInformationPresenter {
    
    private let provider = NetworkServiceProvider()
    weak var view: IPetDetailInformationViewController?
    
    private let tempArray: [PetDetailInfoModel] = [
        PetDetailInfoModel(
            images: [
                "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg",
                "https://media.4-paws.org/9/c/9/7/9c97c38666efa11b79d94619cc1db56e8c43d430/Molly_006-2829x1886-2726x1886-1920x1328.jpg",
                "https://www.rspcasa.org.au/wp-content/uploads/2024/08/Cat-Management-Act-Review-2.png"
            ],
            name: "Angela",
            breed: "British Shorthair",
            age: "2",
            gender: "female",
            description: "A calm British Shorthair cat with soft grey fur and amber eyes. Friendly and quiet.",
            phone: "87082627711",
            gisLing: "https://go.2gis.com/LRmxH"
        ),
        PetDetailInfoModel(
            images: [
                "https://www.al.com/resizer/v2/https%3A%2F%2Fadvancelocal-adapter-image-uploads.s3.amazonaws.com%2Fimage.al.com%2Fhome%2Fbama-media%2Fwidth2048%2Fimg%2Fnews_impact%2Fphoto%2F22988780-standard.jpg?auth=2c452c2123ce33d2c1154e76aad2bf00012acecfd930e7d600fb032c32df7249&width=1280&quality=90",
                "https://i2-prod.getsurrey.co.uk/news/real-life/article31159093.ece/ALTERNATES/s1200d/0_Cute-Labrador-retriever-looking-at-camera.jpg",
                "https://puppyintraining.com/wp-content/uploads/2011/12/Dublin-Shopping.jpg"
            ],
            name: "Max",
            breed: "Labrador Retriever",
            age: "3",
            gender: "male",
            description: "Very active and playful labrador, loves to fetch and swim.",
            phone: "87475223454",
            gisLing: "https://go.2gis.com/9J37I"
        ),
        PetDetailInfoModel(
            images: [
                "https://www.aspca.org/sites/default/files/cat-care_general-cat-care_body1-left.jpg",
                "https://med.stanford.edu/content/dam/sm-news/images/2021/09/cat_by-Kateryna-T-Unsplash.jpg",
                "https://media.4-paws.org/c/f/0/6/cf065689b6f82a397b40846d88b622ba5068de84/VIER%20PFOTEN_2016-07-08_011-4993x3455.jpg"
            ],
            name: "Bella",
            breed: "Siamese",
            age: "1",
            gender: "female",
            description: "Small Siamese kitten with blue eyes. Loves attention and cuddles.",
            phone: "87773678909",
            gisLing: "https://go.2gis.com/CmBWM"
        ),
        PetDetailInfoModel(
            images: [
                "https://www.nylabone.com/-/media/Project/OneWeb/Nylabone/Images/Dog101/why-does-my-dog-stare-at-me/header-cropped.jpg",
                "https://media.graphassets.com/resize=height:360,width:938/output=format:webp/j37rrzIERO05banfylNX?width=938",
                "https://www.cleveland.com/resizer/v2/https%3A%2F%2Fadvancelocal-adapter-image-uploads.s3.amazonaws.com%2Fimage.cleveland.com%2Fhome%2Fcleve-media%2Fwidth2048%2Fimg%2Finsideout_impact%2Fphoto%2Fbluebell-1jpg-0072af5c53b69767.jpg?auth=170f33f78e9128106b21badc62d792edc941ae28b0be8a299bfc296431ccb77d&width=800&quality=90"
            ],
            name: "Charlie",
            breed: "Beagle",
            age: "5",
            gender: "male",
            description: "Energetic beagle with a great sense of smell. Often howls when excited.",
            phone: "87084923708",
            gisLing: "https://go.2gis.com/pBgHB"
        ),
        PetDetailInfoModel(
            images: [
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQQLmPCY9C_wToejxv23H8KDQ-CdQj0hOjjiA&s",
                "https://www.catsluvus.com/wp-content/uploads/2024/04/308c546cthumbnail-1080x675.jpeg",
                "https://www.google.com/url?sa=i&url=https%3A%2F%2Fpethelpful.com%2Fcats%2Fthe-unique-breed-ragdoll&psig=AOvVaw0Us056TI06TrkbdimNP720&ust=1744509773934000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCJDBjb6z0YwDFQAAAAAdAAAAABBH"
            ],
            name: "Lucy",
            breed: "Persian",
            age: "4",
            gender: "female",
            description: "Fluffy Persian cat with white fur and green eyes. Very calm and sleeps a lot.",
            phone: "87017308376",
            gisLing: "https://go.2gis.com/asTYr"
        ),
        PetDetailInfoModel(
            images: [
                "https://cdn.britannica.com/79/232779-050-6B0411D7/German-Shepherd-dog-Alsatian.jpg",
                "https://cdn.shopify.com/s/files/1/1831/0741/files/pettsie-awesome-facts-about-German-Shepherds.jpg?v=1623746710",
                "https://image.petmd.com/files/inline-images/german-shepherd-3.jpg?VersionId=QrldSoaj4srcfCInIahiKcoLSh5D0gh8"
            ],
            name: "Rocky",
            breed: "sheep dog",
            age: "2",
            gender: "male",
            description: "Energetic german sheep dog with brown eyes. Loves running and cold weather.",
            phone: "87017755531",
            gisLing: "https://go.2gis.com/BXv41"
        ),
        PetDetailInfoModel(
            images: [
                "https://www.tippaws.com/cdn/shop/articles/getting-to-know-your-bengal-cat-tippaws.png?v=1729077812",
                "https://images.ctfassets.net/440y9b545yd9/4af4BhzBytX2ZP98blnIQe/bda64578de3f1ea485c6e758c78e8cb1/Bengal850.jpg",
                "https://cdn.mos.cms.futurecdn.net/Uwu9iN5UXkusxNwr2Dixuh.jpg",
                "https://cdn-prd.content.metamorphosis.com/wp-content/uploads/sites/2/2022/09/shutterstock_588477563-1.jpg"
            ],
            name: "Molly",
            breed: "Bengal Cat",
            age: "6",
            gender: "female",
            description: "Large and gentle Maine Coon cat. Very affectionate and curious.",
            phone: "87017308376",
            gisLing: "https://go.2gis.com/asTYr"
        ),
        PetDetailInfoModel(
            images: [
                "https://www.thesprucepets.com/thmb/hxWjs7evF2hP1Fb1c1HAvRi_Rw0=/2765x0/filters:no_upscale():strip_icc()/chinese-dog-breeds-4797219-hero-2a1e9c5ed2c54d00aef75b05c5db399c.jpg",
                "https://cdn.britannica.com/34/233234-050-1649BFA9/Pug-dog.jpg"
            ],
            name: "Buddy",
            breed: "Toy Poodle",
            age: "3",
            gender: "male",
            description: "Tiny poodle with a lot of energy. Loves to be around people and other dogs.",
            phone: "87773678909",
            gisLing: "https://go.2gis.com/CmBWM"
        )
    ]
    
    func sendRequest(id: Int) {
//        provider.petDetailInfo(id: id) { [weak self] data in
//            self?.view?.detailInfo = data
//        }
        self.view?.detailInfo = tempArray[id-1]
    }
    
    func gisLinkTaped(id: Int) {
        
        let link = tempArray[id-1].gisLing
        if let url = URL(string: link) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
    }
    
    func callTaped(id: Int) {
        
        let cleanedNumber = tempArray[id-1].phone
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
            
            // Кодируем "+" для URL
            let encodedNumber = cleanedNumber.replacingOccurrences(of: "+", with: "%2B")
        
        if let url = URL(string: "tel://\(encodedNumber)") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                print("❌ Can't make a call on this device")
            }
        }
    }
    
}
