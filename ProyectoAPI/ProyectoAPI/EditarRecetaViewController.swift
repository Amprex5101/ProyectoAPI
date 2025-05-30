import UIKit
import FirebaseDatabase
class EditarRecetaViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: - Propiedades
    var receta: FakeDataModel!
    var onRecipeUpdated: ((FakeDataModel) -> Void)?
    
    // Variable para almacenar la imagen seleccionada
    private var selectedImage: UIImage?
    private var isImageChanged = false
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let recipeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    private let changeImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cambiar Imagen", for: .normal)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.7)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(changeImageButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Título"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Título de la receta"
        return textField
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Categoría"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let categorySegmentedControl: UISegmentedControl = {
        let items = ["Desayuno", "Almuerzo", "Cena", "Postre", "Bebida", "Snack"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Tiempo de preparación (minutos)"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let timeTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Minutos"
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Autor"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let authorTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .roundedRect
        textField.placeholder = "Tu nombre"
        return textField
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Descripción"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        return textView
    }()
    
    private let ingredientsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ingredientes (separados por línea: 'nombre: cantidad')"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    private let ingredientsTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        return textView
    }()
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Instrucciones"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let instructionsTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        return textView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Guardar Cambios", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let authorStatusView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        return view
    }()
    
    private var authorObserverHandle: DatabaseHandle?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Editar Receta"
        
        setupUI()
        configureWithReceta()
        setupKeyboardDismissal()
        setupDelegates()
        
        // Agregar botón para cancelar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
    }
    
    deinit {
        if let handle = authorObserverHandle {
            FirebaseManager.shared.removeObserver(handle: handle)
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(recipeImageView)
        contentView.addSubview(changeImageButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(titleTextField)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(categorySegmentedControl)
        contentView.addSubview(timeLabel)
        contentView.addSubview(timeTextField)
        contentView.addSubview(authorLabel)
        contentView.addSubview(authorTextField)
        contentView.addSubview(authorStatusView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(ingredientsLabel)
        contentView.addSubview(ingredientsTextView)
        contentView.addSubview(instructionsLabel)
        contentView.addSubview(instructionsTextView)
        contentView.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Recipe Image
            recipeImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            recipeImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            recipeImageView.widthAnchor.constraint(equalToConstant: 250),
            recipeImageView.heightAnchor.constraint(equalToConstant: 180),
            
            // Change Image Button
            changeImageButton.topAnchor.constraint(equalTo: recipeImageView.bottomAnchor, constant: 8),
            changeImageButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            changeImageButton.widthAnchor.constraint(equalToConstant: 150),
            changeImageButton.heightAnchor.constraint(equalToConstant: 40),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: changeImageButton.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Title TextField
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            titleTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Category Label
            categoryLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categoryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Category Segmented Control
            categorySegmentedControl.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            categorySegmentedControl.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            categorySegmentedControl.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Time Label
            timeLabel.topAnchor.constraint(equalTo: categorySegmentedControl.bottomAnchor, constant: 16),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Time TextField
            timeTextField.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            timeTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            timeTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Author Label
            authorLabel.topAnchor.constraint(equalTo: timeTextField.bottomAnchor, constant: 16),
            authorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Author TextField
            authorTextField.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 8),
            authorTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            authorTextField.trailingAnchor.constraint(equalTo: authorStatusView.leadingAnchor, constant: -8),
            
            // Author Status View (círculo indicador)
            authorStatusView.centerYAnchor.constraint(equalTo: authorTextField.centerYAnchor),
            authorStatusView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            authorStatusView.widthAnchor.constraint(equalToConstant: 12),
            authorStatusView.heightAnchor.constraint(equalToConstant: 12),
            
            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: authorTextField.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Description TextView
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            // Ingredients Label
            ingredientsLabel.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16),
            ingredientsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ingredientsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Ingredients TextView
            ingredientsTextView.topAnchor.constraint(equalTo: ingredientsLabel.bottomAnchor, constant: 8),
            ingredientsTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            ingredientsTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            ingredientsTextView.heightAnchor.constraint(equalToConstant: 120),
            
            // Instructions Label
            instructionsLabel.topAnchor.constraint(equalTo: ingredientsTextView.bottomAnchor, constant: 16),
            instructionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            instructionsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Instructions TextView
            instructionsTextView.topAnchor.constraint(equalTo: instructionsLabel.bottomAnchor, constant: 8),
            instructionsTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            instructionsTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            instructionsTextView.heightAnchor.constraint(equalToConstant: 150),
            
            // Save Button
            saveButton.topAnchor.constraint(equalTo: instructionsTextView.bottomAnchor, constant: 24),
            saveButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            saveButton.widthAnchor.constraint(equalToConstant: 200),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func setupDelegates() {
        titleTextField.delegate = self
        timeTextField.delegate = self
        authorTextField.delegate = self
        descriptionTextView.delegate = self
        ingredientsTextView.delegate = self
        instructionsTextView.delegate = self
    }
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Data Configuration
    private func configureWithReceta() {
        guard let receta = receta else { return }
        
        titleTextField.text = receta.title
        
        // Configurar la categoría en el segmented control
        let categories = ["Desayuno", "Almuerzo", "Cena", "Postre", "Bebida", "Snack"]
        if let index = categories.firstIndex(of: receta.category) {
            categorySegmentedControl.selectedSegmentIndex = index
        }
        
        timeTextField.text = "\(receta.preparationTime)"
        authorTextField.text = receta.author
        descriptionTextView.text = receta.description
        
        // Formatear los ingredientes
        var ingredientsText = ""
        for ingredient in receta.ingredients {
            ingredientsText.append("\(ingredient.name): \(ingredient.quantity)\n")
        }
        ingredientsTextView.text = ingredientsText
        
        instructionsTextView.text = receta.instructions
        
        // Cargar imagen solo si hay una URL válida y no está vacía
        if let url = receta.fullImageURL(), !receta.image.isEmpty {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.startAnimating()
            activityIndicator.center = recipeImageView.center
            recipeImageView.addSubview(activityIndicator)
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    activityIndicator.removeFromSuperview()
                    
                    if let error = error {
                        print("Error cargando imagen: \(error)")
                        self.recipeImageView.image = UIImage(systemName: "photo.fill")
                        return
                    }
                    
                    if let data = data, let image = UIImage(data: data) {
                        self.recipeImageView.image = image
                    } else {
                        self.recipeImageView.image = UIImage(systemName: "photo.fill")
                    }
                }
            }.resume()
        } else {
            // Para una nueva receta, usa un símbolo del sistema como placeholder
            recipeImageView.image = UIImage(systemName: "photo.fill")
        }
        
        // Verificar inicialmente el estado del autor
        checkAuthorStatus()
    }
    
    // MARK: - Actions
    @objc private func changeImageButtonTapped() {
        let actionSheet = UIAlertController(title: "Cambiar Imagen", message: "Elige una opción", preferredStyle: .actionSheet)
        
        // Opción de cámara
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Tomar Foto", style: .default, handler: { _ in
                self.openImagePicker(sourceType: .camera)
            }))
        }
        
        // Opción de galería
        actionSheet.addAction(UIAlertAction(title: "Elegir de la Galería", style: .default, handler: { _ in
            self.openImagePicker(sourceType: .photoLibrary)
        }))
        
        // Opción de cancelar
        actionSheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        // Para iPad
        if let popoverController = actionSheet.popoverPresentationController {
            popoverController.sourceView = changeImageButton
            popoverController.sourceRect = changeImageButton.bounds
        }
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    private func openImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            recipeImageView.image = editedImage
            selectedImage = editedImage
            isImageChanged = true
        } else if let originalImage = info[.originalImage] as? UIImage {
            recipeImageView.image = originalImage
            selectedImage = originalImage
            isImageChanged = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped() {
        // Validar campos
        guard let title = titleTextField.text, !title.isEmpty,
              let timeText = timeTextField.text, let time = Int(timeText),
              let author = authorTextField.text, !author.isEmpty,
              let description = descriptionTextView.text, !description.isEmpty,
              let instructions = instructionsTextView.text, !instructions.isEmpty,
              let ingredientsText = ingredientsTextView.text, !ingredientsText.isEmpty else {
            showAlert(title: "Campos Incompletos", message: "Por favor completa todos los campos")
            return
        }
        
        // Mostrar indicador de carga
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        view.isUserInteractionEnabled = false
        
        // Procesar ingredientes
        let ingredients = processIngredients(ingredientsText)
        
        // Obtener categoría seleccionada
        let categories = ["Desayuno", "Almuerzo", "Cena", "Postre", "Bebida", "Snack"]
        let category = categories[categorySegmentedControl.selectedSegmentIndex]
        
        // Crear diccionario con los datos
        let recipeData: [String: Any] = [
            "title": title,
            "description": description,
            "preparationTime": time,
            "instructions": instructions,
            "category": category,
            "author": author,
            "ingredients": ingredients
        ]
        
        // Determinar si es una actualización o creación
        if receta.recipeId > 0 {
            // Es una actualización
            updateRecipe(recipeData: recipeData) { [weak self] success, updatedRecipe in
                self?.handleApiResponse(success: success, recipe: updatedRecipe, indicator: activityIndicator, isNew: false)
            }
        } else {
            // Es una creación
            createRecipe(recipeData: recipeData) { [weak self] success, newRecipe in
                self?.handleApiResponse(success: success, recipe: newRecipe, indicator: activityIndicator, isNew: true)
            }
        }
    }
    
    // Agregar este método para crear una nueva receta
    private func createRecipe(recipeData: [String: Any], completion: @escaping (Bool, FakeDataModel?) -> Void) {
        let baseURL = "https://api-resetas.onrender.com/api/recipes"
        guard let url = URL(string: baseURL) else {
            completion(false, nil)
            return
        }
        
        // Crear la solicitud
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Para multipart/form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Agregar recipeData como JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: recipeData, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"recipeData\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(jsonString)\r\n".data(using: .utf8)!)
            }
        } catch {
            print("Error al serializar JSON: \(error)")
            completion(false, nil)
            return
        }
        
        // Agregar imagen si hay una seleccionada
        if let image = selectedImage ?? recipeImageView.image, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Finalizar el cuerpo
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Asignar el cuerpo a la solicitud
        request.httpBody = body
        
        // Realizar la solicitud
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error de red: \(error)")
                completion(false, nil)
                return
            }
            
            guard let data = data else {
                print("No se recibieron datos")
                completion(false, nil)
                return
            }
            
            // Verificar respuesta HTTP
            if let httpResponse = response as? HTTPURLResponse {
                print("Código de respuesta HTTP: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 201 {
                    do {
                        let newRecipe = try JSONDecoder().decode(FakeDataModel.self, from: data)
                        completion(true, newRecipe)
                    } catch {
                        print("Error al decodificar respuesta: \(error)")
                        completion(false, nil)
                    }
                } else {
                    print("Error HTTP: \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Respuesta del servidor: \(responseString)")
                    }
                    completion(false, nil)
                }
            } else {
                completion(false, nil)
            }
        }.resume()
    }
    
    private func updateRecipe(recipeData: [String: Any], completion: @escaping (Bool, FakeDataModel?) -> Void) {
        guard let recipeId = receta?.recipeId else {
            completion(false, nil)
            return
        }
        
        let baseURL = "https://api-resetas.onrender.com/api/recipes/\(recipeId)"
        guard let url = URL(string: baseURL) else {
            completion(false, nil)
            return
        }
        
        // Crear una sesión URLSession con un tiempo de espera más largo
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60 // 60 segundos
        let session = URLSession(configuration: config)
        
        // Crear la solicitud
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        // Para multipart/form-data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Agregar recipeData como JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: recipeData, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"recipeData\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(jsonString)\r\n".data(using: .utf8)!)
            }
        } catch {
            print("Error al serializar JSON: \(error)")
            completion(false, nil)
            return
        }
        
        // Agregar imagen si cambió
        if isImageChanged, let image = selectedImage, let imageData = image.jpegData(compressionQuality: 0.8) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        // Finalizar el cuerpo
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Asignar el cuerpo a la solicitud
        request.httpBody = body
        
        // Realizar la solicitud
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error de red: \(error)")
                completion(false, nil)
                return
            }
            
            guard let data = data else {
                print("No se recibieron datos")
                completion(false, nil)
                return
            }
            
            // Verificar respuesta HTTP
            if let httpResponse = response as? HTTPURLResponse {
                print("Código de respuesta HTTP: \(httpResponse.statusCode)")
                if httpResponse.statusCode == 200 {
                    do {
                        let updatedRecipe = try JSONDecoder().decode(FakeDataModel.self, from: data)
                        completion(true, updatedRecipe)
                    } catch {
                        print("Error al decodificar respuesta: \(error)")
                        completion(false, nil)
                    }
                } else {
                    print("Error HTTP: \(httpResponse.statusCode)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Respuesta del servidor: \(responseString)")
                    }
                    completion(false, nil)
                }
            } else {
                completion(false, nil)
            }
        }
        
        task.resume()
    }
    
    private func processIngredients(_ text: String) -> [[String: String]] {
        var ingredients: [[String: String]] = []
        
        let lines = text.components(separatedBy: .newlines)
        for line in lines {
            if line.isEmpty { continue }
            
            let parts = line.split(separator: ":", maxSplits: 1, omittingEmptySubsequences: false)
            if parts.count >= 2 {
                let name = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let quantity = String(parts[1]).trimmingCharacters(in: .whitespaces)
                ingredients.append(["name": name, "quantity": quantity])
            } else if let name = parts.first {
                ingredients.append(["name": String(name), "quantity": ""])
            }
        }
        
        return ingredients
    }
    
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == authorTextField {
            checkAuthorStatus()
        }
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if textField == authorTextField {
            // Cuando cambia el texto, poner estado en gris (desconocido)
            authorStatusView.backgroundColor = .systemGray
        }
    }
    
    // Método para manejar la respuesta de la API
    private func handleApiResponse(success: Bool, recipe: FakeDataModel?, indicator: UIActivityIndicatorView, isNew: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            indicator.removeFromSuperview()
            self.view.isUserInteractionEnabled = true
            
            if success, let recipe = recipe {
                // Notificar al controlador anterior sobre la actualización
                self.onRecipeUpdated?(recipe)
                
                let message = isNew ? "Receta creada correctamente" : "Receta actualizada correctamente"
                self.showAlert(title: "Éxito", message: message) {
                    self.navigationController?.popViewController(animated: true)
                }
            } else {
                let message = isNew ? "No se pudo crear la receta" : "No se pudo actualizar la receta"
                self.showAlert(title: "Error", message: "\(message). Intenta de nuevo.")
            }
        }
    }
    
    // Añadir método para verificar el estado del autor
    private func checkAuthorStatus() {
        guard let authorName = authorTextField.text, !authorName.isEmpty else {
            // Si no hay autor, mostrar estado desconocido
            authorStatusView.backgroundColor = .systemGray
            return
        }
        
        // Remover observador anterior si existe
        if let handle = authorObserverHandle {
            FirebaseManager.shared.removeObserver(handle: handle)
        }
        
        // Observar el estado del autor en tiempo real
        authorObserverHandle = FirebaseManager.shared.observeAuthorStatus(authorName: authorName) { [weak self] isActive in
            DispatchQueue.main.async {
                self?.authorStatusView.backgroundColor = isActive ? .systemGreen : .systemRed
            }
        }
    }
}
