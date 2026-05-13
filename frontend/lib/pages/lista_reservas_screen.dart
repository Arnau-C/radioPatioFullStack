import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/models/recurso.dart';
import 'package:frontend/models/reserva.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/services/recurso_service.dart';
import 'package:frontend/services/reserva_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ListaReservasScreen extends StatefulWidget {
  final int comunidadId;
  const ListaReservasScreen({super.key, required this.comunidadId});

  @override
  State<ListaReservasScreen> createState() => _ListaReservasScreenState();
}

class _ListaReservasScreenState extends State<ListaReservasScreen> {
  final ReservaService _reservaService = ReservaService();
  final RecursoService _recursoService = RecursoService();

  // Lista completa tal como llega del backend (nunca se filtra por fecha)
  List<Reserva> _reservasCompletas = [];
  // Vista base según el toggle (activas o todo el historial)
  List<Reserva> _todasLasReservas = [];
  // Resultado final tras aplicar filtros de recurso y fecha
  List<Reserva> _reservasFiltradas = [];
  List<Recurso> _recursos = [];

  bool _isLoading = true;
  bool _verHistorial = false;

  // Filtros
  Recurso? _recursoFiltro;
  DateTime? _fechaFiltro;

  final Color primaryDark = const Color(0xFF1A365D);
  final Color accentColor = const Color(0xFFE27D60);

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final token = Provider.of<UserProvider>(context, listen: false).token;
    if (token == null) return;

