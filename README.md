# PocketPilot - Expense Tracking iOS App

A modern SwiftUI-based iOS application for tracking and managing expenses with real-time updates, secure authentication, and comprehensive expense management features.

## ðŸ“± Project Structure

\\\
PocketPilot-Fe/
â”œâ”€â”€ pocketPilot/
â”‚   â”œâ”€â”€ App/                    # App entry point
â”‚   â”œâ”€â”€ Core/                   # Core functionality
â”‚   â”‚   â”œâ”€â”€ Authentication/     # Auth management
â”‚   â”‚   â”œâ”€â”€ Network/           # API client & networking
â”‚   â”‚   â”œâ”€â”€ Storage/           # Keychain, UserDefaults, CoreData
â”‚   â”‚   â”œâ”€â”€ Utilities/         # Helpers & extensions
â”‚   â”‚   â””â”€â”€ WebSocket/         # Real-time updates
â”‚   â””â”€â”€ Features/              # Feature modules
â”‚       â”œâ”€â”€ Authentication/    # Login, SignUp views
â”‚       â”œâ”€â”€ Dashboard/         # Dashboard & stats
â”‚       â”œâ”€â”€ Expenses/          # Expense management
â”‚       â”œâ”€â”€ Profile/           # User profile
â”‚       â””â”€â”€ Components/        # Reusable UI components
â””â”€â”€ pocketPilot.xcodeproj/     # Xcode project
\\\

## ðŸš€ Prerequisites

### For iOS Development on Windows:

**âš ï¸ Important:** iOS development requires macOS and Xcode. You cannot build iOS apps directly on Windows.

**Option 1: Using macOS (Recommended)**
- You need a Mac with Xcode installed to build and run iOS apps
- If you don't have a Mac, consider:
  - Using a Mac in the cloud (MacStadium, AWS EC2 Mac instances)
  - Using a Mac VM (requires macOS license)
  - Using a Hackintosh (not recommended, legal issues)

**Option 2: Using Remote Mac**
- Connect to a remote Mac via SSH or screen sharing
- Use Xcode remotely

**Option 3: Use Cloud Mac Services**
- **MacStadium**: https://www.macstadium.com/
- **AWS EC2 Mac instances**: https://aws.amazon.com/ec2/instance-types/mac/
- **MacinCloud**: https://www.macincloud.com/

## ðŸ“¦ Setup Instructions

### 1. Install Dependencies

The project uses CocoaPods for dependency management. Install CocoaPods first:

\\\ash
# On macOS (or Mac VM)
sudo gem install cocoapods
\\\

### 2. Install Pods

\\\ash
cd PocketPilot-Fe
pod install
\\\

**Note:** If you see a Podfile in a directory, you may need to create a Podfile at the root level. Here's the content:

\\\uby
platform :ios, '17.0'

target 'pocketPilot' do
  use_frameworks!
  pod 'Alamofire', '~> 5.8'
  pod 'KeychainAccess', '~> 4.2'
end
\\\

### 3. Open the Project

\\\ash
# Open the workspace (not the project file)
open pocketPilot.xcworkspace
\\\

**Important:** Always open the .xcworkspace file, not the .xcodeproj file when using CocoaPods.

### 4. Configure API Endpoint

Update the API base URL in \pocketPilot/Core/Utilities/Constants.swift\:

\\\swift
struct Constants {
    struct API {
        static let baseURL = "https://your-api-url.com"  // Update this
        static let timeout: TimeInterval = 30.0
        static let webSocketURL = "wss://your-api-url.com/ws"
    }
}
\\\

### 5. Build and Run

1. Select a simulator or connected device in Xcode
2. Press \Cmd + R\ to build and run
3. Or use the Play button in Xcode

## ðŸ“š Dependencies

The project uses the following dependencies:

- **Alamofire** (~> 5.8): HTTP networking library
- **KeychainAccess** (~> 4.2): Secure keychain storage

## âœ¨ Project Features

### âœ… Completed Features

- âœ… **Authentication System**
  - Login with email/password
  - User registration (Sign Up)
  - Forgot password flow
  - Secure token management with automatic refresh
  - Keychain-based secure storage

- âœ… **Dashboard**
  - Total expenses overview
  - Monthly expense tracking
  - Category breakdown with visual indicators
  - Recent expenses list
  - Monthly comparison statistics

- âœ… **Expense Management**
  - Create, read, update, delete expenses
  - Category-based organization
  - Date range filtering
  - Search functionality
  - Expense detail view
  - Receipt image support (structure ready)

- âœ… **Profile Management**
  - User profile view
  - Edit profile information
  - Change password
  - Settings with currency selection
  - Logout functionality

- âœ… **Network Layer**
  - RESTful API client with Alamofire
  - Automatic token refresh on 401 errors
  - Request/response interceptors
  - Error handling and mapping
  - Network monitoring

