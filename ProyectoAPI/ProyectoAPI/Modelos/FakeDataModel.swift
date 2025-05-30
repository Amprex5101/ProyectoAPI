import Foundation

// Modelo para los ingredientes
struct Ingredient: Decodable {
    let _id: String
    let name: String
    let quantity: String
}

// Modelo completo para las recetas
struct FakeDataModel: Decodable {
    let _id: String
    let title: String
    let image: String
    let description: String
    let preparationTime: Int
    let ingredients: [Ingredient]
    let instructions: String
    let category: String
    let author: String
    let createdAt: String
    let updatedAt: String
    let recipeId: Int
    
    // Valores por defecto para campos opcionales
    enum CodingKeys: String, CodingKey {
        case _id, title, image, description, preparationTime, ingredients, instructions, category, author, createdAt, updatedAt, recipeId
    }
}

class ModeloDatos {
    
    var onFakeUpdate: (([FakeDataModel]) -> Void)?
    
    let fakeapi = "https://api-resetas.onrender.com/api/recipes"
    var fake: [FakeDataModel] = []
    
    func getFakeDatos() {
        let url = URL(string: fakeapi)
        
        print("encontrando informacion..")
        URLSession.shared.dataTask(with: url!) { data, response, error in
            
            if let error = error {
                print("error... \(error)")
                return
            }
            
            if let data = data,
               let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                do {
                    // Decodificamos directamente como un array de FakeDataModel
                    let productos = try JSONDecoder().decode([FakeDataModel].self, from: data)
                    print("DATOS encontrados: \(productos.count)")
                    self.fake = productos
                    self.onFakeUpdate?(self.fake)
                } catch {
                    print("Error de decodificación: \(error)")
                }
            } else {
                print("No se encontraron datos o hubo un problema con la respuesta")
            }
        }.resume()
    }
    
    func ejecutarAPI() {
        let urlsession = URLSession.shared
        let url = URL(string: fakeapi)
        
        urlsession.dataTask(with: url!) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data)
                    print("Respuesta JSON: \(json)")
                } catch {
                    print("Error al procesar JSON: \(error)")
                }
            }
        }.resume()
    }
}
