import SwiftUI

struct FavoritesView: View {
    @StateObject private var movieService = MovieService.shared
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var favoriteMovies: [Movie] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading favorites...")
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
                            loadFavorites()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if favoriteMovies.isEmpty {
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
                        
                        NavigationLink(destination: MoviesListView()) {
                            Text("Browse Movies")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.red)
                                .cornerRadius(25)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 20) {
                            ForEach(favoriteMovies) { movie in
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
            .navigationTitle("Favorites")
            .navigationBarTitleDisplayMode(.large)
            .task {
                loadFavorites()
            }
            .refreshable {
                loadFavorites()
            }
            .onReceive(favoritesManager.$favoriteMovies) { _ in
                loadFavorites()
            }
        }
    }
    
    private func loadFavorites() {
        let favoriteIds = Array(favoritesManager.favoriteMovies)
        
        guard !favoriteIds.isEmpty else {
            favoriteMovies = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                var movies: [Movie] = []
                
                // Fetch details for each favorite movie
                for movieId in favoriteIds {
                    let movieDetails = try await movieService.fetchMovieDetails(movieId: movieId)
                    
                    // Convert MovieDetails to Movie for display
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
                    movies.append(movie)
                }
                
                await MainActor.run {
                    self.favoriteMovies = movies.sorted { $0.title < $1.title }
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
}
