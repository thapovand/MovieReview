import SwiftUI

struct VideoThumbnailView: View {
    let video: Video
    
    var body: some View {
        Button(action: {
            openYouTubeVideo()
        }) {
            ZStack {
                AsyncImage(url: video.thumbnailURL) { image in
                    image
                        .resizable()
                        .aspectRatio(16/9, contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(16/9, contentMode: .fill)
                        .overlay(
                            Image(systemName: "video")
                                .foregroundColor(.gray)
                                .font(.largeTitle)
                        )
                }
                .clipped()
                .cornerRadius(12)
                
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.6))
                    .clipShape(Circle())
            }
        }
    }
    
    private func openYouTubeVideo() {
        let youtubeAppURL = "youtube://watch?v=\(video.key)"
        let youtubeWebURL = "https://www.youtube.com/watch?v=\(video.key)"
        
        if let appURL = URL(string: youtubeAppURL), UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let webURL = URL(string: youtubeWebURL) {
            UIApplication.shared.open(webURL)
        }
    }
}
