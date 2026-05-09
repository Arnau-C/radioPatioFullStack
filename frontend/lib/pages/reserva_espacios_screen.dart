import 'package:flutter/material.dart';
import 'package:frontend/models/recurso.dart';
import 'package:frontend/models/reserva.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/services/recurso_service.dart';
import 'package:frontend/services/reserva_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ReservaEspaciosScreen extends StatefulWidget {
  final int comunidadId;
  const ReservaEspaciosScreen({super.key, required this.comunidadId});

  @override
  State<ReservaEspaciosScreen> createState() => _ReservaEspaciosScreenState();
}

class _ReservaEspaciosScreenState extends State<ReservaEspaciosScreen> {
  final RecursoService _recursoService = RecursoService();
  final ReservaService _reservaService = ReservaService();

  List<Recurso> _recursos = [];
  bool _isLoadingRecursos = true;

  Recurso? _recursoSeleccionado;
  
  // Para reservas POR_HORAS
  DateTime _fechaSeleccionada = DateTime.now();
  List<Reserva> _reservasExistentes = [];
  bool _isLoadingReservas = false;

  // Para reservas POR_DIAS
  DateTime? _fechaInicioSeleccionada;
  DateTime? _fechaFinSeleccionada;

  final Color primaryDark = const Color(0xFF1A365D);
  final Color accentColor = const Color(0xFFE27D60);

  @override
  void initState() {
    super.initState();
    _cargarRecursos();
  }

