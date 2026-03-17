/// [AppUser]
///
/// Modelo de datos que representa a un usuario dentro de la aplicación.
///
/// Esta clase es inmutable y contiene toda la información relevante de un usuario,
/// como su identificador, nombre de usuario, rol, etc. Se utiliza a través de
/// toda la aplicación para gestionar y mostrar la información del usuario.
class AppUser {
  /// El identificador único del usuario en la base de datos.
  /// Puede ser nulo si el objeto `AppUser` representa a un usuario que
  /// aún no ha sido guardado en el backend.
  final int? id;

  /// El nombre de usuario único. Es obligatorio y se usa para el login.
  final String username;

  /// El nombre de pila del usuario.
  final String? nombre;

  /// Los apellidos del usuario.
  final String? apellidos;

  /// La dirección de correo electrónico del usuario.
  final String? email;

  /// El rol del usuario dentro de la aplicación (ej: 'USER', 'ADMIN', 'SUPER_ADMIN').
  /// Determina los permisos y las vistas a las que tiene acceso.
  final String rol;

  /// Indica si la cuenta del usuario está bloqueada.
  /// Por defecto es `false`.
  final bool cuentaBloqueada;

  /// Contador de intentos de inicio de sesión fallidos.
  /// Puede ser usado por el backend para implementar políticas de bloqueo de cuentas.
  final int intentosFallidos;

  /// Constructor principal para crear una instancia de `AppUser`.
  AppUser({
    this.id,
    required this.username,
    this.nombre,
    this.apellidos,
    this.email,
    required this.rol,
    this.cuentaBloqueada = false,
    this.intentosFallidos = 0,
  });

  /// [AppUser.fromJson]
  ///
  /// Constructor factory para crear una instancia de `AppUser` a partir de un
  /// mapa JSON, que es como la API del backend devuelve los datos.
  ///
  /// Proporciona valores por defecto para campos opcionales (`rol`, `cuentaBloqueada`, etc.)
  /// para garantizar la consistencia del objeto.
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      username: json['username'],
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      email: json['email'],
      rol: json['rol'] ?? 'USER',
      cuentaBloqueada: json['cuentaBloqueada'] ?? false,
      intentosFallidos: json['intentosFallidos'] ?? 0,
    );
  }

  /// [toJson]
  ///
  /// Convierte la instancia de `AppUser` a un mapa JSON.
  /// Este método es útil para enviar los datos del usuario al backend
  /// en el cuerpo de una petición HTTP (ej: al crear o actualizar un usuario).
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nombre': nombre,
      'apellidos': apellidos,
      'email': email,
      'rol': rol,
      'cuentaBloqueada': cuentaBloqueada,
      'intentosFallidos': intentosFallidos,
    };
  }
}
