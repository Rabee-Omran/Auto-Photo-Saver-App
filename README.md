# 📸 Auto Photo Saver App

A cross-platform Flutter application that automatically downloads and saves photos from a Django backend to your device's gallery. The app features background processing, network monitoring, and a clean, modern UI.

## 🌟 Features

### 📱 Mobile App (Flutter)
- **🔄 Automatic Photo Download**: Background service downloads new photos every 15 minutes
- **📶 Network Monitoring**: Only downloads on WiFi/Ethernet connections
- **🌍 Multi-language Support**: English, German, and Arabic localization
- **🌙 Dark/Light Theme**: Automatic theme switching with user preference
- **📱 Cross-platform**: Works on Android, iOS, Web, Windows, macOS, and Linux
- **⚡ Real-time Updates**: Manual refresh with network status indicator
- **💾 Local Storage**: Saves photos to device gallery or downloads folder
- **🔧 Settings Management**: User-configurable background fetch settings
- **📥 Background Fetch**: Continuously monitors for new images and downloads them automatically
- **🆔 Photo ID Tracking**: Uses unique photo IDs to ensure only new photos are downloaded to prevents downloading duplicate photos

### 🖥️ Backend API (Django)
- **📤 Photo Upload**: RESTful API for uploading photos
- **🖼️ Image Management**: Single photo storage with automatic replacement
- **📊 File Information**: Tracks file size, original filename, and upload timestamp
- **🔒 CORS Support**: Configured for cross-origin requests
- **📁 Media Serving**: Direct file access with proper headers

## 📸 Screenshots

The app runs seamlessly across all supported platforms with both light and dark themes:

### Light Theme
![Light Theme](screenshots/light.png)

### Dark Theme  
![Dark Theme](screenshots/dark.png)

*Screenshots show the app running on multiple platforms including macOS, Web, iPhone, and Android with a clean, modern interface that adapts to both light and dark themes.*

## 🏗️ Architecture

### Frontend Architecture (Clean Architecture)
```
frontend-flutter/
├── lib/
│   ├── core/                    # Core utilities and services
│   │   ├── constants/          # App constants
│   │   ├── error/             # Error handling
│   │   ├── extensions/        # Dart extensions
│   │   ├── localization/      # Internationalization
│   │   ├── network/           # Network utilities
│   │   ├── router/            # Navigation
│   │   ├── services/          # Background services
│   │   ├── theme/             # UI theming
│   │   ├── utils/             # Utility functions
│   │   └── widgets/           # Reusable widgets
│   ├── di/                    # Dependency injection
│   ├── features/              # Feature modules
│   │   ├── photo/            # Photo management feature
│   │   │   ├── data/         # Data layer
│   │   │   ├── domain/       # Business logic
│   │   │   └── presentation/ # UI layer
│   │   └── settings/         # Settings feature
│   ├── main.dart             # App entry point
│   └── app.dart              # App configuration
├── assets/                    # Images, fonts, and localization files
├── android/                   # Android-specific files
├── ios/                      # iOS-specific files
├── web/                      # Web-specific files
├── windows/                  # Windows-specific files
├── macos/                    # macOS-specific files
├── linux/                    # Linux-specific files
└── pubspec.yaml              # Dependencies and configuration
```

### Backend Architecture (Django REST)
```
backend-django/
├── backend/                  # Django project settings
│   ├── __init__.py
│   ├── settings.py          # Django settings
│   ├── urls.py              # Main URL configuration
│   ├── wsgi.py              # WSGI configuration
│   └── asgi.py              # ASGI configuration
├── photo/                   # Photo management app
│   ├── __init__.py
│   ├── models.py            # Database models
│   ├── views.py             # API views
│   ├── serializers.py       # Data serialization
│   ├── urls.py              # URL routing
│   ├── admin.py             # Admin interface
│   ├── apps.py              # App configuration
│   └── migrations/          # Database migrations
├── media/                   # Uploaded files
├── manage.py                # Django management script
├── requirements.txt         # Python dependencies
└── db.sqlite3              # SQLite database
```

## 🚀 Getting Started

### Prerequisites
- **Flutter SDK** (3.8.1 or higher)
- **Dart SDK** (3.8.1 or higher)
- **Python** (3.8 or higher)
- **Django** (5.2.3)
- **Android Studio** / **Xcode** (for mobile development)

