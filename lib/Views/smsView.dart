import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import 'package:vidamais/Services/AuthService.dart';
import 'package:vidamais/Providers/AuthProvider.dart';

class SmsView extends StatefulWidget {
  const SmsView({super.key});

  @override
  State<SmsView> createState() => SmsViewState();
}

class SmsViewState extends State<SmsView> {
  late final AuthService authService;
  late final AuthProvider authProvider;
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  int _countdown = 164;
  late Timer _timer;
  static const _timeoutDuration = Duration(minutes: 5);
  late Timer _timeoutTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recupera as instâncias dos providers
    authService = Provider.of<AuthService>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    _timeoutTimer = Timer(_timeoutDuration, _handleTimeout);
  }

  void _handleTimeout() async {
    // Limpa os dados do usuário (ex: removendo do SharedPreferences ou via AuthService)
    await authService.logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  void dispose() {
    _timeoutTimer.cancel();
    _timer.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  String _formatDuration() {
    final minutes = (_countdown ~/ 60).toString().padLeft(2, '0');
    final seconds = (_countdown % 60).toString().padLeft(2, '0');
    return 'Aguarde ($minutes:$seconds)';
  }

  void _handleInput(int index, String value) async {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      }
    } else {
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }

    if (fullCode.length == 6) {
      final user = await authService.fakeSMS(fullCode);
      if (user != null) {
        _timeoutTimer.cancel();
        // Atualiza o estado de login no provider (exemplo de método login que espera um user)
        authProvider.login(user.token!);
        Navigator.pushReplacementNamed(context, '/');
      }
    }
  }

  String get fullCode => _controllers.map((c) => c.text).join();

  @override
  Widget build(BuildContext context) {
    // Aqui você recupera o número salvo no provider
    final userPhone = authProvider.userPhone;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SMS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Usando o número que foi armazenado no provider:
            Text(
              'Enviamos um código por SMS para o número de telefone:\n$userPhone\nDigite o código no campo abaixo para concluir.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  child: TextFormField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    style: const TextStyle(fontSize: 24),
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) => _handleInput(index, value),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  TextButton(
                    onPressed: _countdown == 0
                        ? () {
                            setState(() => _countdown = 164);
                            _startTimer();
                          }
                        : null,
                    child: const Text(
                      'REENVIAR SMS',
                      style: TextStyle(color: Colors.deepPurple),
                    ),
                  ),
                  Text(
                    _formatDuration(),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
