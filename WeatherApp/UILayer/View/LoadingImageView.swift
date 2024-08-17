import UIKit

class LoadingImageView: UIImageView {

    private static let imageCache = NSCache<NSString, UIImage>()
   
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
   
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        setupView()
    }
   
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
   
    private func setupView() {
        addSubview(loadingIndicator)
       
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
   
    func loadImage(from url: URL) {
        let cacheKey = NSString(string: url.absoluteString)
       
        // Check if the image is already cached
        if let cachedImage = LoadingImageView.imageCache.object(forKey: cacheKey) {
            self.image = cachedImage
            return
        }
       
        loadingIndicator.startAnimating()
        self.image = nil
       
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.loadingIndicator.stopAnimating()
               
                if let data = data, let image = UIImage(data: data) {
                    // Cache the image before setting it
                    LoadingImageView.imageCache.setObject(image, forKey: cacheKey)
                    self?.image = image
                }
            }
        }
       
        task.resume()
    }
}
