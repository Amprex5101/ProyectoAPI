import UIKit
import FirebaseDatabase

class DetalleViewController: UIViewController {
    
    // MARK: - Propiedades
    var receta: FakeDataModel!
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 0
        return label
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .systemGray
        return label
    }()
    
    private let authorStatusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()
    
    private let authorStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.text = "Estado: Desconocido"
        return label
    }()
    
    private let preparationTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        return label
    }()
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.text = "Descripción"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private let ingredientsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.text = "Ingredientes"
        return label
    }()
    
    private let ingredientsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.distribution = .fill
        return stackView
    }()
    
    private let instructionsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.text = "Instrucciones"
        return label
    }()
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    private var authorObserverHandle: DatabaseHandle?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Detalle de Receta"
        
        setupUI()
        configureWithReceta()
        
        // Agregar botón para editar en la barra de navegación
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .edit,
            target: self,
            action: #selector(editButtonTapped)
        )
    }
    
    deinit {
        if let handle = authorObserverHandle {
            FirebaseManager.shared.removeObserver(handle: handle)
        }
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        
        containerView.addSubview(headerImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(authorLabel)
        containerView.addSubview(authorStatusView)    // Agregado
        containerView.addSubview(authorStatusLabel)   // Agregado
        containerView.addSubview(preparationTimeLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(descriptionTitleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(ingredientsTitleLabel)
        containerView.addSubview(ingredientsStackView)
        containerView.addSubview(instructionsTitleLabel)
        containerView.addSubview(instructionsLabel)
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Container View
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header Image
            headerImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            headerImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            headerImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: 250),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: headerImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Author
            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            authorLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: authorStatusView.leadingAnchor, constant: -8),
            
            // Author Status View (círculo indicador)
            authorStatusView.centerYAnchor.constraint(equalTo: authorLabel.centerYAnchor),
            authorStatusView.widthAnchor.constraint(equalToConstant: 12),
            authorStatusView.heightAnchor.constraint(equalToConstant: 12),
            authorStatusView.trailingAnchor.constraint(equalTo: authorStatusLabel.leadingAnchor, constant: -4),
            
            // Author Status Label
            authorStatusLabel.centerYAnchor.constraint(equalTo: authorLabel.centerYAnchor),
            authorStatusLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Preparation Time
            preparationTimeLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            preparationTimeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            // Category
            categoryLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            categoryLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Description Title
            descriptionTitleLabel.topAnchor.constraint(equalTo: preparationTimeLabel.bottomAnchor, constant: 24),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Description
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Ingredients Title
            ingredientsTitleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            ingredientsTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            ingredientsTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Ingredients Stack
            ingredientsStackView.topAnchor.constraint(equalTo: ingredientsTitleLabel.bottomAnchor, constant: 8),
            ingredientsStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            ingredientsStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Instructions Title
            instructionsTitleLabel.topAnchor.constraint(equalTo: ingredientsStackView.bottomAnchor, constant: 24),
            instructionsTitleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            instructionsTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Instructions
            instructionsLabel.topAnchor.constraint(equalTo: instructionsTitleLabel.bottomAnchor, constant: 8),
            instructionsLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            instructionsLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            instructionsLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24)
        ])
    }
    
    // MARK: - Configure with Data
    func configureWithReceta() {
        guard let receta = receta else { return }
        
        titleLabel.text = receta.title
        authorLabel.text = "Por: \(receta.author)"
        preparationTimeLabel.text = "Tiempo: \(receta.preparationTime) minutos"
        categoryLabel.text = "Categoría: \(receta.category)"
        descriptionLabel.text = receta.description
        instructionsLabel.text = receta.instructions
        
        // Inicialmente mostrar estado desconocido
        updateAuthorStatus(isActive: false, isLoading: true)
        
        // Observar el estado del autor en tiempo real
        authorObserverHandle = FirebaseManager.shared.observeAuthorStatus(authorName: receta.author) { [weak self] isActive in
            DispatchQueue.main.async {
                self?.updateAuthorStatus(isActive: isActive, isLoading: false)
            }
        }
        
        // Agregar ingredientes al stack view
        for ingredient in receta.ingredients {
            let ingredientLabel = UILabel()
            ingredientLabel.font = UIFont.systemFont(ofSize: 16)
            ingredientLabel.text = "• \(ingredient.name): \(ingredient.quantity)"
            ingredientLabel.numberOfLines = 0
            ingredientsStackView.addArrangedSubview(ingredientLabel)
        }
        
        // Cargar imagen usando fullImageURL
        if let url = receta.fullImageURL() {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.startAnimating()
            activityIndicator.center = headerImageView.center
            headerImageView.addSubview(activityIndicator)
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    activityIndicator.removeFromSuperview()
                    
                    if let error = error {
                        print("Error cargando imagen: \(error)")
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        self.headerImageView.image = image
                    }
                }
            }.resume()
        }
    }
    
    // Método para actualizar la interfaz según el estado del autor
    private func updateAuthorStatus(isActive: Bool, isLoading: Bool) {
        if isLoading {
            authorStatusView.backgroundColor = .systemGray
            authorStatusLabel.text = "Estado: Cargando..."
        } else if isActive {
            authorStatusView.backgroundColor = .systemGreen
            authorStatusLabel.text = "Estado: Activo"
        } else {
            authorStatusView.backgroundColor = .systemRed
            authorStatusLabel.text = "Estado: Inactivo"
        }
    }
    
    // MARK: - Actions
    @objc private func editButtonTapped() {
        let editarVC = EditarRecetaViewController()
        editarVC.receta = self.receta
        
        // Manejar la actualización de la receta
        editarVC.onRecipeUpdated = { [weak self] updatedRecipe in
            guard let self = self else { return }
            self.receta = updatedRecipe
            
            // Limpiar el stack view de ingredientes antes de actualizarlo
            for subview in self.ingredientsStackView.arrangedSubviews {
                self.ingredientsStackView.removeArrangedSubview(subview)
                subview.removeFromSuperview()
            }
            
            // Actualizar la vista con los datos actualizados
            self.configureWithReceta()
        }
        
        navigationController?.pushViewController(editarVC, animated: true)
    }
}
