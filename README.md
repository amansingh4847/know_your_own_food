# 🍽️ Know Your Own Food (KYOF)

> **An intelligent mobile application that helps you understand the nutritional value of your food instantly!**


---

## 📱 About the App

**Know Your Own Food (KYOF)** is a cutting-edge Flutter mobile application that leverages artificial intelligence and machine learning to identify food items from images and provide detailed nutritional information. Whether you're health-conscious, following a diet, or simply curious about what you're eating, KYOF gives you instant insights into the nutritional content of your meals.

### 🎯 Purpose

The app aims to:
- ✅ Make nutrition tracking effortless and fun
- ✅ Help users make informed dietary choices
- ✅ Provide instant nutritional analysis
- ✅ Support healthy lifestyle management
- ✅ Educate users about food composition

---

## ✨ Key Features

| Feature | Description | Status |
|---------|-------------|--------|
| 🤖 **AI-Powered Food Detection** | Uses TensorFlow Lite models (+API supported features Imagga + Spoonaculars) to identify food items | ✅ Active |
| 📷 **Camera Integration** | Real-time food scanning via device camera | ✅ Active |
| 🖼️ **Gallery Upload** | Upload food images from your device gallery | ✅ Active |
| 📊 **Nutritional Analysis** | Detailed breakdown of calories, protein, fat, and carbs | ✅ Active |
| API Integration | Cloud-based food recognition API support | ✅ Active |
| 💚 **Lifestyle Tracking** | Track your daily food intake and habits | 🔄 In Development |
| 👤 **User Profiles** | Personalized dietary preferences (Coming Soon) | ⏳ Planned |
| 📈 **Health Statistics** | Weekly/monthly nutrition summaries | ⏳ Planned |

---

## 🍲 Food Recognition Capabilities

The app can identify the following food items:

- Aloo Gobhi (Cauliflower & Potatoes)
- Aloo Mattar (Peas & Potatoes)
- Biryani
- Chapati
- Banana (Currently not available)
- Chutney
- Dal (Lentils)
- Dosa
- Idli
- Eggs
- Orange
- And more! 🥗🍛🥘

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:
- **Flutter SDK**: ^3.8.1
- **Dart**: Included with Flutter
- **Android SDK** or **Xcode** (for iOS)
- **Git** for version control

### Installation Steps

#### 1️⃣ Clone the Repository
```bash
git clone https://github.com/yourusername/know_your_own_food.git
cd know_your_own_food
```

#### 2️⃣ Install Dependencies
```bash
flutter pub get
```

#### 3️⃣ Set Up API Keys
Create a file at `lib/secrets/api_keys.dart` with your API credentials:
```dart
const String API_KEY = 'your_api_key_here';
```

#### 4️⃣ Run the Application
```bash
# For Android
flutter run -d android

# For iOS
flutter run -d ios

```

---

## 🏗️ Project Structure

```
know_your_own_food/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── main_screen.dart          # Main navigation screen with bottom nav
│   ├── home_page.dart            # Home page with scan options
│   ├── scan_page.dart            # API-based food scanning
│   ├── model_scan_page.dart      # ML model-based scanning
│   ├── lifestyle_page.dart       # Lifestyle & tracking features
│   └── secrets/
│       └── api_keys.dart         # API credentials (⚠️ Keep private!)
├── assets/
│   ├── nutrition.json            # Food nutrition database
│   └── model/
│       ├── 01.tflite             # TensorFlow Lite model 1
│       └── best.tflite           # Best performing model
├── android/                      # Android-specific files
├── ios/                          # iOS-specific files
├── web/                          # Web deployment files
├── windows/                      # Windows desktop version
├── linux/                        # Linux desktop version
├── pubspec.yaml                  # Project dependencies
└── README.md                     # This file!
```

---

