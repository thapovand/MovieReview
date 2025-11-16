import SwiftUI

struct MoviesListView: View {
    @StateObject private var movieService = MovieService.shared
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var movies: [Movie] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedCategory = 0
    
    private let categories = ["Popular", "Favorites", "Top Rated", "Upcoming"]
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading && movies.isEmpty {
                    ProgressView("Loading movies...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        
                        Text("Error")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Retry") {
                            loadMovies()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 0) {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(0..<categories.count, id: \.self) { index in
                                Text(categories[index]).tag(index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                        .onChange(of: selectedCategory) { _, _ in
                            loadMovies()
                        }
                        
                        if movies.isEmpty && selectedCategory == 1 { // Favorites category
                            VStack(spacing: 16) {
                                Image(systemName: "heart")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                
                                Text("No Favorites Yet")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("Movies you favorite will appear here")
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Text("Tap the heart icon on any movie to add it to your favorites")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            ScrollView {
                                LazyVGrid(columns: [
                                    GridItem(.flexible(), spacing: 16),
                                    GridItem(.flexible(), spacing: 16)
                                ], spacing: 20) {
                                    ForEach(movies) { movie in
                                        NavigationLink(destination: MovieDetailView(movieId: movie.id)) {
                                            MovieCardView(movie: movie)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Movies")
            .navigationBarTitleDisplayMode(.large)
            .task {
                if movies.isEmpty {
                    loadMovies()
                }
            }
            .refreshable {
                loadMovies()
            }
            .onReceive(favoritesManager.$favoriteMovies) { _ in
                if selectedCategory == 1 { // Favorites category
                    loadMovies()
                }
            }
        }
    }
    
    private func loadMovies() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                switch selectedCategory {
                case 0: // Popular
                    let response = try await movieService.fetchPopularMovies()
                    await MainActor.run {
                        self.movies = response.results
                        self.isLoading = false
                    }
                case 1: // Favorites
                    await loadFavoriteMovies()
                case 2: // Top Rated
                    let response = try await movieService.fetchTopRatedMovies()
                    await MainActor.run {
                        self.movies = response.results
                        self.isLoading = false
                    }
                case 3: // Upcoming
                    let response = try await movieService.fetchUpcomingMovies()
                    await MainActor.run {
                        self.movies = response.results
                        self.isLoading = false
                    }
                default:
                    let response = try await movieService.fetchPopularMovies()
                    await MainActor.run {
                        self.movies = response.results
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    private func loadFavoriteMovies() async {
        let favoriteIds = Array(favoritesManager.favoriteMovies)
        
        guard !favoriteIds.isEmpty else {
            await MainActor.run {
                self.movies = []
                self.isLoading = false
            }
            return
        }
        
        do {
            var favoriteMovies: [Movie] = []
            
            // Fetch details for each favorite movie
            for movieId in favoriteIds {
                let movieDetails = try await movieService.fetchMovieDetails(movieId: movieId)
                
                let movie = Movie(
                    id: movieDetails.id,
                    title: movieDetails.title,
                    overview: movieDetails.overview,
                    posterPath: movieDetails.posterPath,
                    backdropPath: movieDetails.backdropPath,
                    releaseDate: movieDetails.releaseDate,
                    voteAverage: movieDetails.voteAverage,
                    voteCount: movieDetails.voteCount,
                    adult: false,
                    originalLanguage: "en",
                    originalTitle: movieDetails.title,
                    popularity: 0.0,
                    video: false,
                    genreIds: movieDetails.genres.map { $0.id },
                    runtime: movieDetails.runtime
                )
                favoriteMovies.append(movie)
            }
            
            await MainActor.run {
                self.movies = favoriteMovies.sorted { $0.title < $1.title }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}
