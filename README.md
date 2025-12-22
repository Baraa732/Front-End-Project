# Firstoo - Apartment Rental App

A Flutter-based apartment rental application that connects tenants and landlords.

## Features

- **Authentication System**: Login and registration for both tenants and landlords
- **Apartment Management**: Landlords can add, edit, and manage their properties
- **Booking System**: Tenants can browse and book apartments
- **Real-time Chat**: Communication between tenants and landlords
- **Profile Management**: User profile customization
- **Favorites**: Save preferred apartments
- **Notifications**: Stay updated with booking requests and messages
- **Theme Support**: Light and dark mode themes

## Architecture

This project follows Clean Architecture principles with:

- **Presentation Layer**: UI screens, widgets, and providers
- **Domain Layer**: Business logic and use cases
- **Data Layer**: Models, repositories, and data sources
- **Core Layer**: Shared utilities, services, and configurations

## Tech Stack

- **Flutter**: Cross-platform mobile development
- **Provider**: State management
- **HTTP**: API communication
- **Shared Preferences**: Local storage
- **Image Picker**: Photo selection
- **Connectivity Plus**: Network status monitoring

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Android/iOS device or emulator

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd firstoo
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── application/          # Application layer (BLoCs, events, states)
├── core/                # Core utilities and configurations
│   ├── constants/       # App constants and routes
│   ├── network/         # API services and network management
│   ├── services/        # Core services
│   ├── state/          # Global state management
│   ├── theme/          # App theming
│   └── utils/          # Utility functions
├── data/               # Data layer
│   ├── models/         # Data models
│   └── repositories/   # Data repositories
├── domain/             # Domain layer
│   ├── entities/       # Business entities
│   ├── repositories/   # Repository interfaces
│   └── usecases/       # Business use cases
└── presentation/       # Presentation layer
    ├── providers/      # State providers
    ├── screens/        # UI screens
    └── widgets/        # Reusable widgets
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.