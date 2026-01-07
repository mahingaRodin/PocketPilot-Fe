# PocketPilot Setup Guide for Windows Users

## Quick Start Guide

Since you're on Windows, here's a step-by-step guide to get your iOS app running:

## Step 1: Get Access to macOS

You **must** have access to macOS to build iOS apps. Choose one:

### Option A: Cloud Mac Service (Easiest)
1. Sign up for a cloud Mac service:
   - **MacStadium**: https://www.macstadium.com/ (starts at ~$99/month)
   - **MacinCloud**: https://www.macincloud.com/ (starts at ~$30/month)
   - **AWS EC2 Mac**: https://aws.amazon.com/ec2/instance-types/mac/ (pay per hour)

2. Once you have access, connect via Remote Desktop or SSH

### Option B: Virtual Machine
1. Set up a macOS VM using VirtualBox or VMware
2. **Note**: You need a valid macOS license (comes with Mac hardware)
3. Install Xcode from the App Store

### Option C: Physical Mac
- Use a MacBook, iMac, or Mac Mini
- This is the standard approach

## Step 2: Install Xcode

1. Open the App Store on macOS
2. Search for "Xcode"
3. Install Xcode (it's large, ~15GB, so be patient)
4. Open Xcode and accept the license agreement
5. Install additional components when prompted

## Step 3: Install CocoaPods

Open Terminal on macOS and run:

```bash
sudo gem install cocoapods
```

Enter your password when prompted.

## Step 4: Install Project Dependencies

1. Navigate to your project directory:
```bash
cd /path/to/PocketPilot-Fe
```

2. Create a Podfile at the root if it doesn't exist:
```bash
cat > Podfile << 'EOF'
platform :ios, '17.0'

target 'pocketPilot' do
  use_frameworks!
  pod 'Alamofire', '~> 5.8'
  pod 'KeychainAccess', '~> 4.2'
end
EOF
```

3. Install pods:
```bash
pod install
```

## Step 5: Configure API Endpoint

1. Open `pocketPilot/Core/Utilities/Constants.swift`
2. Update the base URL:
```swift
static let baseURL = "https://your-backend-api.com"
static let webSocketURL = "wss://your-backend-api.com/ws"
```

## Step 6: Open Project in Xcode

**IMPORTANT**: Always open the workspace, not the project file!

```bash
open pocketPilot.xcworkspace
```

Or in Finder, double-click `pocketPilot.xcworkspace`

## Step 7: Build and Run

1. In Xcode, select a simulator (e.g., iPhone 15 Pro)
2. Press `Cmd + R` or click the Play button
3. Wait for the build to complete
4. The app will launch in the simulator

## Troubleshooting

### "No such module 'Alamofire'"
- Make sure you opened `.xcworkspace`, not `.xcodeproj`
- Run `pod install` again
- Clean build folder: `Cmd + Shift + K`

### Build Errors
1. Clean build: `Cmd + Shift + K`
2. Delete derived data: `Cmd + Option + Shift + K`
3. Restart Xcode
4. Run `pod install` again

### Pod Install Fails
```bash
pod deintegrate
pod install
```

## Next Steps

1. ✅ Project is set up
2. ✅ Dependencies installed
3. ✅ API endpoint configured
4. 🔄 Connect to your backend API
5. 🔄 Test authentication flow
6. 🔄 Test expense creation and listing

## Project Structure Overview

- **App/**: Main app entry point
- **Core/**: Shared functionality (Network, Storage, Auth)
- **Features/**: Feature modules (Dashboard, Expenses, Profile)
- **Components/**: Reusable UI components

## Key Files to Know

- `ContentView.swift`: Main navigation
- `Constants.swift`: API configuration
- `APIClient.swift`: Network layer
- `AuthManager.swift`: Authentication logic

## Need Help?

- Check the main README.md for detailed documentation
- Review code comments in the project
- Ensure your backend API matches the expected endpoints

---

**Remember**: iOS development requires macOS. You cannot build iOS apps on Windows directly. Use one of the options above to get macOS access.
