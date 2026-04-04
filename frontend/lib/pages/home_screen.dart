import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null).then((_) {
      _updateFechaHeader();
    });
  }

  // Actualiza el texto de la fecha en el header (ej: Martes, 24 Marzo)
  void _updateFechaHeader() {
    if (mounted) {
      setState(() {
        String diaSemana = DateFormat(
          'EEEE',
          'es_ES',
        ).format(_fechaSeleccionada);
        String diaMes = DateFormat(
          'd MMMM',
          'es_ES',
        ).format(_fechaSeleccionada);
        _fechaHeaderFormatted =
            "${diaSemana[0].toUpperCase()}${diaSemana.substring(1)}, $diaMes";
      });
    }
  }

  // --- LÓGICA DE NAVEGACIÓN DE FECHA ---
  void _irAlDiaSiguiente() {
    setState(() {
      _fechaSeleccionada = _fechaSeleccionada.add(const Duration(days: 1));
      _updateFechaHeader();
      _isFabMenuOpen = false; // Cierra menú FAB si cambias de día
    });
  }

  void _irAlDiaAnterior() {
    setState(() {
      _fechaSeleccionada = _fechaSeleccionada.subtract(const Duration(days: 1));
      _updateFechaHeader();
      _isFabMenuOpen = false; // Cierra menú FAB si cambias de día
    });
  }

  // Comprueba si el día seleccionado es hoy (para mostrar el texto "Hoy")
  bool _esHoy() {
    final now = DateTime.now();
    return _fechaSeleccionada.year == now.year &&
        _fechaSeleccionada.month == now.month &&
        _fechaSeleccionada.day == now.day;
  }

  // --- LÓGICA DE CREACIÓN DE AVISOS (SOLO PRESIDENTE) ---
  void _mostrarFormularioCrearAviso(String username, String token) {
    final TextEditingController _tituloController = TextEditingController();
    final TextEditingController _descripcionController =
        TextEditingController();
    DateTime _fechaAvisoNuevo = DateTime.now(); // Por defecto, aviso para hoy

    showDialog(
      context: context,
      barrierDismissible: false, // Obliga a usar botones para cerrar
      builder: (context) => StatefulBuilder(
        // Necesario para actualizar la fecha dentro del diálogo
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.campaign, color: Colors.teal),
              SizedBox(width: 10),
              Text("Crear Nuevo Aviso"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo Título
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
                // Campo Descripción/Contexto
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
                // Selector de Fecha
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
                    // Abre el selector de fecha nativo
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _fechaAvisoNuevo,
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ), // Un año atrás máx
                      lastDate: DateTime.now().add(
                        const Duration(days: 365),
                      ), // Un año vista máx
                      locale: const Locale('es', 'ES'),
                    );
                    if (picked != null && picked != _fechaAvisoNuevo) {
                      setDialogState(() {
                        // Actualiza la fecha DENTRO del diálogo
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
                          DateFormat(
                            'dd / MM / yyyy',
                            'es_ES',
                          ).format(_fechaAvisoNuevo),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.teal),
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
              child: const Text(
                "Cancelar",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validación básica
                if (_tituloController.text.isEmpty ||
                    _descripcionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Por favor, rellena todos los campos."),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                try {
                  // Llamada al servicio para crear el aviso
                  await _avisoService.crearAviso(
                    _tituloController.text.trim(),
                    _descripcionController.text.trim(),
                    _fechaAvisoNuevo,
                    username,
                    token,
                  );

                  if (mounted) {
                    Navigator.pop(context); // Cierra diálogo
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("¡Aviso creado correctamente! 🎉"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Si el aviso creado es para el día que estamos viendo, recargamos la pantalla
                    if (DateUtils.isSameDay(
                      _fechaAvisoNuevo,
                      _fechaSeleccionada,
                    )) {
                      setState(() {}); // Fuerza el repintado del FutureBuilder
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
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text("CREAR AVISO"),
            ),
          ],
        ),
      ),
    );
  }

  // --- BUILD PRINCIPAL ---
  @override
  Widget build(BuildContext context) {
    // Obtenemos el usuario y el token del Provider
    final user = Provider.of<UserProvider>(context).user;
    final token = Provider.of<UserProvider>(
      context,
    ).token; // Asumimos que guardas el token en el provider

    if (user == null || token == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    bool isVecinoMember = (user.rol != 'USER');
    bool isPresident = (user.rol == 'PRESIDENTE');
    bool isAdmin = (user.rol == 'ADMIN' || user.rol == 'SUPER_ADMIN');

    return Scaffold(
      backgroundColor: Colors.grey[100],

      // --- 1. AÑADE EL DRAWER AQUÍ (Entre el backgroundColor y el appBar) ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Text(
                'Menú Comunidad',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // La opción de Documentos solo se muestra si es Presidente o Admin
            if (isPresident || isAdmin)
              ListTile(
                leading: const Icon(Icons.folder_shared, color: Colors.teal),
                title: const Text('Administración (Documentos)'),
                onTap: () {
                  Navigator.pop(context); // Cierra la barra lateral primero
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocumentosScreen(),
                    ),
                  );
                },
              ),
          ],
        ),
      ),

      // --- APPBAR (Logo RP y Perfil) ---
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "RP",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              "Radio Patio",
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,

        // --- 2. ¡MUY IMPORTANTE! ---
        // BORRA o COMENTA la siguiente línea. Si dice "false", el icono
        // de la hamburguesa (las 3 rayitas) no aparecerá.
        // automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: PopupMenuButton<String>(
              icon: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, color: Colors.white),
              ),
              onSelected: (value) => _manejarOpcionesPerfil(value),
              itemBuilder: (BuildContext context) {
                // ... (Mismo código de menú de perfil que antes)
                List<PopupMenuEntry<String>> menuItems = [
                  const PopupMenuItem<String>(
                    value: 'perfil',
                    child: ListTile(
                      leading: Icon(Icons.account_circle, color: Colors.teal),
                      title: Text("Mi Perfil"),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'reservas',
                    child: ListTile(
                      leading: Icon(Icons.history, color: Colors.orange),
                      title: Text("Todas las Reservas"),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text("Cerrar Sesión"),
                    ),
                  ),
                ];
                return menuItems;
              },
            ),
          ),
        ],
      ),

      // --- CUERPO (Navegación de Fecha y Avisos Reales) ---
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- SECCIÓN NAVEGACIÓN DE FECHA (CON FLECHAS) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botón día anterior
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.teal,
                        size: 20,
                      ),
                      onPressed: _irAlDiaAnterior,
                    ),
                    // Texto de la fecha (ej: Martes, 24 Marzo)
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
                              : DateFormat(
                                  'd MMM',
                                  'es_ES',
                                ).format(_fechaSeleccionada),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    // Botón día siguiente
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.teal,
                        size: 20,
                      ),
                      onPressed: _irAlDiaSiguiente,
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Subtítulo "Avisos"
                Row(
                  children: [
                    Icon(Icons.campaign, color: Colors.redAccent.shade100),
                    const SizedBox(width: 8),
                    const Text(
                      "Avisos Importantes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // --- CARGA DE AVISOS REALES (FUTUREBUILDER) ---
                FutureBuilder<List<Aviso>>(
                  future: _avisoService.getAvisosPorFecha(
                    _fechaSeleccionada,
                    token!,
                  ), // <--- Pasa el token aquí
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return _buildErrorState(snapshot.error.toString());
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmptyAvisosState();
                    } else {
                      // Tenemos avisos reales, los pintamos
                      final avisos = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: avisos.length,
                        itemBuilder: (context, index) {
                          final aviso = avisos[index];
                          return _buildAvisoCard(aviso);
                        },
                      );
                    }
                  },
                ),

                const SizedBox(height: 100), // Espacio para el FAB
              ],
            ),
          ),

          // Capa oscura del FAB
          if (_isFabMenuOpen)
            GestureDetector(
              onTap: () => setState(() => _isFabMenuOpen = false),
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
        ],
      ),

      // --- BOTÓN FLOTANTE (+) TIPO TWITTER DESPLEGABLE ---
      // Le pasamos el username y el token para la creación de avisos
      floatingActionButton: _buildTwitterStyleFab(
        isVecinoMember,
        isPresident,
        isAdmin,
        user.username,
        token,
      ),
    );
  }

  // --- WIDGETS AUXILIARES DE MAQUETACIÓN ---

  // Tarjeta de aviso maquetada con datos REALES del modelo Aviso
  Widget _buildAvisoCard(Aviso aviso) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    aviso.titulo,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Opcional: Mostrar quién lo creó
                if (aviso.creadorUsername != null)
                  Text(
                    "@${aviso.creadorUsername}",
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              aviso.descripcion,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAvisosState() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 50,
            color: Colors.teal.shade200,
          ),
          const SizedBox(height: 10),
          const Text(
            "¡Todo al día!",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            "No hay avisos para el día ${DateFormat('d MMM', 'es_ES').format(_fechaSeleccionada)}.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
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

  // --- LÓGICA DEL BOTÓN FLOTANTE DESPLEGABLE (+) ---
  Widget _buildTwitterStyleFab(
    bool isMember,
    bool isPresident,
    bool isAdmin,
    String username,
    String token,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Opciones desplegadas
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

          // --- CAMBIO AQUÍ: La opción de crear aviso es SOLO PARA EL PRESIDENTE (y admin) ---
          if (isPresident || isAdmin) ...[
            const Divider(indent: 100),
            _buildFabMenuItem(
              icon: Icons.campaign,
              label: "Crear Aviso",
              color: Colors.redAccent,
              onTap: () => _mostrarFormularioCrearAviso(
                username,
                token,
              ), // Abre formulario
            ),
            const SizedBox(height: 15),
          ],
        ],
        // El botón "+" principal
        FloatingActionButton(
          onPressed: () {
            if (!isMember) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserPage()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    "Primero debes crear o unirte a una comunidad.",
                  ),
                ),
              );
            } else {
              setState(() => _isFabMenuOpen = !_isFabMenuOpen);
            }
          },
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 5,
          child: AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: _isFabMenuOpen ? 0.125 : 0,
            child: const Icon(Icons.add, size: 30),
          ),
        ),
      ],
    );
  }

  Widget _buildFabMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    // ... (Mismo código de item del menú FAB que antes)
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 10),
        FloatingActionButton.small(
          heroTag: label,
          onPressed: () {
            setState(() => _isFabMenuOpen = false); // Cierra menú
            onTap(); // Ejecuta acción
          },
          backgroundColor: color,
          foregroundColor: Colors.white,
          child: Icon(icon, size: 20),
        ),
      ],
    );
  }

  // --- LÓGICA DE NAVEGACIÓN DEL MENÚ DE PERFIL ---
  void _manejarOpcionesPerfil(String value) {
    // ... (Mismo código de menú de perfil que antes)
    switch (value) {
      case 'perfil':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserPage()),
        );
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
