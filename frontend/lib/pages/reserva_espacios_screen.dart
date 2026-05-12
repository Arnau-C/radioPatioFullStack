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
  
  // Variables de tiempo
  DateTime _fechaSeleccionada = DateTime.now();
  int? _horaInicioSeleccionada;
  int _duracionSeleccionada = 1; // Por defecto 1 hora

  List<Reserva> _reservasExistentes = [];
  bool _isLoadingReservas = false;

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
          _horaInicioSeleccionada = null; // Reiniciar selección al cambiar recurso
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
      _horaInicioSeleccionada = null;
      _duracionSeleccionada = 1;
    });
    _cargarReservasRecurso(rec.id);
  }

  // --- NUEVA LÓGICA: LÍMITE DIARIO POR USUARIO ---
  int _calcularHorasRestantesUsuarioHoy() {
    final username = Provider.of<UserProvider>(context, listen: false).user?.username;
    if (username == null || _recursoSeleccionado == null) return 0;
    
    int horasConsumidasHoy = 0;
    
    for (var r in _reservasExistentes) {
      // Si la reserva es de este usuario Y es del mismo día que ha seleccionado
      if (r.usuarioUsername == username && DateUtils.isSameDay(r.fechaInicio, _fechaSeleccionada)) {
        // Sumamos las horas que dura esa reserva
        horasConsumidasHoy += r.fechaFin.difference(r.fechaInicio).inHours;
      }
    }
    
    int restante = _recursoSeleccionado!.maxHorasReserva - horasConsumidasHoy;
    return restante > 0 ? restante : 0;
  }

  // Comprueba si un bloque de 1 hora exacto está ocupado por CUALQUIER persona
  bool _estaHoraOcupada(DateTime horaAComprobar) {
    for (var r in _reservasExistentes) {
      if ((horaAComprobar.isAtSameMomentAs(r.fechaInicio) || horaAComprobar.isAfter(r.fechaInicio)) &&
          horaAComprobar.isBefore(r.fechaFin)) {
        return true;
      }
    }
    return false;
  }

  // Calcula cuántas horas SEGUIDAS puede reservar combinando su límite diario y los huecos libres
  int _calcularHorasDisponiblesDesde(int horaInicio) {
    int limiteRestante = _calcularHorasRestantesUsuarioHoy();
    if (limiteRestante <= 0) return 1; // Fallback por seguridad

    int horasPosibles = 0;

    for (int i = 0; i < limiteRestante; i++) {
      int horaAComprobar = horaInicio + i;
      if (horaAComprobar >= 23) break; // El límite de cierre son las 23:00

      DateTime slot = DateTime(_fechaSeleccionada.year, _fechaSeleccionada.month, _fechaSeleccionada.day, horaAComprobar);
      
      if (_estaHoraOcupada(slot)) {
        break; // Si choca con otra persona, cortamos ahí
      }
      horasPosibles++;
    }
    return horasPosibles == 0 ? 1 : horasPosibles;
  }

  Future<void> _realizarReserva() async {
    if (_horaInicioSeleccionada == null) return;

    DateTime fechaInicio = DateTime(_fechaSeleccionada.year, _fechaSeleccionada.month, _fechaSeleccionada.day, _horaInicioSeleccionada!);
    DateTime fechaFin = fechaInicio.add(Duration(hours: _duracionSeleccionada));

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final token = userProvider.token;
    final username = userProvider.user?.username;

    if (token == null || username == null || _recursoSeleccionado == null) return;

    try {
      final nuevaReserva = Reserva(
        recursoId: _recursoSeleccionado!.id,
        usuarioUsername: username,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );

      await _reservaService.crearReserva(nuevaReserva, token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Reserva confirmada! 🎉'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
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
            const Text("1. Selecciona el espacio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
            const SizedBox(height: 10),
            DropdownButtonFormField<Recurso>(
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)), filled: true, fillColor: Colors.white),
              hint: const Text('Ej: Pista de Pádel'),
              value: _recursoSeleccionado,
              items: _recursos.map((r) => DropdownMenuItem(value: r, child: Text(r.nombre))).toList(),
              onChanged: _onRecursoChanged,
            ),
            const SizedBox(height: 30),

            if (_recursoSeleccionado != null && _isLoadingReservas)
              const Center(child: CircularProgressIndicator())
            else if (_recursoSeleccionado != null)
              _buildFormularioReservas(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormularioReservas() {
    int horasRestantesUsuario = _calcularHorasRestantesUsuarioHoy();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("2. Selecciona el Día", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
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
              setState(() {
                _fechaSeleccionada = picked;
                _horaInicioSeleccionada = null; // Quitar hora al cambiar de día
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(10), color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(_fechaSeleccionada), style: const TextStyle(fontSize: 16)),
                Icon(Icons.calendar_month, color: primaryDark),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // CARTEL INFORMATIVO DEL LÍMITE DIARIO
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: horasRestantesUsuario > 0 ? Colors.blue.shade50 : Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: horasRestantesUsuario > 0 ? Colors.blue.shade200 : Colors.orange.shade300)
          ),
          child: Row(
            children: [
              Icon(horasRestantesUsuario > 0 ? Icons.info_outline : Icons.warning_amber_rounded, color: horasRestantesUsuario > 0 ? Colors.blue : Colors.orange.shade800),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Límite de ${_recursoSeleccionado!.maxHorasReserva} horas al día.\n'
                  '${horasRestantesUsuario > 0 ? 'Te quedan $horasRestantesUsuario horas disponibles hoy.' : 'Ya has agotado todas tus horas para este día.'}',
                  style: TextStyle(color: horasRestantesUsuario > 0 ? Colors.blue.shade900 : Colors.orange.shade900, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        const Text("3. Selecciona la Hora de Inicio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
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
            bool isSelected = _horaInicioSeleccionada == hora;

            Color bgColor = isSelected ? primaryDark : (isAvailable ? Colors.green.shade100 : Colors.grey.shade300);
            Color textColor = isSelected ? Colors.white : (isAvailable ? Colors.green.shade900 : Colors.grey.shade600);
            String estado = isOccupied ? 'Ocupado' : (isPast ? 'Pasado' : 'Libre');
            if (isSelected) estado = 'Elegido';

            return Material(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              elevation: isSelected ? 4 : 0,
              child: InkWell(
                onTap: isAvailable ? () {
                  if (horasRestantesUsuario <= 0) {
                    // Si ya no le quedan horas, le soltamos un aviso y no le dejamos pintar el botón de azul
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ya has agotado tu límite diario para este espacio.'), backgroundColor: Colors.orange)
                    );
                    return;
                  }
                  setState(() {
                    _horaInicioSeleccionada = hora;
                    _duracionSeleccionada = 1; // Reseteamos a 1h al tocar una nueva hora
                  });
                } : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: isSelected ? Border.all(color: accentColor, width: 2) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text('$hora:00', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                      Text(estado, style: TextStyle(fontSize: 10, color: textColor, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
        
        // SELECTOR DE DURACIÓN Y BOTÓN (Solo aparece si se ha tocado una hora libre y le quedan horas en el día)
        if (_horaInicioSeleccionada != null && horasRestantesUsuario > 0) ...[
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.blue.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("4. Duración de la reserva", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey)),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  value: _duracionSeleccionada,
                  items: List.generate(
                    _calcularHorasDisponiblesDesde(_horaInicioSeleccionada!),
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text(index + 1 == 1 ? '1 hora (hasta las ${_horaInicioSeleccionada! + 1}:00)' : '${index + 1} horas (hasta las ${_horaInicioSeleccionada! + index + 1}:00)'),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => _duracionSeleccionada = val!);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _realizarReserva,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 5,
                    ),
                    child: const Text('CONFIRMAR RESERVA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          )
        ]
      ],
    );
  }
}