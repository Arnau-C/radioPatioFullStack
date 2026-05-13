import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_typography.dart';
import 'package:frontend/ui/feedback/radio_patio_snackbar.dart';
import 'package:frontend/ui/shared/state_widgets.dart';

import 'package:frontend/models/aviso.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/providers/community_provider.dart';
import 'package:frontend/services/aviso_service.dart';
import 'package:frontend/utils/api_client.dart';

/// [HomeScreen]
///
/// Pantalla principal de RadioPatio — muestra el calendario de avisos diarios.
///
/// Tras la refactorización, esta pantalla se centra SOLO en su función principal:
/// - Navegación de fechas (día anterior / siguiente).
/// - Listado de avisos del día seleccionado.
/// - FAB simplificado para crear avisos (solo Presidente/Admin).
///
/// Las funciones que antes estaban aquí (Drawer, PopupMenu, FAB con reservas/incidencias)
/// se han migrado a las tabs del [ResponsiveScaffold] (Reservas, Incidencias, Perfil).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- ESTADO DE LA PANTALLA ---

  /// Día que estamos visualizando en el calendario de avisos.
  DateTime _fechaSeleccionada = DateTime.now();

  /// Texto formateado para el header de la fecha (ej: "Lunes, 12 mayo").
  String _fechaHeaderFormatted = "";

  /// Servicio para obtener y crear avisos desde la API.
  final AvisoService _avisoService = AvisoService();

  /// Número de incidencias pendientes (para el badge de la AppBar).
  int _numeroIncidencias = 0;

  /// [initState]
  ///
  /// Inicializa el formato de fecha en español y carga datos iniciales.
  @override
  void initState() {
    super.initState();
    // Inicializar el formato de fechas en español para DateFormat.
    initializeDateFormatting('es_ES', null).then((_) {
      _updateFechaHeader();
    });

    // Cargar el número de incidencias tras el primer frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarIncidenciasIniciales();
    });
  }

  /// Carga el número de incidencias si tenemos comunidadId disponible.
  void _cargarIncidenciasIniciales() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final communityProvider =
        Provider.of<CommunityProvider>(context, listen: false);
    final user = userProvider.user;
    final token = userProvider.token;
    final comunidadId = communityProvider.communityId;

    if (user != null && user.rol != 'USER' && token != null && comunidadId != null) {
      _cargarNumeroIncidencias(token, comunidadId);
    }
  }

  // =========================================================================
  // LÓGICA DE DATOS — Comunicación con la API
  // =========================================================================

  /// Carga el número total de incidencias de la comunidad para el badge.
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

  // =========================================================================
  // LÓGICA DE NAVEGACIÓN DE FECHAS
  // =========================================================================

  /// Actualiza el texto formateado del header de fecha.
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

  /// Avanza al día siguiente.
  void _irAlDiaSiguiente() {
    setState(() {
      _fechaSeleccionada = _fechaSeleccionada.add(const Duration(days: 1));
      _updateFechaHeader();
    });
  }

  /// Retrocede al día anterior.
  void _irAlDiaAnterior() {
    setState(() {
      _fechaSeleccionada = _fechaSeleccionada.subtract(const Duration(days: 1));
      _updateFechaHeader();
    });
  }

  /// Comprueba si la fecha seleccionada es hoy.
  bool _esHoy() {
    final now = DateTime.now();
    return _fechaSeleccionada.year == now.year &&
        _fechaSeleccionada.month == now.month &&
        _fechaSeleccionada.day == now.day;
  }

  // =========================================================================
  // FORMULARIO DE CREAR AVISO — Solo para Presidente/Admin
  // =========================================================================

  /// Muestra un diálogo para crear un nuevo aviso comunitario.
  void _mostrarFormularioCrearAviso(String username, String token) {
    final tituloController = TextEditingController();
    final descripcionController = TextEditingController();
    DateTime fechaAvisoNuevo = DateTime.now();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.campaign, color: AppColors.accent),
              const SizedBox(width: 10),
              const Text("Crear Nuevo Aviso"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Campo: título del aviso.
                TextField(
                  controller: tituloController,
                  decoration: const InputDecoration(
                    labelText: "Título del Aviso",
                    hintText: "Ej: Corte de agua",
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 15),
                // Campo: descripción/contexto del aviso.
                TextField(
                  controller: descripcionController,
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
                // Selector de fecha del aviso.
                const Text(
                  "Fecha del Aviso:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: dialogContext,
                      initialDate: fechaAvisoNuevo,
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                      locale: const Locale('es', 'ES'),
                    );
                    if (picked != null && picked != fechaAvisoNuevo) {
                      setDialogState(() {
                        fechaAvisoNuevo = picked;
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
                          DateFormat('dd / MM / yyyy', 'es_ES')
                              .format(fechaAvisoNuevo),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primaryDark,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                "Cancelar",
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (tituloController.text.isEmpty ||
                    descripcionController.text.isEmpty) {
                  RadioPatioSnackbar.warning(
                    dialogContext,
                    "Por favor, rellena todos los campos.",
                  );
                  return;
                }

                try {
                  await _avisoService.crearAviso(
                    tituloController.text.trim(),
                    descripcionController.text.trim(),
                    fechaAvisoNuevo,
                    username,
                    token,
                  );

                  if (mounted) {
                    Navigator.pop(dialogContext);
                    RadioPatioSnackbar.success(
                      context,
                      "¡Aviso creado correctamente! 🎉",
                    );
                    // Si el aviso es para el día que estamos viendo, refrescamos.
                    if (DateUtils.isSameDay(fechaAvisoNuevo, _fechaSeleccionada)) {
                      setState(() {});
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    RadioPatioSnackbar.error(
                      dialogContext,
                      "Error al crear aviso: $e",
                    );
                  }
                }
              },
              child: const Text("CREAR AVISO"),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // BUILD — Interfaz de usuario
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final token = Provider.of<UserProvider>(context).token;

    // Guard: Si no hay usuario logueado, mostramos un loader.
    if (user == null || token == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Determinamos los permisos del usuario actual.
    final bool isPresident = user.rol == 'PRESIDENTE';
    final bool isAdmin = user.rol == 'ADMIN' || user.rol == 'SUPER_ADMIN';
    final bool canCreateAvisos = isPresident || isAdmin;

    return Scaffold(
      // --- APPBAR SIMPLIFICADA ---
      // Ya no tiene Drawer ni PopupMenu. Solo el logo y el badge de incidencias.
      appBar: AppBar(
        // Eliminamos el leading automático (hamburguesa del Drawer).
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: SizedBox(
          height: 72,
          child: Image.asset(
            'lib/images/logo.png',
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
          ),
        ),
        actions: [
          // Badge de incidencias pendientes.
          _buildIncidenciasBadge(token),
          const SizedBox(width: 8),
        ],
      ),

      // --- CUERPO: Navegador de fecha + Lista de avisos ---
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Navegador de fecha (anterior / hoy / siguiente).
            _buildDateNavigator(),
            const SizedBox(height: 25),

            // Título de la sección de avisos.
            Row(
              children: [
                Icon(Icons.campaign, color: AppColors.primaryDark, size: 28),
                const SizedBox(width: 8),
                Text(
                  "Avisos Importantes",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Lista de avisos del día (FutureBuilder).
            _buildAvisosList(token),

            // Espacio extra al final para que el FAB no tape contenido.
            const SizedBox(height: 80),
          ],
        ),
      ),

      // --- FAB SIMPLIFICADO ---
      // Solo muestra el botón "Crear Aviso" para Presidente/Admin.
      // Las acciones de Reservar y Reportar Avería están ahora en sus tabs.
      floatingActionButton: canCreateAvisos
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: () => _mostrarFormularioCrearAviso(
                user.username,
                token,
              ),
              icon: const Icon(Icons.campaign),
              label: const Text("Nuevo Aviso"),
            )
          : null,
    );
  }

  // =========================================================================
  // WIDGETS EXTRAÍDOS — Componentes del build principal
  // =========================================================================

  /// Badge con el número de incidencias pendientes.
  /// Al pulsarlo, navega a la tab de incidencias usando GoRouter.
  Widget _buildIncidenciasBadge(String token) {
    return IconButton(
      icon: Badge(
        isLabelVisible: _numeroIncidencias > 0,
        label: Text(
          '$_numeroIncidencias',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Icon(
          Icons.priority_high,
          color: AppColors.accent,
          size: 28,
        ),
      ),
      onPressed: () {
        // Navegamos a la tab de incidencias.
        context.go('/incidencias');
      },
    );
  }

  /// Navegador de fecha con flechas izquierda/derecha y label del día actual.
  Widget _buildDateNavigator() {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          _irAlDiaSiguiente(); // Swipe a la izquierda -> siguiente día
        } else if (details.primaryVelocity! > 0) {
          _irAlDiaAnterior(); // Swipe a la derecha -> día anterior
        }
      },
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppColors.primaryDark, size: 20),
            onPressed: _irAlDiaAnterior,
          ),
          Column(
            children: [
              Text(
                _fechaHeaderFormatted,
                style: AppTypography.dateNavigatorLabel,
              ),
              Text(
                _esHoy()
                    ? "Hoy"
                    : DateFormat('d MMM', 'es_ES').format(_fechaSeleccionada),
                style: AppTypography.dateNavigatorDay,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios,
                color: AppColors.primaryDark, size: 20),
            onPressed: _irAlDiaSiguiente,
          ),
        ],
      ),
      ),
    );
  }

  /// Lista de avisos del día seleccionado usando FutureBuilder.
  Widget _buildAvisosList(String token) {
    return FutureBuilder<List<Aviso>>(
      future: _avisoService.getAvisosPorFecha(_fechaSeleccionada, token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircularProgressIndicator(color: AppColors.primaryDark),
            ),
          );
        } else if (snapshot.hasError) {
          // Usamos el widget reutilizable del Design System.
          return ErrorStateWidget(
            message: snapshot.error.toString(),
            onRetry: () => setState(() {}),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Usamos el widget reutilizable del Design System.
          return EmptyStateWidget(
            icon: Icons.task_alt,
            iconColor: AppColors.success,
            title: "¡Todo al día!",
            subtitle:
                "No hay avisos para el día ${DateFormat('d MMM', 'es_ES').format(_fechaSeleccionada)}.",
          );
        } else {
          final avisos = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: avisos.length,
            itemBuilder: (context, index) => TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutQuart,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: _buildAvisoCard(avisos[index]),
            ),
          );
        }
      },
    );
  }

  /// Tarjeta individual de un aviso.
  Widget _buildAvisoCard(Aviso aviso) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Título del aviso.
                Expanded(
                  child: Text(
                    aviso.titulo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryDark,
                        ),
                  ),
                ),
                // Badge con el username del creador.
                if (aviso.creadorUsername != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "@${aviso.creadorUsername}",
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 20, thickness: 0.5),
            // Descripción del aviso.
            Text(
              aviso.descripcion,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