  Future<void> _cargarRecursos() async {
    final token = Provider.of<UserProvider>(context, listen: false).token;
    if (token == null) return;
    try {
      final res = await _recursoService.obtenerRecursos(widget.comunidadId, token);
      if (mounted) {
        setState(() {
          _recursos = res;
          _isLoadingRecursos = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingRecursos = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error cargando espacios')));
      }
    }
  }

  Future<void> _cargarReservasRecurso(int recursoId) async {
    final token = Provider.of<UserProvider>(context, listen: false).token;
    if (token == null) return;
    setState(() => _isLoadingReservas = true);
    try {
      final res = await _reservaService.obtenerReservasPorRecurso(recursoId, token);
      if (mounted) {
        setState(() {
          _reservasExistentes = res;
          _isLoadingReservas = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingReservas = false);
      }
    }
  }

  void _onRecursoChanged(Recurso? rec) {
    if (rec == null) return;
    setState(() {
      _recursoSeleccionado = rec;
      _fechaInicioSeleccionada = null;
      _fechaFinSeleccionada = null;
    });
    _cargarReservasRecurso(rec.id);
  }

  bool _estaHoraOcupada(DateTime horaAComprobar) {
    for (var r in _reservasExistentes) {
      // Si la hora a comprobar está entre el inicio (incluido) y el fin (excluido) de alguna reserva
      if ((horaAComprobar.isAtSameMomentAs(r.fechaInicio) || horaAComprobar.isAfter(r.fechaInicio)) &&
          horaAComprobar.isBefore(r.fechaFin)) {
        return true;
      }
    }
    return false;
  }

  bool _estanDiasOcupados(DateTime inicio, DateTime fin) {
    for (var r in _reservasExistentes) {
      // Si hay solapamiento: inicio1 < fin2 && fin1 > inicio2
      if (inicio.isBefore(r.fechaFin) && fin.isAfter(r.fechaInicio)) {
        return true;
      }
    }
    return false;
  }

  Future<void> _realizarReserva(DateTime inicio, DateTime fin) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;
    final username = userProvider.user?.username;

    if (token == null || username == null || _recursoSeleccionado == null) return;

    try {
      final nuevaReserva = Reserva(
        recursoId: _recursoSeleccionado!.id,
        usuarioUsername: username,
        fechaInicio: inicio,
        fechaFin: fin,
      );

      await _reservaService.crearReserva(nuevaReserva, token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Reserva confirmada!'), backgroundColor: Colors.green));
        Navigator.pop(context); // Volver al home screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e is ReservaException ? e.message : 'Error desconocido'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingRecursos) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reservar Espacio')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservar Espacio', style: TextStyle(color: Colors.white)),
        backgroundColor: primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("1. Selecciona el espacio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            DropdownButtonFormField<Recurso>(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              hint: const Text('Ej: Pista de Pádel'),
              value: _recursoSeleccionado,
              items: _recursos.map((r) => DropdownMenuItem(value: r, child: Text(r.nombre))).toList(),
              onChanged: _onRecursoChanged,
            ),
            const SizedBox(height: 30),

            if (_recursoSeleccionado != null && _isLoadingReservas)
              const Center(child: CircularProgressIndicator())
            else if (_recursoSeleccionado != null)
              _buildFormularioParaRecurso(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioParaRecurso() {
    bool porHoras = _recursoSeleccionado!.tipoReserva == 'POR_HORAS';
    return porHoras ? _buildFormularioPorHoras() : _buildFormularioPorDias();
  }

  Widget _buildFormularioPorHoras() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("2. Selecciona el Día", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _fechaSeleccionada,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
            );
            if (picked != null) {
              setState(() => _fechaSeleccionada = picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(_fechaSeleccionada), style: const TextStyle(fontSize: 16)),
                Icon(Icons.calendar_month, color: primaryDark),
              ],
            ),
          ),
        ),
        const SizedBox(height: 30),
        const Text("3. Selecciona la Hora (Tramos de 1 hora)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(14, (index) { // Desde las 09:00 hasta las 22:00
            int hora = index + 9;
            DateTime timeSlot = DateTime(_fechaSeleccionada.year, _fechaSeleccionada.month, _fechaSeleccionada.day, hora);
            bool isPast = timeSlot.isBefore(DateTime.now());
            bool isOccupied = _estaHoraOcupada(timeSlot);
            bool isAvailable = !isPast && !isOccupied;

            return Material(
              color: isAvailable ? Colors.green.shade100 : Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: isAvailable ? () {
                  _realizarReserva(timeSlot, timeSlot.add(const Duration(hours: 1)));
                } : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Text('$hora:00', style: TextStyle(fontWeight: FontWeight.bold, color: isAvailable ? Colors.green.shade900 : Colors.red.shade900)),
                      Text(isOccupied ? 'Ocupado' : (isPast ? 'Pasado' : 'Libre'), style: TextStyle(fontSize: 10, color: isAvailable ? Colors.green.shade700 : Colors.red.shade700)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFormularioPorDias() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("2. Selecciona Fecha de Inicio y Fin", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          icon: const Icon(Icons.date_range),
          label: Text(_fechaInicioSeleccionada == null ? 'Seleccionar Rango de Días' : '${DateFormat('dd/MM').format(_fechaInicioSeleccionada!)}  al  ${DateFormat('dd/MM').format(_fechaFinSeleccionada!)}'),
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 90)),
            );
            if (picked != null) {
              if (_estanDiasOcupados(picked.start, picked.end)) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hay fechas ocupadas en ese rango.'), backgroundColor: Colors.red));
              } else {
                setState(() {
                  _fechaInicioSeleccionada = picked.start;
                  // Si el usuario selecciona del 1 al 2, eso debe cubrir todo el 2, por lo que el fin es el día 3 a las 00:00
                  _fechaFinSeleccionada = picked.end.add(const Duration(days: 1)); 
                });
              }
            }
          },
        ),
        const SizedBox(height: 30),
        if (_fechaInicioSeleccionada != null)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => _realizarReserva(_fechaInicioSeleccionada!, _fechaFinSeleccionada!),
              style: ElevatedButton.styleFrom(backgroundColor: primaryDark, foregroundColor: Colors.white),
              child: const Text('CONFIRMAR RESERVA DE DÍAS'),
            ),
          )
      ],
    );
  }
}
