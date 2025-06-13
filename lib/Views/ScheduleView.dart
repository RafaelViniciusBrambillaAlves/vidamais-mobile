import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidamais/Providers/AuthProvider.dart';
import 'package:vidamais/Providers/LaborProvider.dart';
import 'package:vidamais/Views/PreSchedulingView.dart';
import 'package:vidamais/models/Schedule.dart';
import 'package:vidamais/Providers/ScheduleProvider.dart';

class ScheduleView extends StatefulWidget {
  const ScheduleView({Key? key}) : super(key: key);

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  List<Schedule> _schedules = [];
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchedules();
    });
  }

  Future<void> _loadSchedules() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final laborProvider = context.read<LaborProvider>();

      if (laborProvider.selectedLabor == null) {
        setState(() => _isLoading = false);
        return;
      } 
      
      final schedules = await laborProvider.loadUserSchedules(
        int.parse(authProvider.userId!),
        laborProvider.selectedLabor!.id,
      );

      setState(() {
        _schedules = schedules;
        _isLoading = false;
      });

    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await _loadSchedules();
  }

  String _formatDate(DateTime date) {
    final d = date.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _cancelSchedule(int scheduleId, int index) async {
    try {
      final laborProvider = context.read<LaborProvider>();
      await laborProvider.cancelSchedule(scheduleId);
      
      // Dispara o refresh automático
      _refreshIndicatorKey.currentState?.show();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agendamento cancelado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao cancelar: $e')),
      );
    }
  }

  Future<void> _showCancelDialog(int scheduleId, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancelar Agendamento'),
          content: const Text('Tem certeza que deseja cancelar este agendamento?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Não'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Sim'),
              onPressed: () {
                Navigator.of(context).pop();
                _cancelSchedule(scheduleId, index);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (scheduleProvider.error != null) {
      return Center(child: Text('Erro: ${scheduleProvider.error}'));
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _handleRefresh,
              child: _buildScheduleList(),
            ),
          ),
          _buildPreAgendamento(),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    if (_schedules.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: const Center(
              child: Text(
                'Nenhum agendamento disponível.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: _schedules.length,
      itemBuilder: (context, index) {
        final schedule = _schedules[index];
        final isCanceled = schedule.status.toLowerCase() == 'cancelado';
        final isRealizado = schedule.status.toLowerCase() == 'realizado';
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: isCanceled 
            ? Colors.grey[300] : 
            isRealizado
              ? Colors.green[50] 
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: ExpansionTile(
            leading: Icon(
              Icons.calendar_today,
              color: isCanceled ? Colors.grey : null,
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Data: ${_formatDate(schedule.date)}',
                  style: TextStyle(
                    color: isCanceled ? Colors.grey : null,
                    decoration: isCanceled ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Unidade: ${schedule.unit?.address ?? "Unidade não informada"}',
                  style: TextStyle(
                    color: isCanceled ? Colors.grey : null,
                  ),
                ),
                if (isCanceled || isRealizado) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${isCanceled ? 'Cancelado' : 'Realizado'}',
                    style: TextStyle(
                      color: isCanceled ? Colors.red[700] : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              ...schedule.exams.map((exam) {
                return ListTile(
                  leading: Icon(
                    Icons.biotech,
                    color: isCanceled ? Colors.grey : null,
                  ),
                  title: Text(
                    exam.name ?? 'Exame sem nome',
                    style: TextStyle(
                      color: isCanceled ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text(
                    exam.description ?? '',
                    style: TextStyle(
                      color: isCanceled ? Colors.grey : null,
                    ),
                  ),
                );
              }).toList(),
              
              if (!isCanceled && !isRealizado) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        label: const Text('Cancelar Agendamento'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: () => _showCancelDialog(schedule.id!, index),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            trailing: Icon(
              Icons.expand_more,
              color: isCanceled ? Colors.grey : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreAgendamento() {
    return Column(
      children: [
        const Divider(),
        ListTile(
          leading: const Icon(Icons.add_circle),
          title: const Text('Novo Pré-Agendamento'),
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PreSchedulingScreen(),
              ),
            );
            
            // Se um novo agendamento foi feito, atualiza a lista
            if (result == true) {
              _refreshIndicatorKey.currentState?.show();
            }
          },
        ),
      ],
    );
  }
}