# MovieApp - TMDb iOS Application

A modern iOS application built with SwiftUI that integrates with The Movie Database (TMDb) API to provide users with a comprehensive movie browsing experience.

## Features

### Implemented Features

- **Movies List Page (Home)**
  - Display popular movies with poster, title, rating, and release year
  - Category selection: Popular, Favourites, Top Rated, Upcoming
  - Grid layout with smooth scrolling
  - Pull-to-refresh functionality
  - Favorite indicator on movie cards

- **Movie Detail Page**
  - Comprehensive movie information including plot, genres, cast, duration, and rating
  - Backdrop and poster images
  - Embedded YouTube trailer player
  - Cast members with profile images
  - Add/remove favorites functionality

- **Search Functionality**
  - Real-time movie search by title
  - Grid layout for search results
  - Error handling for failed searches
  - Empty state for no results

- **Favorites System**
  - Mark/unmark movies as favorites from both list and detail pages
  - Persistent storage using UserDefaults
  - Visual indicators for favorited movies
  - Favorites restored on app relaunch

## Setup Instructions

### Prerequisites

- Xcode 26.0 or later
- iOS 17.0 or later
- TMDb API key (free registration required)

### Getting Your TMDb API Key

1. Visit [The Movie Database (TMDb)](https://www.themoviedb.org/)
2. Create a free account
3. Go to Settings > API
4. Request an API key (choose "Developer" option)
5. Fill out the required information
6. Copy your API key

### Installation & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd TMDB
   ```

2. **Open the project**

3. **Configure API Key**
   - Open `MovieApp/Services/MovieService.swift`
   - Replace `YOUR_API_KEY_HERE` with your actual TMDb API key:
   ```swift
   private let apiKey = "your_actual_api_key_here"
   ```


## Project Structure

## Architecture & Design Decisions

### MVVM Pattern
- **Models**: Data structures for API responses and business logic
- **Views**: SwiftUI views for UI presentation
- **ViewModels**: ObservableObject classes for state management

### Networking Layer
- Centralized `MovieService` class using async/await
- Proper error handling with custom error types
- URL construction with query parameters
- Image loading with AsyncImage

### State Management
- `@StateObject` and `@ObservableObject` for reactive UI updates
- `@EnvironmentObject` for shared state (FavoritesManager)
- UserDefaults for persistent favorites storage

### UI/UX Design
- Modern iOS design with native SwiftUI components
- Responsive grid layouts
- Smooth animations and transitions
- Error states and loading indicators
- Pull-to-refresh functionality

## API Endpoints Used

- **Popular Movies**: `/movie/popular`
- **Now Playing**: `/movie/now_playing`
- **Top Rated**: `/movie/top_rated`
- **Upcoming**: `/movie/upcoming`
- **Movie Details**: `/movie/{movie_id}`
- **Movie Videos**: `/movie/{movie_id}/videos`
- **Movie Credits**: `/movie/{movie_id}/credits`
- **Search Movies**: `/search/movie`

## Dependencies

### Native iOS Frameworks
- **SwiftUI**: Modern declarative UI framework
- **Foundation**: Core functionality and networking
- **WebKit**: YouTube video player integration

### External Dependencies
- None (uses only native iOS frameworks)

## Known Limitations

1. **API Key Security**: API key is stored in source code (should use secure storage in production)
2. **Offline Support**: No offline caching implemented
3. **Pagination**: Limited to first page of results for simplicity
4. **Video Player**: Basic YouTube embed (could be enhanced with native player)
5. **Error Recovery**: Basic error handling (could be more sophisticated)
6. **Accessibility**: Limited accessibility features implemented
7. **Testing**: No unit tests or UI tests included

## Troubleshooting

### Common Issues

1. **"Invalid API Key" Error**
   - Verify your API key is correctly set in `MovieService.swift`
   - Ensure your TMDb account is activated

2. **Network Errors**
   - Check internet connection
   - Verify TMDb API is accessible

3. **Build Errors**
   - Ensure Xcode 26.0+ is being used
   - Clean build folder (`Cmd + Shift + K`)

4. **Videos Not Playing**
   - Ensure device has internet connection
   - Some trailers may not be available

## License

This project is for educational purposes. TMDb API terms of service apply for API usage.

## Acknowledgments

- [The Movie Database (TMDb)](https://www.themoviedb.org/) for providing the comprehensive movie API
- Apple for SwiftUI framework and development tools
