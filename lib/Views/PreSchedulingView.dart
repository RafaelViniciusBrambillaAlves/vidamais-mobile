import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:vidamais/Providers/AuthProvider.dart';
import 'package:vidamais/Providers/LaborProvider.dart';
import 'package:vidamais/Services/LaborService.dart';
import 'package:vidamais/models/Schedule.dart';
import 'package:vidamais/models/Unit.dart';

class PreSchedulingScreen extends StatefulWidget {
  const PreSchedulingScreen({super.key});

  @override
  State<PreSchedulingScreen> createState() => _PreSchedulingScreenState();
}

class _PreSchedulingScreenState extends State<PreSchedulingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final List<String> _selectedExams = [];

  late LaborService laborService;
  late AuthProvider authProvider;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _toggleExam(String examId) {
    setState(() {
      if (_selectedExams.contains(examId)) {
        _selectedExams.remove(examId);
      } else {
        _selectedExams.add(examId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final laboratorio = context.watch<LaborProvider>().selectedLabor;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Pré-Agendamento')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildLaboratorioInfo(),
              const SizedBox(height: 20),
              const Text('Exames Disponíveis:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...laboratorio?.exams.map((exam) => CheckboxListTile(
                title: Text(exam.name),
                value: _selectedExams.contains(exam.id.toString()),
                onChanged: (_) => _toggleExam(exam.id.toString()),
              )) ?? [],

              // Seção de Data/Horário
              const SizedBox(height: 20),
              const Text('Data e Horário:', 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Data',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () => _selectDate(context),
                        ),
                      ),
                      controller: TextEditingController(
                        text: _selectedDate != null 
                            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                            : 'Selecione uma data',
                      ),
                      validator: (value) {
                        if (_selectedDate == null) return 'Selecione uma data';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Horário',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () => _selectTime(context),
                        ),
                      ),
                      controller: TextEditingController(
                        text: _selectedTime != null 
                            ? _selectedTime!.format(context)
                            : 'Selecione um horário',
                      ),
                      validator: (value) {
                        if (_selectedTime == null) return 'Selecione um horário';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              // Botão de Confirmação
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: const Text('Confirmar Agendamento'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _selectedUnidade;

  // Adicione este método para construir o dropdown
  Widget _buildUnidadeDropdown() {
    final laboratorio = context.watch<LaborProvider>().selectedLabor;

    return DropdownButtonFormField<String>(
      value: _selectedUnidade,
      decoration: const InputDecoration(
        labelText: 'Selecione a Unidade',
        border: OutlineInputBorder(),
      ),
      items: laboratorio?.units?.map((unidade) {
        return DropdownMenuItem<String>(
          value: unidade.id.toString(),
          child: Text(unidade.name),
        );
      }).toList() ?? [],
      onChanged: (value) => setState(() => _selectedUnidade = value),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Selecione uma unidade';
        return null;
      },
    );
  }

  // Modifique o Card de informações para incluir o dropdown
  Widget _buildLaboratorioInfo() {
    final laboratorio = Provider.of<LaborProvider>(context).selectedLabor;
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(laboratorio?.name ?? 'Laboratório não selecionado',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                _buildUnidadeDropdown(), // Substituiu o Text fixo
              ],
            ),
          ),
        ),
        if (_selectedUnidade != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Endereço: ${_getEnderecoUnidade(_selectedUnidade!)}',
                style: Theme.of(context).textTheme.bodySmall),
          ),
      ],
    );
  }

  // Método auxiliar para obter endereço (adicione sua lógica real)
  String _getEnderecoUnidade(String unidade) {
    // Exemplo básico - implemente com seus dados reais
    final enderecos = {
      'Centro': 'Rua Principal, 123 - Centro',
      'Zona Norte': 'Av. Secundária, 456 - Zona Norte',
    };
    return enderecos[unidade] ?? 'Endereço não disponível';
  }

  // void _submit() async {
  //   if (_formKey.currentState!.validate()) {
  //     if (_selectedExams.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Selecione pelo menos um exame')),
  //       );
  //       return;
  //     }
  //     await laborService.createSchedule(Schedule(date: date, exams: exams, ));
      
  //     Navigator.pop(context);
  //   }
  // }

  void _submit() async {
    final laborProvider = Provider.of<LaborProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (_formKey.currentState!.validate()) {
      if (_selectedExams.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione pelo menos um exame')),
        );
        return;
      }

      // Verifica se uma unidade foi selecionada
      if (_selectedUnidade == null || _selectedUnidade!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione uma unidade')),
        );
        return;
      }

      final laboratorio = context.read<LaborProvider>().selectedLabor;
      final examsSelecionados = laboratorio?.exams
          .where((exam) => _selectedExams.contains(exam.id.toString()))
          .toList() ?? [];
      
      final unitSelected = laboratorio?.units.firstWhere(
        (u) => u.id.toString() == _selectedUnidade,
      );
      print(unitSelected);
      final DateTime date = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Cria o objeto de agendamento com o unitId
      final schedule = Schedule(
        id: 0,
        date: date,
        status: 'pendente',
        confirmCode: 'ABC123',
        exams: examsSelecionados,
        createdAt: DateTime.now(),
        unit: unitSelected,
      );

      try {
        await laborProvider.createSchedule(
          int.parse(authProvider.userId!),
          schedule
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar agendamento: $e')),
        );
      }
    }
  }
}