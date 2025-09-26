# Countries Explorer

A modern iOS application built with SwiftUI and VIPER architecture that allows users to explore countries around the world with location-based features and intuitive search functionality.

## Features

### Core Functionality
- **Location Detection**: Automatically detects and displays your current country using GPS
- **Country Search**: Real-time search with debouncing to find countries quickly
- **Country Management**: Add up to 5 countries to your selection list
- **Detailed Information**: View comprehensive country details including capital, currency, population, and more

### Technical Features
- **VIPER Architecture**: Clean separation of concerns with proper modularity
- **Modern iOS**: Built with SwiftUI and NavigationStack for native performance
- **Network Integration**: REST Countries API for comprehensive country data
- **Location Services**: Efficient GPS-based country detection with permission handling

## Architecture

The application follows the VIPER (View, Interactor, Presenter, Entity, Router) architectural pattern:

### Components
- **Models**: Country data structures with comprehensive API mapping
- **Services**: NetworkService for API calls and LocationService for GPS functionality
- **Modules**: Modular components for CountriesList and CountryDetail features
- **Views**: SwiftUI-based user interface with modern design patterns

### Key Services
- **NetworkService**: Handles REST Countries API integration with Combine framework
- **LocationService**: Manages GPS location detection and reverse geocoding
- **CountriesListInteractor**: Business logic for country selection and management
- **CountriesListPresenter**: Presentation logic with search debouncing and state management

## API Integration

The application integrates with the REST Countries API:
- **Search Endpoint**: `https://restcountries.com/v2/name/{query}`
- **Country Details**: Comprehensive data including capital, currency, population, languages
- **Flag Images**: High-quality flag representations for visual identification

## User Interface

### Main Screen
- Search bar with tap-to-activate functionality
- Location-detected country section (protected from removal)
- Selected countries section with management capabilities
- Smooth animations and transitions throughout

### Search Experience
- Full-screen overlay with blur background
- Real-time search with 1-second debouncing
- Visual feedback for country selection states
- Persistent search until manually closed

### Country Details
- Comprehensive information display
- Navigation integration with SwiftUI
- Professional layout with proper information hierarchy

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.0+

## Installation

1. Clone the repository
2. Open `countries-task-coorb.xcodeproj` in Xcode
3. Build and run the project on your device or simulator

## Usage

1. **Launch**: The app automatically requests location permission and detects your current country
2. **Search**: Tap the search bar to open the search interface
3. **Add Countries**: Search for countries and tap the plus button to add them
4. **View Details**: Tap any country card to view detailed information
5. **Manage Selection**: Remove countries using the remove button (except your location country)

## Location Permissions

The app requires location access to automatically detect your current country. If permission is denied, the app gracefully handles this state and provides instructions for enabling location access in Settings.

## Performance Optimizations

- **Efficient Location Detection**: Optimized accuracy settings for faster GPS response
- **Search Debouncing**: Prevents excessive API calls during typing
- **Smooth Animations**: Optimized animation timing for responsive feel
- **Memory Management**: Proper resource cleanup and state management

## Future Enhancements

Potential areas for expansion include:
- Offline mode with cached country data
