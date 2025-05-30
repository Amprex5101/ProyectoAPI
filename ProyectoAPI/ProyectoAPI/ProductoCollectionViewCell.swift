import UIKit

class ProductoCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ProductoCollectionCell"
    
    private let productoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let tituloLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 10
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.2
        contentView.layer.shadowOffset = CGSize(width: 0, height: 2)
        contentView.layer.shadowRadius = 4
        
        contentView.addSubview(productoImageView)
        contentView.addSubview(tituloLabel)
        
        NSLayoutConstraint.activate([
            productoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            productoImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            productoImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            productoImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.75),
            
            tituloLabel.topAnchor.constraint(equalTo: productoImageView.bottomAnchor, constant: 8),
            tituloLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            tituloLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            tituloLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with recipe: FakeDataModel) {
        tituloLabel.text = recipe.title
        
        if let url = recipe.fullImageURL(), !recipe.image.isEmpty {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.startAnimating()
            activityIndicator.center = productoImageView.center
            productoImageView.addSubview(activityIndicator)
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    activityIndicator.removeFromSuperview()
                    
                    if let error = error {
                        print("Error cargando imagen: \(error)")
                        self.productoImageView.image = UIImage(systemName: "photo")
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        self.productoImageView.image = image
                    } else {
                        self.productoImageView.image = UIImage(systemName: "photo")
                    }
                }
            }.resume()
        } else {
            // Si la URL está vacía, usa un símbolo del sistema
            productoImageView.image = UIImage(systemName: "photo.fill")
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        productoImageView.image = nil
        tituloLabel.text = nil
    }
}