    try {
      // Cargar los recursos para el desplegable de filtros
      final recursos = await _recursoService.obtenerRecursos(widget.comunidadId, token);
      
      // Cargar el pool global de reservas de la comunidad
      final reservas = await _reservaService.obtenerReservasPorComunidad(widget.comunidadId, token);
      
      if (mounted) {
        setState(() {
          _recursos = recursos;
          _reservasCompletas = reservas;
          _todasLasReservas = _verHistorial ? reservas : _soloActivas(reservas);
          _reservasFiltradas = List.from(_todasLasReservas);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error cargando la lista de reservas')));
      }
    }
  }

  List<Reserva> _soloActivas(List<Reserva> reservas) {
    final now = DateTime.now();
    return reservas.where((r) => r.estado == 'ACTIVA' && r.fechaFin.isAfter(now)).toList();
  }

  void _cambiarVista(bool verHistorial) {
    setState(() {
      _verHistorial = verHistorial;
      _recursoFiltro = null;
      _fechaFiltro = null;
      _todasLasReservas = verHistorial ? _reservasCompletas : _soloActivas(_reservasCompletas);
      _reservasFiltradas = List.from(_todasLasReservas);
    });
  }

  void _aplicarFiltros() {
    setState(() {
      _reservasFiltradas = _todasLasReservas.where((r) {
        // Filtro por Recurso
        bool coincideRecurso = true;
        if (_recursoFiltro != null) {
          coincideRecurso = r.recursoId == _recursoFiltro!.id;
        }

        // Filtro por Fecha (Verificamos si la fecha seleccionada cae dentro del rango de la reserva)
        bool coincideFecha = true;
        if (_fechaFiltro != null) {
          // Si es por dia: r.fechaInicio.year == _fechaFiltro.year, etc...
          // Lo más amplio es comprobar si la reserva ocurre o toca ese día.
          final checkStart = DateTime(r.fechaInicio.year, r.fechaInicio.month, r.fechaInicio.day);
          final checkEnd = DateTime(r.fechaFin.year, r.fechaFin.month, r.fechaFin.day);
          final filterDay = DateTime(_fechaFiltro!.year, _fechaFiltro!.month, _fechaFiltro!.day);

          coincideFecha = (filterDay.isAtSameMomentAs(checkStart) || filterDay.isAfter(checkStart)) &&
                          (filterDay.isAtSameMomentAs(checkEnd) || filterDay.isBefore(checkEnd));
        }

        return coincideRecurso && coincideFecha;
      }).toList();
    });
  }

  void _limpiarFiltros() {
    setState(() {
      _recursoFiltro = null;
      _fechaFiltro = null;
      _reservasFiltradas = List.from(_todasLasReservas);
    });
  }

  bool _esPasada(Reserva r) => r.fechaFin.isBefore(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context, listen: false);
    final isPresidenteOrAdmin = userProv.user?.rol == 'PRESIDENTE' || userProv.user?.rol == 'SUPER_ADMIN';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Comunidad: Todas las Reservas', style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (isPresidenteOrAdmin)
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: "Gestión de Espacios (Panel Presidente)",
              onPressed: () => context.push('/presidente'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Toggle Próximas / Historial
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: false,
                        label: Text('Próximas'),
                        icon: Icon(Icons.upcoming),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text('Historial'),
                        icon: Icon(Icons.history),
                      ),
                    ],
                    selected: {_verHistorial},
                    onSelectionChanged: (s) => _cambiarVista(s.first),
                    style: ButtonStyle(
                      iconSize: WidgetStateProperty.all(16),
                    ),
                  ),
                ),

                _buildPanelFiltros(),

                Expanded(
                  child: _reservasFiltradas.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _verHistorial ? Icons.history_toggle_off : Icons.event_available,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _verHistorial
                                    ? 'No hay reservas en el historial.'
                                    : 'No hay reservas próximas.',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _reservasFiltradas.length,
                          itemBuilder: (context, index) {
                            final reserva = _reservasFiltradas[index];
                            return _buildReservaCard(reserva);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () async {
          await context.push('/reservas/nueva');
          if (mounted) _cargarDatos();
        },
        icon: const Icon(Icons.add),
        label: const Text("Reservar Zona"),
        backgroundColor: accentColor,
      ),
    );
  }

  Widget _buildPanelFiltros() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 5,
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Recurso>(
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Espacio / Recurso',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0)
                  ),
                  initialValue: _recursoFiltro,
                  items: _recursos.map((r) => DropdownMenuItem(value: r, child: Text(r.nombre, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (val) {
                    _recursoFiltro = val;
                    _aplicarFiltros();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _fechaFiltro ?? DateTime.now(),
                      firstDate: _verHistorial
                          ? DateTime.now().subtract(const Duration(days: 365))
                          : DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 180)),
                    );
                    if (picked != null) {
                      _fechaFiltro = picked;
                      _aplicarFiltros();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_fechaFiltro == null 
                             ? 'Filtrar Día' 
                             : DateFormat('dd/MM', 'es_ES').format(_fechaFiltro!), 
                             style: TextStyle(color: _fechaFiltro == null ? Colors.grey.shade600 : Colors.black)),
                        Icon(Icons.calendar_today, size: 18, color: primaryDark),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_recursoFiltro != null || _fechaFiltro != null)
             Align(
               alignment: Alignment.centerRight,
               child: TextButton.icon(
                 onPressed: _limpiarFiltros, 
                 icon: const Icon(Icons.clear, size: 16), 
                 label: const Text('Limpiar Filtros')
               ),
             )
        ],
      ),
    );
  }

  Widget _buildReservaCard(Reserva reserva) {
    final pasada = _esPasada(reserva);
    String fechaInicioFormat = DateFormat('dd MMM yyyy, HH:mm', 'es_ES').format(reserva.fechaInicio);
    String horaFinFormat = DateFormat('HH:mm', 'es_ES').format(reserva.fechaFin);

    if (reserva.fechaInicio.day != reserva.fechaFin.day) {
      horaFinFormat = DateFormat('dd MMM yyyy', 'es_ES').format(reserva.fechaFin);
    }

    final Color espacioColor = pasada ? Colors.grey : accentColor;

    return Opacity(
      opacity: pasada ? 0.65 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 15),
        elevation: pasada ? 0 : 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Badge del espacio
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: espacioColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: espacioColor),
                    ),
                    child: Text(
                      reserva.recursoNombre ?? 'Espacio',
                      style: TextStyle(color: espacioColor, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  Row(
                    children: [
                      // Badge "Pasada" en modo historial
                      if (pasada) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Pasada',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '@${reserva.usuarioUsername}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Icon(Icons.access_time_filled, color: pasada ? Colors.grey : primaryDark, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '$fechaInicioFormat  a  $horaFinFormat',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: pasada ? Colors.grey.shade600 : Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
