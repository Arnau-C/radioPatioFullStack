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

  List<Reserva> _todasLasReservas = [];
  List<Reserva> _reservasFiltradas = [];
  List<Recurso> _recursos = [];

  bool _isLoading = true;

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
          _todasLasReservas = _limpiarReservasPasadas(reservas);
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

  // Si queremos mostrar solo las activas a futuro (opcional, aunque es mejor experiencia)
  List<Reserva> _limpiarReservasPasadas(List<Reserva> reservas) {
    final now = DateTime.now();
    return reservas.where((r) => r.estado == 'ACTIVA' && r.fechaFin.isAfter(now)).toList();
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
                _buildPanelFiltros(),
                Expanded(
                  child: _reservasFiltradas.isEmpty
                      ? const Center(child: Text('No hay reservas próximas en este espacio/día.'))
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
        onPressed: () => context.push('/reservas/nueva'),
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
                  value: _recursoFiltro,
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
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
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
    String fechaInicioFormat = DateFormat('dd MMM yyyy, HH:mm', 'es_ES').format(reserva.fechaInicio);
    String horaFinFormat = DateFormat('HH:mm', 'es_ES').format(reserva.fechaFin);
    
    // Si la reserva dura varios dias
    if (reserva.fechaInicio.day != reserva.fechaFin.day) {
      horaFinFormat = DateFormat('dd MMM yyyy', 'es_ES').format(reserva.fechaFin);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: accentColor)
                  ),
                  child: Text(
                    reserva.recursoNombre ?? 'Espacio',
                    style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Text(
                  '@${reserva.usuarioUsername}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                )
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Icon(Icons.access_time_filled, color: primaryDark, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$fechaInicioFormat  a  $horaFinFormat',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
