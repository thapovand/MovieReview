import Foundation

class MovieService: ObservableObject {
    static let shared = MovieService()
    
    private let baseURL = "https://api.themoviedb.org/3"
    private let apiKey = "YOUR_API_KEY_HERE" // Replace with your actual API key
    
    private init() {}
    
    enum APIError: Error, LocalizedError {
        case invalidURL
        case noData
        case decodingError
        case networkError(String)
        case invalidAPIKey
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Invalid URL"
            case .noData:
                return "No data received"
            case .decodingError:
                return "Failed to decode response"
            case .networkError(let message):
                return "Network error: \(message)"
            case .invalidAPIKey:
                return "Invalid API key. Please check your TMDb API key."
            }
        }
    }
    
    private func makeRequest<T: Codable>(endpoint: String, type: T.Type) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        var queryItems = components?.queryItems ?? []
        queryItems.append(URLQueryItem(name: "api_key", value: apiKey))
        components?.queryItems = queryItems
        
        guard let finalURL = components?.url else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: finalURL)
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 401 {
                    throw APIError.invalidAPIKey
                }
                if httpResponse.statusCode != 200 {
                    throw APIError.networkError("HTTP \(httpResponse.statusCode)")
                }
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch is DecodingError {
            throw APIError.decodingError
        } catch {
            throw APIError.networkError(error.localizedDescription)
        }
    }
    
    func fetchPopularMovies(page: Int = 1) async throws -> MoviesResponse {
        return try await makeRequest(endpoint: "/movie/popular?page=\(page)", type: MoviesResponse.self)
    }
    
    func searchMovies(query: String, page: Int = 1) async throws -> MoviesResponse {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return try await makeRequest(endpoint: "/search/movie?query=\(encodedQuery)&page=\(page)", type: MoviesResponse.self)
    }
    
    func fetchMovieDetails(movieId: Int) async throws -> MovieDetails {
        return try await makeRequest(endpoint: "/movie/\(movieId)", type: MovieDetails.self)
    }
    
    func fetchMovieVideos(movieId: Int) async throws -> VideosResponse {
        return try await makeRequest(endpoint: "/movie/\(movieId)/videos", type: VideosResponse.self)
    }
    
    func fetchMovieCredits(movieId: Int) async throws -> CreditsResponse {
        return try await makeRequest(endpoint: "/movie/\(movieId)/credits", type: CreditsResponse.self)
    }
    
    func fetchNowPlayingMovies(page: Int = 1) async throws -> MoviesResponse {
        return try await makeRequest(endpoint: "/movie/now_playing?page=\(page)", type: MoviesResponse.self)
    }
    
    func fetchTopRatedMovies(page: Int = 1) async throws -> MoviesResponse {
        return try await makeRequest(endpoint: "/movie/top_rated?page=\(page)", type: MoviesResponse.self)
    }
    
    func fetchUpcomingMovies(page: Int = 1) async throws -> MoviesResponse {
        return try await makeRequest(endpoint: "/movie/upcoming?page=\(page)", type: MoviesResponse.self)
    }
}
