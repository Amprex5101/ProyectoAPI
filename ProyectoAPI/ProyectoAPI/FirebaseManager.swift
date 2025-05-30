import Foundation
import FirebaseCore
import FirebaseDatabase

class FirebaseManager {
    
    static let shared = FirebaseManager()
    private let database = Database.database().reference()
    
    // Cache para evitar consultas repetidas
    private var authorStatusCache: [String: Bool] = [:]
    
    private init() {}
    
    // Método para configurar Firebase
    func configure() {
        // Firebase ya debe estar configurado vía GoogleService-Info.plist
        // Este método se puede llamar en el AppDelegate
    }
    
    // Método para obtener el estado de un autor
    func getAuthorStatus(authorName: String, completion: @escaping (Bool) -> Void) {
        // Verificar si tenemos el estado en caché
        if let cachedStatus = authorStatusCache[authorName] {
            completion(cachedStatus)
            return
        }
        
        // Buscar en Firebase por nombre de autor
        database.child("Autores").queryOrdered(byChild: "NombreAutor")
            .queryEqual(toValue: authorName)
            .observeSingleEvent(of: .value) { [weak self] snapshot in
                var authorStatus = false
                
                // Recorrer resultados (puede haber múltiples autores con el mismo nombre)
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                       let value = snapshot.value as? [String: Any],
                       let status = value["Estado"] as? Bool {
                        authorStatus = status
                        break // Usar el primer autor encontrado
                    }
                }
                
                // Guardar en caché
                self?.authorStatusCache[authorName] = authorStatus
                
                // Devolver el resultado
                completion(authorStatus)
            }
    }
    
    // Método para observar cambios en el estado de un autor en tiempo real
    func observeAuthorStatus(authorName: String, completion: @escaping (Bool) -> Void) -> DatabaseHandle {
        let handle = database.child("Autores").queryOrdered(byChild: "NombreAutor")
            .queryEqual(toValue: authorName)
            .observe(.value) { [weak self] snapshot in
                var authorStatus = false
                
                for child in snapshot.children {
                    if let snapshot = child as? DataSnapshot,
                       let value = snapshot.value as? [String: Any],
                       let status = value["Estado"] as? Bool {
                        authorStatus = status
                        break
                    }
                }
                
                // Actualizar caché
                self?.authorStatusCache[authorName] = authorStatus
                
                // Notificar cambio
                completion(authorStatus)
            }
        
        return handle
    }
    
    // Remover un observador
    func removeObserver(handle: DatabaseHandle) {
        database.removeObserver(withHandle: handle)
    }
}
