import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/models/votacion.dart';
import 'package:frontend/services/votacion_service.dart';

class VotacionDetalleScreen extends StatefulWidget {
  final int votacionId;
  final String token;
  final bool isPresidente;

  const VotacionDetalleScreen({
    super.key,
    required this.votacionId,
    required this.token,
    required this.isPresidente,
  });

  @override
  State<VotacionDetalleScreen> createState() => _VotacionDetalleScreenState();
}

class _VotacionDetalleScreenState extends State<VotacionDetalleScreen> {
  final VotacionService _service = VotacionService();
  VotacionDetalle? _votacion;
  bool _isLoading = true;
  bool _isVoting = false;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  // Carga inicial con spinner
  Future<void> _cargar() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final v =
          await _service.obtenerDetalle(widget.votacionId, widget.token);
      if (!mounted) return;
      setState(() {
        _votacion = v;
        _isLoading = false;
      });
      if (v.estaAbierta) _iniciarPolling();
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _iniciarPolling() {
    _pollingTimer?.cancel();
    _pollingTimer =
        Timer.periodic(const Duration(seconds: 4), (_) => _refrescar());
  }

  // Refresco silencioso — no muestra spinner, actualiza los números en segundo plano
  Future<void> _refrescar() async {
    if (!mounted) return;
    try {
      final v =
          await _service.obtenerDetalle(widget.votacionId, widget.token);
      if (!mounted) return;
      setState(() => _votacion = v);
      if (!v.estaAbierta) _pollingTimer?.cancel();
    } catch (_) {
      // Fallo silencioso: se mantienen los datos anteriores
    }
  }

  Future<void> _votar(int opcionId) async {
    if (_isVoting) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _isVoting = true);
    try {
      final updated =
          await _service.emitirVoto(widget.votacionId, opcionId, widget.token);
      if (!mounted) return;
      setState(() {
        _votacion = updated;
        _isVoting = false;
      });
    } on VotacionException catch (e) {
      if (!mounted) return;
      setState(() => _isVoting = false);
      messenger.showSnackBar(SnackBar(
          content: Text(e.message), backgroundColor: AppColors.error));
    }
  }

  Future<void> _cerrarVotacion() async {
    final messenger = ScaffoldMessenger.of(context);
    // Pedir confirmación antes de cerrar
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Cerrar la votación?'),
        content: const Text(
            'Una vez cerrada, los vecinos ya no podrán votar y los resultados serán definitivos.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white),
            child: const Text('Cerrar votación'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final updated =
          await _service.cerrarVotacion(widget.votacionId, widget.token);
      if (!mounted) return;
      _pollingTimer?.cancel();
      setState(() => _votacion = updated);
      messenger.showSnackBar(const SnackBar(
          content: Text('Votación cerrada. Resultados definitivos.'),
          backgroundColor: AppColors.success));
    } on VotacionException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
          content: Text(e.message), backgroundColor: AppColors.error));
    }
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _votacion == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryDark,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final v = _votacion!;
    final esCerrada = !v.estaAbierta;
    final puedeVotar = !v.yaVotado && v.estaAbierta;
    final canClose = widget.isPresidente && v.estaAbierta;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(v.titulo,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 17)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildStatusChip(v.estado, esCerrada),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Descripción
            if (v.descripcion != null && v.descripcion!.isNotEmpty) ...[
              Text(v.descripcion!,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 15)),
              const SizedBox(height: 16),
            ],

            // Meta: total votos + creador
            Wrap(
              spacing: 16,
              children: [
                _metaItem(Icons.people_outline,
                    '${v.totalVotos} ${v.totalVotos == 1 ? "voto" : "votos"}'),
                _metaItem(Icons.person_outline, '@${v.creadorUsername}'),
                if (v.fechaLimite != null)
                  _metaItem(
                    Icons.event_outlined,
                    'Cierra el ${v.fechaLimite!.day}/${v.fechaLimite!.month}/${v.fechaLimite!.year}',
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Instrucción
            if (puedeVotar) ...[
              const Text('Selecciona una opción para votar:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 12),
            ] else if (v.yaVotado && v.estaAbierta) ...[
              Row(children: [
                const Icon(Icons.check_circle,
                    size: 16, color: AppColors.success),
                const SizedBox(width: 6),
                const Text('Tu voto ha sido registrado.',
                    style: TextStyle(color: AppColors.success, fontSize: 14)),
              ]),
              const SizedBox(height: 12),
            ],

            // Opciones
            ...v.opciones.map((o) => _buildOpcion(o, v, puedeVotar)),

            // Indicador de polling
            if (v.estaAbierta) ...[
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync, size: 13, color: AppColors.textHint),
                    const SizedBox(width: 4),
                    const Text('Resultados en tiempo real · actualización cada 4s',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textHint)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: canClose
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: _cerrarVotacion,
              icon: const Icon(Icons.lock_outline),
              label: const Text('Cerrar votación'),
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildOpcion(
      OpcionDetalle opcion, VotacionDetalle v, bool puedeVotar) {
    final esVotada = v.opcionVotadaId == opcion.id;
    final mostrarBarra = v.yaVotado || !v.estaAbierta;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: esVotada
            ? AppColors.primaryDark.withValues(alpha: 0.07)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: esVotada
              ? AppColors.primaryDark
              : Colors.grey.shade200,
          width: esVotada ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: (puedeVotar && !_isVoting) ? () => _votar(opcion.id) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icono de selección / resultado
                  if (puedeVotar) ...[
                    Icon(
                      Icons.radio_button_unchecked,
                      size: 20,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 10),
                  ] else if (esVotada) ...[
                    const Icon(Icons.check_circle,
                        size: 20, color: AppColors.primaryDark),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      opcion.texto,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            esVotada ? FontWeight.bold : FontWeight.normal,
                        color: esVotada
                            ? AppColors.primaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  // Porcentaje (solo si hay resultados visibles)
                  if (mostrarBarra)
                    Text(
                      '${opcion.porcentaje.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: esVotada
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              // Barra de progreso
              if (mostrarBarra) ...[
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: (opcion.porcentaje / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    esVotada
                        ? AppColors.primaryDark
                        : AppColors.accent.withValues(alpha: 0.65),
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 6),
                Text(
                  '${opcion.votos} ${opcion.votos == 1 ? "voto" : "votos"}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textHint),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String estado, bool esCerrada) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white54),
      ),
      child: Text(
        esCerrada ? 'Cerrada' : 'Abierta',
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
      ),
    );
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(text,
            style:
                const TextStyle(fontSize: 12, color: AppColors.textHint)),
      ],
    );
  }
}
