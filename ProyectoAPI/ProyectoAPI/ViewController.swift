import UIKit

class ViewController: UIViewController {

    // Array de productos en lugar de strings
    var productos: [FakeDataModel] = []
    let modelo = ModeloDatos()
    var datosRecibidos = false
    
    // Cambio de TableView por CollectionView
    private let collectionView: UICollectionView = {
        // Crear el layout para la cuadrícula 2x2
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ProductoCollectionViewCell.self, forCellWithReuseIdentifier: ProductoCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    private let loadButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Cargar Datos", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(loadButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Recetas"
        
        setupDataModel()
        
        // Primero agregamos ambas vistas a la jerarquía
        view.addSubview(collectionView)
        view.addSubview(loadButton)
        
        // Luego configuramos todas las restricciones
        configureUI()
        
        // Configuramos el collectionView como delegado y origen de datos
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Agregar botón para crear nueva receta
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewRecipe)
        )
    }
    
    private func setupDataModel() {
        modelo.onFakeUpdate = { [weak self] productos in
            self?.productos = productos
            
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                self?.datosRecibidos = true
            }
        }
    }
    
    // Método unificado para configurar la UI
    private func configureUI() {
        // Configurar restricciones para el botón
        NSLayoutConstraint.activate([
            loadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            loadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            loadButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            loadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Configurar restricciones para la colección
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: loadButton.topAnchor, constant: -16)
        ])
    }
    
    private func loadData() {
        modelo.getFakeDatos()
    }
    
    @objc private func loadButtonTapped() {
        loadData()
    }
    
    @objc private func addNewRecipe() {
        let editarVC = EditarRecetaViewController()
        
        // Crear una receta vacía como plantilla
        let emptyIngredient = Ingredient(_id: UUID().uuidString, name: "", quantity: "")
        let emptyRecipe = FakeDataModel(
            _id: UUID().uuidString,
            title: "",
            // En lugar de una URL externa, usa una cadena vacía o una imagen predeterminada del servidor
            image: "",
            description: "",
            preparationTime: 30,
            ingredients: [emptyIngredient],
            instructions: "",
            category: "Desayuno",
            author: "",
            createdAt: Date().description,
            updatedAt: Date().description,
            recipeId: -1  // ID temporal negativo para indicar que es nueva
        )
        
        editarVC.receta = emptyRecipe
        
        // Manejar la creación de la nueva receta
        editarVC.onRecipeUpdated = { [weak self] newRecipe in
            guard let self = self else { return }
            
            // Añadir la nueva receta a la lista y actualizar la colección
            self.productos.append(newRecipe)
            self.collectionView.reloadData()
        }
        
        navigationController?.pushViewController(editarVC, animated: true)
    }
    
    // Método para eliminar receta
    private func deleteRecipe(recipeId: Int, completion: @escaping (Bool) -> Void) {
        let baseURL = "https://api-resetas.onrender.com/api/recipes/\(recipeId)"
        guard let url = URL(string: baseURL) else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error de red: \(error)")
                completion(false)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                completion(httpResponse.statusCode == 200)
            } else {
                completion(false)
            }
        }.resume()
    }
}

// Extensión para el CollectionView
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return productos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductoCollectionViewCell.reuseIdentifier, for: indexPath) as! ProductoCollectionViewCell
        
        let producto = productos[indexPath.item]
        cell.configure(with: producto)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calcular el ancho para 2 celdas por fila con espacio entre ellas
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let spaceBetweenCells = flowLayout.minimumInteritemSpacing
        let sectionInsets = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        
        let width = (collectionView.frame.width - spaceBetweenCells - sectionInsets) / 2
        return CGSize(width: width, height: width * 1.3) // Ajusta el alto según necesites
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let receta = productos[indexPath.item]
        let detalleVC = DetalleViewController()
        detalleVC.receta = receta
        navigationController?.pushViewController(detalleVC, animated: true)
    }
    
    // Agregar menú contextual para cada celda (similar al swipe de TableView)
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
            
            // Acción de Editar
            let editAction = UIAction(title: "Editar", image: UIImage(systemName: "pencil")) { [weak self] action in
                guard let self = self else { return }
                
                let receta = self.productos[indexPath.item]
                let editarVC = EditarRecetaViewController()
                editarVC.receta = receta
                
                // Manejar la actualización
                editarVC.onRecipeUpdated = { [weak self] updatedRecipe in
                    guard let self = self else { return }
                    
                    // Actualizar la receta en el arreglo local
                    if let index = self.productos.firstIndex(where: { $0.recipeId == updatedRecipe.recipeId }) {
                        self.productos[index] = updatedRecipe
                        self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    }
                }
                
                self.navigationController?.pushViewController(editarVC, animated: true)
            }
            
            // Acción de Eliminar
            let deleteAction = UIAction(title: "Eliminar", image: UIImage(systemName: "trash"), attributes: .destructive) { [weak self] action in
                guard let self = self else { return }
                
                let recipeId = self.productos[indexPath.item].recipeId
                
                // Mostrar confirmación
                let alert = UIAlertController(title: "Eliminar Receta", message: "¿Estás seguro de que deseas eliminar esta receta?", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
                
                alert.addAction(UIAlertAction(title: "Eliminar", style: .destructive) { _ in
                    // Realizar solicitud DELETE a la API
                    self.deleteRecipe(recipeId: recipeId) { success in
                        if success {
                            DispatchQueue.main.async {
                                // Eliminar de la lista local y actualizar la colección
                                self.productos.remove(at: indexPath.item)
                                self.collectionView.deleteItems(at: [indexPath])
                            }
                        } else {
                            DispatchQueue.main.async {
                                let errorAlert = UIAlertController(title: "Error", message: "No se pudo eliminar la receta. Intenta de nuevo.", preferredStyle: .alert)
                                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                                self.present(errorAlert, animated: true)
                            }
                        }
                    }
                })
                
                self.present(alert, animated: true)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
}