## 📦 Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| **flutter** | SDK | UI framework |
| **camera** | ^0.10.5+9 | Camera access & capture |
| **image_picker** | ^1.2.1 | Gallery image selection |
| **tflite_flutter** | ^0.12.1 | ML model inference |
| **http** | ^0.13.6 | API requests |
| **image** | ^4.8.0 | Image processing |
| **cupertino_icons** | ^1.0.8 | iOS-style icons |

---

## 🎮 How to Use

### Option 1: API-Based Food Scanning
1. Open the app
2. Tap **"Scan food using API"**
3. Capture or select a food image
4. View detailed nutritional information returned by the API

### Option 2: ML Model-Based Scanning
1. Open the app
2. Tap **"Scan food using model"**
3. Capture or select a food image
4. The on-device ML model identifies the food and displays results instantly

### Lifestyle Tracking (Beta)
1. Navigate to the **"Lifestyle"** tab
2. All features under development for future releases

---

## 🔧 Technical Stack

| Component | Technology |
|-----------|-----------|
| **Framework** | Flutter (Dart) |
| **ML/AI** | TensorFlow Lite |
| **Image Processing** | Dart Image Package |
| **API Communication** | HTTP Client |
| **Camera** | Camera Plugin |
| **Platform** | Cross-platform (Android, iOS, Web, Linux, Windows) |
| **UI Design** | Material Design 3 |

---

## 🌟 Features in Detail

### 🤖 Dual Scanning Methods

**API-Based Scanning:**
- ☁️ Processes images through cloud servers
- 📡 Highly accurate food recognition
- 🔄 Real-time API integration
- ⚡ Best for unknown or complex dishes

**ML Model-Based Scanning:**
- 🖥️ On-device processing (no internet required)
- ⚡ Instant results with zero latency
- 🔒 Privacy-friendly approach
- 📱 Works offline

### 📊 Nutritional Information

Get comprehensive details for each scanned food:
- 🔥 **Calories** - Total energy content
- 🥚 **Protein** - Muscle-building nutrients
- 🧈 **Fat** - Energy and absorption
- 🌾 **Carbohydrates** - Primary energy source

---

## 🎨 UI/UX Design

The app features a clean, intuitive interface with:
- 🎯 Simple navigation with bottom navigation bar
- 🌙 Dark theme for comfortable viewing
- 📱 Responsive design for all screen sizes
- ⚡ Fast and smooth transitions
- 🎪 User-friendly buttons and controls

---

## 🐛 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| 📷 Camera not working | Check app permissions in device settings |
| ❌ Model not loading | Ensure `.tflite` files exist in `assets/model/` |
| 🌐 API errors | Verify API key in `api_keys.dart` |
| 📸 Image picking fails | Confirm storage permissions are granted |
| 🔴 App crashes on startup | Run `flutter clean && flutter pub get` |

---

## 🔐 Privacy & Security

- 🔒 API keys are stored securely (never commit to git!)
- 📱 ML mode processes images locally - no data sent
- 👤 No personal data collection (currently)
- ✅ All permissions requested at runtime

### Important Security Notes
⚠️ **Never commit `lib/secrets/api_keys.dart` to version control!**

Add to `.gitignore`:
```
lib/secrets/api_keys.dart
```

---

## 🚀 Future Roadmap

- [ ] 🔐 User authentication and profiles
- [ ] 📊 Advanced nutrition tracking dashboard
- [ ] 📈 Daily/weekly health statistics
- [ ] 🎯 Personalized diet recommendations
- [ ] 🗣️ Multi-language support
- [ ] 🌐 Offline mode enhancements
- [ ] 🤝 Social sharing features
- [ ] 📧 Email reports and insights

---

## 📱 Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| 🤖 Android | ✅ Fully Supported | API 21+ recommended |
| 🍎 iOS | ✅ Fully Supported | iOS 11+ required |
---


## 👨‍💻 Contributing

We welcome contributions! Here's how:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📞 Support & Contact

- 📧 Email: amansingh484748@gmail.com

---


**Made with ❤️ for food lovers and health enthusiasts!**

*Last Updated: April 2026*
