import 'package:flutter/material.dart';
import 'package:frontend/models/user.dart';
import 'package:frontend/services/super_admin_service.dart';

/// [SuperAdminProvider]
///
/// Este provider gestiona las operaciones que solo un SUPER_ADMIN puede realizar,
/// como obtener la lista de todos los usuarios, crear nuevos usuarios, bloquearlos
/// o eliminarlos.
///
/// Funciona como un intermediario entre la UI (específicamente la `SuperAdminPage`)
/// y el `SuperAdminService`, que es el que realiza las llamadas a la API.
///
/// Utiliza `ChangeNotifier` para notificar a los widgets cuando hay cambios,
/// como la actualización de la lista de usuarios, el inicio/fin de una carga
/// o la aparición de un error.
class SuperAdminProvider with ChangeNotifier {
  // Instancia del servicio que se comunica con el backend.
  final SuperAdminService _superAdminService = SuperAdminService();

  // --- ESTADO INTERNO DEL PROVIDER ---

  // Lista privada de todos los usuarios de la aplicación.
  List<AppUser> _users = [];
  // Getter público para acceder a la lista de usuarios desde la UI.
  List<AppUser> get users => _users;

  // Flag para controlar el estado de carga (ej: mientras se obtiene la lista de usuarios).
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Almacena un mensaje de error si alguna operación falla.
  String? _error;
  String? get error => _error;

  // --- MÉTODOS PÚBLICOS ---

  /// [getUsers]
  ///
  /// Obtiene la lista completa de usuarios del backend y la almacena en el estado.
  Future<void> getUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Notifica a la UI que la carga ha comenzado.

    try {
      // Llama al servicio para obtener los usuarios.
      _users = await _superAdminService.getUsers();
    } catch (e) {
      // Si hay un error, se guarda el mensaje.
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      // Se asegura de que el estado de carga termine, tanto en éxito como en error.
      _isLoading = false;
      notifyListeners(); // Notifica a la UI que la carga ha terminado.
    }
  }

  /// [createUser]
  ///
  /// Crea un nuevo usuario en el sistema.
  Future<bool> createUser(AppUser user, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _superAdminService.createUser(user, password);
      // Después de crear el usuario, refresca la lista para incluir el nuevo.
      await getUsers();
      return true; // Devuelve true si la operación fue exitosa.
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false; // Devuelve false si hubo un error.
    }
  }

  /// [toggleBlockUser]
  ///
  /// Cambia el estado de bloqueo de un usuario (lo bloquea si no lo está, y viceversa).
  Future<bool> toggleBlockUser(String username, bool isBlocked) async {
    _error = null;
    // No activamos `_isLoading` para que la UI pueda ser más fluida,
    // mostrando el cambio de forma optimista o con un indicador local.
    try {
      // El servicio espera un mapa con los campos a actualizar.
      await _superAdminService.updateUser(username, {'cuentaBloqueada': !isBlocked});
      // Refresca la lista de usuarios para mostrar el cambio.
      await getUsers();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// [deleteUser]
  ///
  /// Elimina un usuario permanentemente del sistema.
  Future<bool> deleteUser(String username) async {
    _error = null;
    try {
      await _superAdminService.deleteUser(username);
      // Refresca la lista de usuarios para quitar el que ha sido eliminado.
      await getUsers();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
