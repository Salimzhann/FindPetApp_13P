SDUPM is a comprehensive iOS application designed to help reunite lost pets with their owners. The app provides a platform for pet owners to register their lost pets, while also allowing people who find lost pets to post information about them. Through advanced image recognition and matching algorithms, the app helps identify potential matches between lost and found pets.
Key Features

Lost & Found Pet Registry: Register lost pets or report found pets with detailed information
AI-Powered Pet Matching: Advanced image recognition to match lost and found pets
Real-time Chat: Direct communication between pet owners and finders
User Profiles: Manage your pet information and account details
Location Services: See pets lost or found in your vicinity
Search Functionality: Find pets by species, breed, color, and more

📋 Project Structure
The project follows a modular structure for better organization and maintainability:
SDUPM/
├── Modules/
│   ├── Chat/               - Chat functionality between users
│   ├── FindPet/            - Search and match pet functionality
│   ├── Main/               - Main application screens
│   ├── MyPets/             - User's pet management
│   ├── Profile/            - User profile management
│   ├── RegistrationViews/  - Authentication & registration
│   └── TapBarNavigation/   - Navigation structure
├── NetworkService/         - API communication layer
└── Resources/              - Assets and resources
🚀 Getting Started
Prerequisites

iOS 14.0+
Xcode 13.0+
Swift 5.5+
CocoaPods (for dependency management)

Installation

Clone the repository
bashgit clone https://github.com/yourusername/SDUPM.git

Install dependencies
bashcd SDUPM
pod install

Open the workspace file
bashopen SDUPM.xcworkspace

Build and run the project in Xcode

🧠 Technical Implementation
Architecture
The app follows the MVP (Model-View-Presenter) architectural pattern, providing a clean separation of concerns:

Model: Data structures and business logic
View: UI components and layouts
Presenter: Mediates between Model and View, handling user interactions

Key Components

NetworkServiceProvider: Handles all API communication
ChatPresenter/ChatViewController: Manages real-time chat functionality
FindPetPresenter/FindPetViewController: Handles pet search and matching
ProfilePresenter/ProfileView: Manages user profile information
Authentication: Secure login, registration, and email verification

Technologies Used

UIKit: For native iOS UI components
SnapKit: For programmatic Auto Layout constraints
WebSockets: For real-time chat communication
URLSession: For API communication
CoreLocation: For location-based services
AVFoundation: For camera integration

📊 Data Models
The app uses several key data models:

Pet: Contains pet details including species, breed, photos, and status
Chat: Manages conversation data between users
User: User profile and authentication information
PetMatch: Links between potentially matching pets with similarity scores

🔄 API Integration
The app communicates with a RESTful backend API for data persistence and retrieval:

Authentication API: User registration, login, and verification
Pets API: Create, read, update, and delete pet information
Chat API: Message management and WebSocket connections
Search API: Pet matching and search functionality

📃 Documentation
Detailed documentation is available in the /docs directory, including:

API documentation
Architecture overview
User flows
Development guidelines

✅ Testing
The project includes unit tests for key functionality. Run the tests in Xcode using Cmd+U.
🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

Fork the repository
Create your feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add some amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request

📝 License
This project is licensed under the MIT License - see the LICENSE file for details.
📞 Contact
Project Maintainer - manassalimzhan04@gmail.com

Made with ❤️ by the Manas Salimzhan
