import Foundation
import SwiftUI

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    
    @Published var favoriteMovies: Set<Int> = []
    
    private let favoritesKey = "FavoriteMovies"
    
    private init() {
        loadFavorites()
    }
    
    func isFavorite(_ movieId: Int) -> Bool {
        return favoriteMovies.contains(movieId)
    }
    
    func toggleFavorite(_ movieId: Int) {
        if favoriteMovies.contains(movieId) {
            favoriteMovies.remove(movieId)
        } else {
            favoriteMovies.insert(movieId)
        }
        saveFavorites()
    }
    
    private func saveFavorites() {
        let favoriteArray = Array(favoriteMovies)
        UserDefaults.standard.set(favoriteArray, forKey: favoritesKey)
    }
    
    func loadFavorites() {
        if let favoriteArray = UserDefaults.standard.array(forKey: favoritesKey) as? [Int] {
            favoriteMovies = Set(favoriteArray)
        }
    }
}