- âœ… **Real-time Updates**
  - WebSocket integration
  - Real-time expense updates
  - Automatic UI refresh on changes

- âœ… **UI Components**
  - Reusable button components (Primary, Secondary)
  - Custom form fields
  - Loading and error views
  - Stat cards
  - Expense cards
  - Modern SwiftUI design

## ðŸ”Œ API Integration

The app expects a REST API with the following endpoints:

### Authentication
- \POST /auth/login\ - User login
- \POST /auth/signup\ - User registration
- \POST /auth/logout\ - User logout
- \POST /auth/refresh\ - Refresh access token
- \GET /auth/me\ - Get current user
- \PUT /auth/profile\ - Update profile
- \POST /auth/change-password\ - Change password
- \POST /auth/forgot-password\ - Request password reset
- \POST /auth/reset-password\ - Reset password with token

### Expenses
- \GET /expenses\ - List expenses (returns PaginatedResponse)
- \GET /expenses/:id\ - Get expense details
- \POST /expenses\ - Create expense
- \PUT /expenses/:id\ - Update expense
- \DELETE /expenses/:id\ - Delete expense

### Dashboard
- \GET /dashboard\ - Get dashboard statistics

### WebSocket
- \WS /ws\ - WebSocket connection for real-time updates

### API Response Format

The API should return responses in this format:

\\\json
{
  "success": true,
  "data": { ... },
  "message": "Optional message",
  "error": null
}
\\\

For paginated responses:

\\\json
{
  "data": [...],
  "pagination": {
    "current_page": 1,
    "total_pages": 10,
    "total_items": 100,
    "items_per_page": 10
  }
}
\\\

## ðŸ—ï¸ Architecture

### Design Patterns
- **MVVM Pattern**: ViewModels handle business logic
- **Observable Pattern**: Using Swift's \@Observable\ macro (iOS 17+)
- **Dependency Injection**: Singleton pattern for managers
- **Async/Await**: Modern Swift concurrency

### Code Organization
- **Features**: Organized by feature modules
- **Core**: Shared functionality (Network, Storage, etc.)
- **Components**: Reusable UI components
- **Separation of Concerns**: Clear boundaries between layers

## ðŸ› ï¸ Development Notes

### Code Style
- Follow Swift naming conventions
- Use SwiftUI best practices
- Maintain separation of concerns
- Use \@Observable\ for state management
- Prefer async/await over completion handlers

### Key Files
- \ContentView.swift\: Main app navigation and authentication flow
- \APIClient.swift\: Network layer implementation
- \AuthManager.swift\: Authentication state management
- \KeychainManager.swift\: Secure storage
- \Constants.swift\: App configuration

## ðŸ› Troubleshooting

### Build Errors
1. Clean build folder: \Cmd + Shift + K\
2. Delete derived data: \Cmd + Option + Shift + K\
3. Run \pod install\ again
4. Restart Xcode
5. Check that you opened \.xcworkspace\, not \.xcodeproj\

### Network Issues
- Check API base URL in \Constants.swift\
- Verify network permissions in \Info.plist\
- Check SSL certificate if using HTTPS
- Ensure backend API is running and accessible

### Keychain Issues
- Ensure proper keychain access permissions
- Check service identifier matches
- Verify KeychainAccess pod is installed

### CocoaPods Issues
- Run \pod deintegrate\ then \pod install\
- Clear CocoaPods cache: \pod cache clean --all\
- Update CocoaPods: \sudo gem update cocoapods\

## ðŸ“ Running on Windows

Since iOS development requires macOS and Xcode, here are your options:

### Option A: Use a Mac VM (VirtualBox/VMware)
1. Obtain macOS (requires Apple Developer account)
2. Install macOS in VM
3. Install Xcode from App Store
4. Follow setup instructions above

### Option B: Use Cloud Mac Services
- **MacStadium**: https://www.macstadium.com/
- **AWS EC2 Mac instances**: https://aws.amazon.com/ec2/instance-types/mac/
- **MacinCloud**: https://www.macincloud.com/

### Option C: Develop on a Physical Mac
- Use a MacBook, iMac, or Mac Mini
- This is the standard and recommended approach

## ðŸ”’ Security Features

- Secure token storage in Keychain
- Automatic token refresh
- HTTPS support
- Secure password handling
- Keychain-based user data storage

## ðŸ“± Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- CocoaPods

## ðŸ“„ License

[Your License Here]

## ðŸ¤ Support

For issues and questions, please open an issue on GitHub.

## ðŸŽ¯ Next Steps

1. Update \Constants.swift\ with your API endpoint
2. Install dependencies with \pod install\
3. Open \pocketPilot.xcworkspace\ in Xcode
4. Build and run on simulator or device
5. Test authentication flow
6. Configure backend API endpoints

---

**Note:** This is a complete frontend implementation. Make sure your backend API matches the expected endpoints and response formats described above.
