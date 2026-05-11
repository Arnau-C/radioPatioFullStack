import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:frontend/pages/create_incidence.dart';
import 'package:frontend/pages/miembros_comunidad_screen.dart';
import 'package:frontend/pages/tablon_incidencias_screen.dart';
import 'package:frontend/utils/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:frontend/models/aviso.dart';
import 'package:frontend/pages/login_page.dart';
import 'package:frontend/pages/user_page.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/services/aviso_service.dart';
import 'package:frontend/pages/documentos_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _fechaSeleccionada =
      DateTime.now(); // El día que estamos visualizando
  String _fechaHeaderFormatted = "";
  bool _isFabMenuOpen = false;
  final AvisoService _avisoService = AvisoService(); // Instancia del servicio

  int? _comunidadIdActual;
  int _numeroIncidencias = 0;

  // --- COLORES DEL NUEVO TEMA ---
  final Color primaryDark = const Color(0xFF1A365D); // Azul marino profundo
  final Color primaryLight = const Color(0xFFE2E8F0); // Gris azulado claro
  final Color accentColor = const Color(0xFFE27D60); // Naranja/Teja (para contrastar)

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null).then((_) {
      _updateFechaHeader();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      final token = userProvider.token;

      if (user != null && user.rol != 'USER' && token != null) {
        _obtenerComunidadId(user.username, token);
      }
    });
  }

  Future<void> _cargarNumeroIncidencias(String token, int comunidadId) async {
    final url = Uri.parse(
      '${ApiClient.baseUrl}/comunidades/$comunidadId/incidencias',
    );
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        if (mounted) {
          setState(() {
            _numeroIncidencias = data.length; 
          });
        }
      }
    } catch (e) {
      debugPrint('Error al cargar incidencias: $e');
    }
  }

  Future<void> _obtenerComunidadId(String username, String token) async {
    final url = Uri.parse('${ApiClient.baseUrl}/comunidades/detalle/$username');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            _comunidadIdActual =
                data['id'] ?? data['idComunidad'] ?? data['comunidadId'];
          });
        }
      } else {
        debugPrint(
          'Error al obtener datos de comunidad: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('Fallo de conexión en _obtenerComunidadId: $e');
    }
  }

  void _updateFechaHeader() {
    if (mounted) {
      setState(() {
        String diaSemana = DateFormat('EEEE', 'es_ES').format(_fechaSeleccionada);
        String diaMes = DateFormat('d MMMM', 'es_ES').format(_fechaSeleccionada);
        _fechaHeaderFormatted =
            "${diaSemana[0].toUpperCase()}${diaSemana.substring(1)}, $diaMes";
      });
    }
  }

  void _irAlDiaSiguiente() {
    setState(() {
      _fechaSeleccionada = _fechaSeleccionada.add(const Duration(days: 1));
      _updateFechaHeader();
      _isFabMenuOpen = false;
    });
  }

  void _irAlDiaAnterior() {
    setState(() {
      _fechaSeleccionada = _fechaSeleccionada.subtract(const Duration(days: 1));
      _updateFechaHeader();
      _isFabMenuOpen = false; 
    });
  }

  bool _esHoy() {
    final now = DateTime.now();
    return _fechaSeleccionada.year == now.year &&
        _fechaSeleccionada.month == now.month &&
        _fechaSeleccionada.day == now.day;
  }

  void _mostrarFormularioCrearAviso(String username, String token) {
    final TextEditingController _tituloController = TextEditingController();
    final TextEditingController _descripcionController = TextEditingController();
    DateTime _fechaAvisoNuevo = DateTime.now(); 

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.campaign, color: accentColor),
              const SizedBox(width: 10),
              const Text("Crear Nuevo Aviso"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: "Título del Aviso",
                    hintText: "Ej: Corte de agua",
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: "Contexto / Descripción",
                    hintText: "Detalla el aviso aquí...",
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Fecha del Aviso:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _fechaAvisoNuevo,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)), 
                      lastDate: DateTime.now().add(const Duration(days: 365)), 
                      locale: const Locale('es', 'ES'),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: primaryDark, 
                              onPrimary: Colors.white, 
                              onSurface: Colors.black, 
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null && picked != _fechaAvisoNuevo) {
                      setDialogState(() {
                        _fechaAvisoNuevo = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd / MM / yyyy', 'es_ES').format(_fechaAvisoNuevo),
                          style: const TextStyle(fontSize: 16),
                        ),
                        Icon(Icons.calendar_today, color: primaryDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_tituloController.text.isEmpty || _descripcionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Por favor, rellena todos los campos."),
                      backgroundColor: accentColor,
                    ),
                  );
                  return;
                }

                try {
                  await _avisoService.crearAviso(
                    _tituloController.text.trim(),
                    _descripcionController.text.trim(),
                    _fechaAvisoNuevo,
                    username,
                    token,
                  );

                  if (mounted) {
                    Navigator.pop(context); 
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("¡Aviso creado correctamente! 🎉"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    if (DateUtils.isSameDay(_fechaAvisoNuevo, _fechaSeleccionada)) {
                      setState(() {}); 
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error al crear aviso: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryDark,
                foregroundColor: Colors.white,
              ),
              child: const Text("CREAR AVISO"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final token = Provider.of<UserProvider>(context).token; 

    if (user == null || token == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    bool isVecinoMember = (user.rol != 'USER');
    bool isPresident = (user.rol == 'PRESIDENTE');
    bool isAdmin = (user.rol == 'ADMIN' || user.rol == 'SUPER_ADMIN');

    // 👇 ESTA ES LA CLAVE: Aquí están tus variables
    bool puedeCrearAvisos = isPresident || isAdmin || (user.permisoCrearAvisos);
    bool puedeVerDocumentos = isPresident || isAdmin || (user.permisoGestionarDocumentos);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: primaryDark),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.person, size: 35, color: primaryDark),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '@${user.username}',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.rol == 'PRESIDENTE' ? 'Presidente' : 'Vecino',
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                  ),
                ],
              ),
            ),
            // 👇 Aquí usamos tu variable puedeVerDocumentos
            if (puedeVerDocumentos)
              ListTile(
                leading: Icon(Icons.folder_shared, color: primaryDark),
                title: const Text('Administración (Documentos)'),
                onTap: () {
                  Navigator.pop(context); 
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DocumentosScreen()),
                  );
                },
              ),
          ],
        ),
      ),

      // --- APPBAR CON TU LOGO Y NUEVO COLOR ---
      appBar: AppBar(
        backgroundColor: primaryLight, 
        
        // 👇 Quitamos la sombra difuminada y ponemos tu rayita negra
        elevation: 0, 
        shape: const Border(
          bottom: BorderSide(
            color: Colors.black, // Color de la raya
            width: 1.0,          // Grosor (pon 2.0 si la quieres más gorda)
          ),
        ),
        
        iconTheme: IconThemeData(color: primaryDark), // Menú oscuro para que se vea en el blanco

        titleSpacing: 0, 
        title: SizedBox(
          height: 72,
          child: Image.asset(
            'lib/images/logo.png', 
            fit: BoxFit.contain, 
            alignment: Alignment.centerLeft,
          ),
        ),

        actions: [
          if (_comunidadIdActual != null) 
            Padding(
              padding: const EdgeInsets.only(right: 5.0),
              child: IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Tu icono original (!)
                    const Icon(Icons.priority_high, color: Colors.orange, size: 28),
                    if (_numeroIncidencias > 0)
                      Positioned(
                        right: -2,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$_numeroIncidencias',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TablonIncidenciasScreen(
                        comunidadId: _comunidadIdActual!,
                        tokenJwt: token, 
                        isPresidenteOrAdmin: isPresident || isAdmin,
                      ),
                    ),
                  ).then((_) {
                    _cargarNumeroIncidencias(token, _comunidadIdActual!);
                  });
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: PopupMenuButton<String>(
              icon: CircleAvatar(
                backgroundColor: primaryDark.withOpacity(0.1),
                child: Icon(Icons.person, color: primaryDark),
              ),
              onSelected: (value) => _manejarOpcionesPerfil(value),
              itemBuilder: (BuildContext context) {
                List<PopupMenuEntry<String>> menuItems = [
                  PopupMenuItem<String>(
                    value: 'perfil',
                    child: ListTile(
                      leading: Icon(Icons.account_circle, color: primaryDark),
                      title: const Text("Mi Perfil"),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'comunidad',
                    child: ListTile(
                      leading: Icon(Icons.people, color: primaryDark),
                      title: const Text("Ver Comunidad"),
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'reservas',
                    child: ListTile(
                      leading: Icon(Icons.history, color: accentColor), 
                      title: const Text("Todas las Reservas"),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text("Cerrar Sesión"),
                    ),
                  ),
                ];
                return menuItems;
              },
            ),
          ),
        ],
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- SECCIÓN NAVEGACIÓN DE FECHA ---
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios, color: primaryDark, size: 20),
                        onPressed: _irAlDiaAnterior,
                      ),
                      Column(
                        children: [
                          Text(
                            _fechaHeaderFormatted,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            _esHoy()
                                ? "Hoy"
                                : DateFormat('d MMM', 'es_ES').format(_fechaSeleccionada),
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primaryDark,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward_ios, color: primaryDark, size: 20),
                        onPressed: _irAlDiaSiguiente,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                Row(
                  children: [
                    Icon(Icons.campaign, color: primaryDark, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      "Avisos Importantes",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: primaryDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                FutureBuilder<List<Aviso>>(
                  future: _avisoService.getAvisosPorFecha(_fechaSeleccionada, token),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(color: primaryDark),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return _buildErrorState(snapshot.error.toString());
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyAvisosState();
                    } else {
                      final avisos = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: avisos.length,
                        itemBuilder: (context, index) {
                          return _buildAvisoCard(avisos[index]);
                        },
                      );
                    }
                  },
                ),

                const SizedBox(height: 100), 
              ],
            ),
          ),

          if (_isFabMenuOpen)
            GestureDetector(
              onTap: () => setState(() => _isFabMenuOpen = false),
              child: Container(color: Colors.black.withOpacity(0.6)), // Fondo más oscuro al abrir menú
            ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            // 👇 Y aquí se le pasa puedeCrearAvisos al botón flotante
            child: _buildTwitterStyleFab(isVecinoMember, puedeCrearAvisos, user.username, token),
          ),
        ],
      ),
    );
  }

  Widget _buildAvisoCard(Aviso aviso) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade200, width: 1), // Borde sutil
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    aviso.titulo,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: primaryDark,
                    ),
                  ),
                ),
                if (aviso.creadorUsername != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "@${aviso.creadorUsername}",
                      style: TextStyle(
                        fontSize: 11,
                        color: primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 20, thickness: 0.5),
            Text(
              aviso.descripcion,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAvisosState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.task_alt, size: 60, color: Colors.green.shade300),
          const SizedBox(height: 15),
          Text(
            "¡Todo al día!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryDark),
          ),
          const SizedBox(height: 5),
          Text(
            "No hay avisos para el día ${DateFormat('d MMM', 'es_ES').format(_fechaSeleccionada)}.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 40, color: Colors.red),
          const SizedBox(height: 10),
          const Text(
            "Error al cargar avisos",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Icons.refresh),
            label: const Text("Reintentar"),
          ),
        ],
      ),
    );
  }

  // 👇 Aquí está la otra parte del cambio: recibe 'puedeCrearAvisos'
  Widget _buildTwitterStyleFab(bool isMember, bool puedeCrearAvisos, String username, String token) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_isFabMenuOpen) ...[
          if (isMember)
            _buildFabMenuItem(
              icon: Icons.chat_bubble_outline,
              label: "Nuevo mensaje foro",
              color: Colors.deepPurple,
              onTap: () {},
            ),
          const SizedBox(height: 15),
          if (isMember)
            _buildFabMenuItem(
              icon: Icons.event_available,
              label: "Reservar zona",
              color: Colors.orange,
              onTap: () {},
            ),
          const SizedBox(height: 15),
          if (isMember)
            _buildFabMenuItem(
              icon: Icons.build,
              label: "Reportar Avería",
              color: Colors.blueGrey,
              onTap: () {
                if (_comunidadIdActual != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CrearIncidenciaPage(comunidadId: _comunidadIdActual!),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Aún cargando datos... Inténtalo de nuevo.'),
                      backgroundColor: accentColor,
                    ),
                  );
                }
              },
            ),
          const SizedBox(height: 15),
          // 👇 Y aquí usamos la variable
          if (puedeCrearAvisos) ...[
            const Divider(indent: 100),
            _buildFabMenuItem(
              icon: Icons.campaign,
              label: "Crear Aviso",
              color: Colors.redAccent,
              onTap: () => _mostrarFormularioCrearAviso(username, token),
            ),
            const SizedBox(height: 15),
          ],
        ],
        FloatingActionButton(
          onPressed: () {
            if (!isMember) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserPage()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Primero debes crear o unirte a una comunidad.")),
              );
            } else {
              setState(() => _isFabMenuOpen = !_isFabMenuOpen);
            }
          },
          backgroundColor: primaryDark,
          foregroundColor: Colors.white,
          elevation: 6,
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _isFabMenuOpen ? 0.125 : 0,
            child: const Icon(Icons.add, size: 30),
          ),
        ),
      ],
    );
  }

  Widget _buildFabMenuItem({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        const SizedBox(width: 15),
        FloatingActionButton.small(
          heroTag: label,
          onPressed: () {
            setState(() => _isFabMenuOpen = false); 
            onTap(); 
          },
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          child: Icon(icon, size: 22),
        ),
      ],
    );
  }

  void _manejarOpcionesPerfil(String value) {
    switch (value) {
      case 'perfil':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserPage()),
        );
        break;
      case 'comunidad':
        if (_comunidadIdActual != null) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          bool isPresident = (userProvider.user?.rol == 'PRESIDENTE');
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MiembrosComunidadScreen(
                comunidadId: _comunidadIdActual!,
                tokenJwt: userProvider.token!,
                isPresidente: isPresident,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cargando datos de comunidad...')),
          );
        }
        break;
      case 'logout':
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Opción $value (Próximamente)...")),
        );
    }
  }
}