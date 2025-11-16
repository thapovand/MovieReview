import SwiftUI

struct MovieDetailView: View {
    let movieId: Int
    
    @StateObject private var movieService = MovieService.shared
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    @State private var movieDetails: MovieDetails?
    @State private var videos: [Video] = []
    @State private var cast: [Cast] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: []) {
                if isLoading {
                    ProgressView("Loading movie details...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
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
                            loadMovieDetails()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let movieDetails = movieDetails {
                    VStack(alignment: .leading, spacing: 0) {
                        // Backdrop and poster section
                        ZStack(alignment: .bottomLeading) {
                            AsyncImage(url: movieDetails.backdropURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                            }
                            .frame(height: 250)
                            .clipped()
                            
                            LinearGradient(
                                colors: [Color.clear, Color.black.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 250)
                            
                            HStack(alignment: .bottom, spacing: 16) {
                                AsyncImage(url: movieDetails.posterURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                }
                                .frame(width: 120, height: 180)
                                .clipped()
                                .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(movieDetails.title)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                        
                                        Text(String(format: "%.1f", movieDetails.voteAverage))
                                            .foregroundColor(.white)
                                        
                                        Text("• \(movieDetails.formattedRuntime)")
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                    
                                    Text(movieDetails.formattedReleaseDate)
                                        .foregroundColor(.white.opacity(0.8))
                                    
                                    Button(action: {
                                        favoritesManager.toggleFavorite(movieDetails.id)
                                    }) {
                                        HStack {
                                            Image(systemName: favoritesManager.isFavorite(movieDetails.id) ? "heart.fill" : "heart")
                                            Text(favoritesManager.isFavorite(movieDetails.id) ? "Favorited" : "Add to Favorites")
                                        }
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(Color.red.opacity(0.8))
                                        .cornerRadius(20)
                                    }
                                }
                                
                                Spacer()
                            }
                            .padding()
                        }
                        
                        // Content sections with proper spacing
                        VStack(alignment: .leading, spacing: 0) {
                            // Genres section
                            if !movieDetails.genres.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(movieDetails.genres, id: \.id) { genre in
                                                Text(genre.name)
                                                    .font(.caption)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color.blue.opacity(0.2))
                                                    .foregroundColor(.blue)
                                                    .cornerRadius(16)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                                .padding(.top, 20)
                            }
                            
                            // Overview section
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Overview")
                                    .font(.headline)
                                    .padding(.horizontal, 16)
                                
                                Text(movieDetails.overview)
                                    .font(.body)
                                    .foregroundColor(.secondary)
                                    .lineLimit(nil)
                                    .padding(.horizontal, 16)
                            }
                            .padding(.top, 20)
                            
                            // Trailers section
                            if !videos.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Trailers & Videos")
                                        .font(.headline)
                                        .padding(.horizontal, 16)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(videos.prefix(5)) { video in
                                                VStack(alignment: .leading) {
                                                    VideoThumbnailView(video: video)
                                                        .frame(width: 200)
                                                    
                                                    Text(video.name)
                                                        .font(.caption)
                                                        .lineLimit(2)
                                                        .frame(width: 200, alignment: .leading)
                                                }
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                .padding(.top, 20)
                            }
                            
                            // Cast section
                            if !cast.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Cast")
                                        .font(.headline)
                                        .padding(.horizontal, 16)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(alignment: .top, spacing: 12) {
                                            ForEach(cast.prefix(10)) { actor in
                                                VStack(alignment: .center, spacing: 8) {
                                                    AsyncImage(url: actor.profileURL) { image in
                                                        image
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fill)
                                                    } placeholder: {
                                                        Rectangle()
                                                            .fill(Color.gray.opacity(0.3))
                                                            .overlay(
                                                                Image(systemName: "person.fill")
                                                                    .foregroundColor(.gray)
                                                            )
                                                    }
                                                    .frame(width: 80, height: 120)
                                                    .clipped()
                                                    .cornerRadius(8)
                                                    
                                                    VStack(spacing: 4) {
                                                        Text(actor.name)
                                                            .font(.caption)
                                                            .fontWeight(.medium)
                                                            .lineLimit(2)
                                                            .multilineTextAlignment(.center)
                                                            .frame(width: 80, height: 32, alignment: .top)
                                                        
                                                        Text(actor.character)
                                                            .font(.caption2)
                                                            .foregroundColor(.secondary)
                                                            .lineLimit(2)
                                                            .multilineTextAlignment(.center)
                                                            .frame(width: 80, height: 24, alignment: .top)
                                                    }
                                                }
                                                .frame(width: 80)
                                            }
                                        }
                                        .padding(.horizontal, 16)
                                    }
                                }
                                .padding(.top, 20)
                            }
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .task {
                loadMovieDetails()
            }
        }
    }
    private func loadMovieDetails() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                async let detailsTask = movieService.fetchMovieDetails(movieId: movieId)
                async let videosTask = movieService.fetchMovieVideos(movieId: movieId)
                async let creditsTask = movieService.fetchMovieCredits(movieId: movieId)
                
                let (details, videosResponse, creditsResponse) = try await (detailsTask, videosTask, creditsTask)
                
                await MainActor.run {
                    self.movieDetails = details
                    self.videos = videosResponse.results.filter { $0.type == "Trailer" || $0.type == "Teaser" }
                    self.cast = creditsResponse.cast
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



