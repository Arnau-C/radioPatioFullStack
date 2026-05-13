import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/models/votacion.dart';
import 'package:frontend/services/votacion_service.dart';

class VotacionesScreen extends StatefulWidget {
  final int comunidadId;
  final String token;
  final bool isPresidente;

  const VotacionesScreen({
    super.key,
    required this.comunidadId,
    required this.token,
    required this.isPresidente,
  });

  @override
  State<VotacionesScreen> createState() => _VotacionesScreenState();
}

class _VotacionesScreenState extends State<VotacionesScreen> {
  final VotacionService _service = VotacionService();
  List<VotacionDetalle> _votaciones = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result =
          await _service.listarVotaciones(widget.comunidadId, widget.token);
      if (!mounted) return;
      setState(() {
        _votaciones = result;
        _isLoading = false;
      });
    } on VotacionException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar las votaciones.';
        _isLoading = false;
      });
    }
  }

  // =========================================================================
  // DIÁLOGO CREAR VOTACIÓN
  // =========================================================================

  void _mostrarDialogoCrear() {
    final messenger = ScaffoldMessenger.of(context);
    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final opcionCtrls = <TextEditingController>[
      TextEditingController(),
      TextEditingController(),
    ];
    DateTime? fechaLimite;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => StatefulBuilder(
        builder: (BuildContext dialogContext, setDialogState) {
          final dialogNav = Navigator.of(dialogContext);
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.how_to_vote, color: AppColors.primaryDark),
                const SizedBox(width: 10),
                const Text('Nueva Votación'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: tituloCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Título *',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 150,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  const Text('Opciones',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...opcionCtrls.asMap().entries.map((entry) {
                    final i = entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: entry.value,
                              decoration: InputDecoration(
                                labelText: 'Opción ${i + 1}',
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                          if (opcionCtrls.length > 2)
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: AppColors.error),
                              tooltip: 'Eliminar opción',
                              onPressed: () =>
                                  setDialogState(() => opcionCtrls.removeAt(i)),
                            ),
                        ],
                      ),
                    );
                  }),
                  if (opcionCtrls.length < 6)
                    TextButton.icon(
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Añadir opción'),
                      onPressed: () => setDialogState(
                          () => opcionCtrls.add(TextEditingController())),
                    ),
                  const Divider(height: 24),
                  // Fecha límite opcional
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: dialogContext,
                        initialDate:
                            DateTime.now().add(const Duration(days: 7)),
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setDialogState(() => fechaLimite = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.event_outlined,
                              size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fechaLimite == null
                                  ? 'Fecha límite (opcional)'
                                  : 'Cierra el ${fechaLimite!.day}/${fechaLimite!.month}/${fechaLimite!.year}',
                              style: TextStyle(
                                color: fechaLimite == null
                                    ? AppColors.textHint
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (fechaLimite != null)
                            GestureDetector(
                              onTap: () =>
                                  setDialogState(() => fechaLimite = null),
                              child: const Icon(Icons.clear,
                                  size: 16, color: AppColors.textHint),
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
                onPressed: () => dialogNav.pop(),
                child: const Text('Cancelar',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () async {
                  final titulo = tituloCtrl.text.trim();
                  if (titulo.isEmpty) {
                    messenger.showSnackBar(const SnackBar(
                        content: Text('El título es obligatorio.')));
                    return;
                  }
                  final opciones = opcionCtrls
                      .map((c) => c.text.trim())
                      .where((t) => t.isNotEmpty)
                      .toList();
                  if (opciones.length < 2) {
                    messenger.showSnackBar(const SnackBar(
                        content: Text('Necesitas al menos 2 opciones.')));
                    return;
                  }
                  dialogNav.pop();
                  try {
                    await _service.crearVotacion(
                      comunidadId: widget.comunidadId,
                      titulo: titulo,
                      descripcion: descCtrl.text.trim().isEmpty
                          ? null
                          : descCtrl.text.trim(),
                      opciones: opciones,
                      fechaLimite: fechaLimite,
                      token: widget.token,
                    );
                    _cargar();
                  } on VotacionException catch (e) {
                    messenger.showSnackBar(SnackBar(
                        content: Text(e.message),
                        backgroundColor: AppColors.error));
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white),
                child: const Text('CREAR'),
              ),
            ],
          );
        },
      ),
    );
  }

  // =========================================================================
  // BUILD
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Votaciones',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: AppColors.primaryDark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _votaciones.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _cargar,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _votaciones.length,
                        itemBuilder: (ctx, i) => _buildCard(_votaciones[i]),
                      ),
                    ),
      floatingActionButton: widget.isPresidente
          ? FloatingActionButton.extended(
              heroTag: null,
              onPressed: _mostrarDialogoCrear,
              icon: const Icon(Icons.how_to_vote),
              label: const Text('Nueva Votación'),
              backgroundColor: AppColors.primaryDark,
            )
          : null,
    );
  }

  Widget _buildCard(VotacionDetalle v) {
    final esCerrada = !v.estaAbierta;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await context.push('/votaciones/${v.id}');
          if (mounted) _cargar();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Estado + votos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatusChip(v.estado, esCerrada),
                  Text(
                    '${v.totalVotos} ${v.totalVotos == 1 ? "voto" : "votos"}',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Título
              Text(v.titulo,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              // Descripción
              if (v.descripcion != null && v.descripcion!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(v.descripcion!,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 12),
              // Footer: estado del voto del usuario
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (v.yaVotado)
                    const Row(children: [
                      Icon(Icons.check_circle,
                          size: 15, color: AppColors.success),
                      SizedBox(width: 4),
                      Text('Ya has votado',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w600)),
                    ])
                  else if (v.estaAbierta)
                    const Text('Toca para votar',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.info))
                  else
                    const Text('Ver resultados',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textHint)),
                  const Icon(Icons.chevron_right,
                      color: AppColors.textHint),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String estado, bool esCerrada) {
    final color = esCerrada ? AppColors.textSecondary : AppColors.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        esCerrada ? 'Cerrada' : 'Abierta',
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.how_to_vote_outlined,
              size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text('No hay votaciones aún.',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 15)),
          if (widget.isPresidente) ...[
            const SizedBox(height: 8),
            const Text('Crea la primera con el botón +',
                style: TextStyle(
                    color: AppColors.textHint, fontSize: 13)),
          ],
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 12),
          Text(_error!,
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _cargar,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
