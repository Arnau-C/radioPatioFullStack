import 'package:flutter/material.dart';

import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/services/community_service.dart';

/// [CommunityProvider]
///
/// Este provider gestiona todo lo relacionado con las comunidades de vecinos.
/// Se encarga de la creación de comunidades, la unión a ellas y la obtención
/// de sus detalles.
///
/// Utiliza `ChangeNotifier` para que los widgets que lo escuchan puedan
/// redibujarse cuando su estado cambie (ej: al cargar datos o al mostrar un error).
class CommunityProvider with ChangeNotifier {
  // Instancia del servicio que se comunica con la API para las operaciones de comunidad.
  final CommunityService _communityService = CommunityService();

  // Referencia al UserProvider para acceder a los datos del usuario actual (ej: su username).
  // Es inyectado en el constructor y se puede actualizar con el método `update`.
  UserProvider _userProvider;

  // --- ESTADO INTERNO DEL PROVIDER ---

  // Nombre de la comunidad a la que pertenece el usuario.
  String? communityName;

  // ID numérico de la comunidad (necesario para las APIs de reservas, incidencias, etc.).
  int? communityId;

  // Código de invitación de la comunidad (si el usuario es presidente/admin).
  String? invitationCode;

  // Flag para indicar si hay una operación en curso (ej: cargando datos de la API).
  bool _isLoading = false;

  // Mensaje de error en caso de que una operación falle.
  String? _error;

  // --- CONSTRUCTOR ---
  CommunityProvider(this._userProvider);

  // --- GETTERS PÚBLICOS ---
  // Permiten acceder al estado interno desde fuera de la clase de forma segura (solo lectura).
  bool get isLoading => _isLoading;
  String? get error => _error;

  // --- MÉTODOS PÚBLICOS ---

  /// [update]
  ///
  /// Actualiza la referencia al UserProvider. Esto es útil en escenarios donde
  /// el UserProvider puede ser reemplazado o actualizado en el árbol de widgets.
  void update(UserProvider userProvider) {
    _userProvider = userProvider;
  }

  /// [getCommunityDetails]
  ///
  /// Obtiene los detalles de la comunidad a la que pertenece el usuario.
  /// Almacena el ID, nombre y código de invitación para uso de toda la app.
  Future<void> getCommunityDetails() async {
    // Guarda: Si no hay un usuario en sesión, no se puede continuar.
    final username = _userProvider.user?.username;
    if (username == null) return;

    // Inicia el estado de carga y limpia errores anteriores.
    _isLoading = true;
    _error = null;
    notifyListeners(); // Notifica a los widgets que el estado ha cambiado.

    try {
      // Llama al servicio para obtener los datos.
      final data = await _communityService.getCommunityDetails(username);
      // Actualiza el estado con los datos recibidos.
      communityName = data['nombre'];
      communityId = data['id'] ?? data['comunidadId'];
      invitationCode = data['codigoInvitacion'];
    } catch (e) {
      // En caso de error, guarda el mensaje.
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      // Finaliza el estado de carga, tanto en éxito como en error.
      _isLoading = false;
      notifyListeners();
    }
  }

  /// [joinCommunity]
  ///
  /// Permite a un usuario unirse a una comunidad existente usando un código de invitación.
  Future<Map<String, dynamic>?> joinCommunity(String code) async {
    final username = _userProvider.user?.username;
    if (username == null) return null;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _communityService.joinCommunity(codigo: code, username: username);
      communityName = data['comunidadNombre'];
      
      // Si la operación es exitosa, se actualiza el rol del usuario a 'VECINO'.
      // Se crea una copia del usuario actual y se modifica el rol.
      // Este mapa se devuelve para que el `UserProvider` pueda ser actualizado.
      final updatedUserData = Map<String, dynamic>.from(_userProvider.user!.toJson());
      updatedUserData['rol'] = 'VECINO';
      updatedUserData['token'] = _userProvider.token; // Preservamos el token para no desloguear

      return updatedUserData;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// [createCommunity]
  ///
  /// Crea una nueva comunidad y asigna al usuario actual como presidente.
  Future<Map<String, dynamic>?> createCommunity({
    required String nombre,
    required String direccion,
  }) async {
    final username = _userProvider.user?.username;
    if (username == null) return null;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Llama al servicio para crear la comunidad.
      final data = await _communityService.createCommunity(
        nombre: nombre,
        direccion: direccion,
        presidenteUsername: username,
      );
      // Guarda el código de invitación y el nombre de la nueva comunidad.
      invitationCode = data['codigoInvitacion'];
      communityName = nombre;

      // Al crear la comunidad, el rol del usuario pasa a ser 'PRESIDENTE'.
      // Se prepara el mapa de datos del usuario actualizado para devolverlo.
      final updatedUserData = Map<String, dynamic>.from(_userProvider.user!.toJson());
      updatedUserData['rol'] = 'PRESIDENTE';
      updatedUserData['token'] = _userProvider.token; // Preservamos el token para no desloguear

      return updatedUserData;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