### 📱 Frontend Setup (Flutter)

1. **Clone the repository**
   ```bash
   git clone https://github.com/Rabee-Omran/Auto-Photo-Saver-App
   cd final-project/frontend-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   # For development
   flutter run
   
   # For specific platform
   flutter run -d chrome    # Web
   flutter run -d android   # Android
   flutter run -d ios       # iOS
   ```

### 🖥️ Backend Setup (Django)

1. **Navigate to backend directory**
   ```bash
   cd backend-django
   ```

2. **Create virtual environment**
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Run migrations**
   ```bash
   python manage.py migrate
   ```

5. **Start the server**
   ```bash
   python manage.py runserver
   ```

## 📖 Usage

### 📱 Using the Mobile App

1. **Launch the app** - The app will automatically start monitoring for new photos
2. **Check network status** - Ensure you're connected to WiFi or Ethernet
3. **Manual refresh** - Tap the refresh button to download the latest photo
4. **View settings** - Access settings to configure background fetch preferences
5. **Change language** - Switch between English, German, and Arabic
6. **Toggle theme** - Switch between light and dark themes

### 🖥️ Using the Backend API

The backend is hosted on PythonAnywhere at: `https://autosaverapptask.pythonanywhere.com`

#### Upload a Photo
```bash
curl -X POST \
  https://autosaverapptask.pythonanywhere.com/api/photo/ \
  -H 'Content-Type: multipart/form-data' \
  -F 'image=@/path/to/your/photo.jpg'
```

#### Get Latest Photo
```bash
curl -X GET https://autosaverapptask.pythonanywhere.com/api/photo/
```

#### API Response Format
```json
{
  "id": 1,
  "image": "https://autosaverapptask.pythonanywhere.com/media/photos/photo.jpg",
  "original_file_name": "photo.jpg",
  "file_size": 1024000,
  "uploaded_at": "2024-01-15T10:30:00Z"
}
```

## 🔧 Configuration

### Frontend Configuration

#### Background Service Settings
- **Fetch Interval**: 15 minutes (configurable)
- **Network Requirements**: WiFi/Ethernet only
- **Battery Optimization**: Disabled for reliable background operation
- **API Base URL**: `https://autosaverapptask.pythonanywhere.com/api/`
- **Duplicate Prevention**: Uses photo ID comparison to avoid re-downloading
- **Background Monitoring**: Continuous checking for new photos every 15 minutes

#### Supported Platforms
- ✅ Android (API 21+)
- ✅ iOS (iOS 10+)
- ✅ Web (Chrome, Firefox, Safari)
- ✅ Windows (Windows 10+)
- ✅ macOS (macOS 10.14+)
- ✅ Linux (Ubuntu 18.04+)

### Backend Configuration

The backend is configured to run on PythonAnywhere with the following settings:
- **Base URL**: `https://autosaverapptask.pythonanywhere.com`
- **API Endpoint**: `/api/photo/`
- **Admin Panel**: `/admin/`
- **Media Files**: `/media/`
- **Single Photo Storage**: Automatically replaces old photos with new uploads
- **File Tracking**: Maintains original filename, file size, and upload timestamp

## 🛠️ Development

### Frontend Development

#### Project Structure
- **Clean Architecture**: Separation of concerns with data, domain, and presentation layers
- **BLoC Pattern**: State management using flutter_bloc
- **Dependency Injection**: GetIt for service locator pattern
- **Routing**: GoRouter for navigation

#### Key Dependencies
- `flutter_bloc`: State management
- `get_it`: Dependency injection
- `dio`: HTTP client
- `go_router`: Navigation
- `workmanager`: Background tasks
- `shared_preferences`: Local storage
- `cached_network_image`: Image caching
- `permission_handler`: Permission handling

### Backend Development

#### Project Structure
- **Django REST Framework**: API development
- **SQLite Database**: Default database
- **Media Files**: Local file storage

#### Key Dependencies
- `Django`: Web framework
- `djangorestframework`: API framework
- `django-cors-headers`: CORS support
- `Pillow`: Image processing

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Django team for the robust backend framework
- All contributors and maintainers

## 📞 Support

If you encounter any issues or have questions:
1. Check the [Issues](https://github.com/your-username/your-repo/issues) page
2. Create a new issue with detailed information
3. Contact the maintainers

---

**Made with ❤️ using Flutter & Django**