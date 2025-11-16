import SwiftUI

struct MovieCardView: View {
    let movie: Movie
    @EnvironmentObject var favoritesManager: FavoritesManager
    @StateObject private var movieService = MovieService.shared
    @State private var runtime: Int?
    @State private var isLoadingRuntime = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Poster Image with fixed size
            ZStack(alignment: .topTrailing) {
                AsyncImage(url: movie.posterURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                        )
                }
                .frame(width: 160, height: 240)
                .clipped()
                .cornerRadius(12)
                
                Button(action: {
                    favoritesManager.toggleFavorite(movie.id)
                }) {
                    Image(systemName: favoritesManager.isFavorite(movie.id) ? "heart.fill" : "heart")
                        .foregroundColor(favoritesManager.isFavorite(movie.id) ? .red : .white)
                        .font(.title2)
                        .padding(8)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Circle())
                }
                .padding(8)
            }
            
            // Text content with fixed height to ensure alignment
            VStack(alignment: .leading, spacing: 4) {
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: 44, alignment: .top) // Fixed height for 2 lines
                
                HStack(alignment: .center) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                    
                    Text(movie.ratingText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if let movieRuntime = movie.runtime {
                        Text(formatRuntime(movieRuntime))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else if let fetchedRuntime = runtime {
                        Text(formatRuntime(fetchedRuntime))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    } else if isLoadingRuntime {
                        ProgressView()
                            .scaleEffect(0.5)
                            .frame(height: 10)
                    }
                    
                    Spacer()
                    
                    Text(String(movie.releaseDate.prefix(4)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                }
                .frame(height: 20) // Fixed height for bottom row
            }
            .frame(width: 160, height: 68, alignment: .top) // Fixed total text area height
        }
        .frame(width: 160, height: 316) // Fixed total card height (240 + 8 + 68)
        .onAppear {
            fetchRuntimeIfNeeded()
        }
    }
    
    private func fetchRuntimeIfNeeded() {
        guard movie.runtime == nil && runtime == nil && !isLoadingRuntime else { return }
        
        isLoadingRuntime = true
        
        Task {
            do {
                let movieDetails = try await movieService.fetchMovieDetails(movieId: movie.id)
                
                await MainActor.run {
                    self.runtime = movieDetails.runtime
                    self.isLoadingRuntime = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingRuntime = false
                }
            }
        }
    }
    
    private func formatRuntime(_ runtime: Int) -> String {
        let hours = runtime / 60
        let minutes = runtime % 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
}
