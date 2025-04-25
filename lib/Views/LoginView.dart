import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vidamais/Providers/AuthProvider.dart';
import 'package:vidamais/Services/AuthService.dart';
import 'package:vidamais/Views/smsView.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCountry = 'BR';
  final _documentController = TextEditingController();
  final _passwordController = TextEditingController();
  late AuthService authService;
  late AuthProvider authProvider;

  bool _isLoading = false;

  final List<Map<String, String>> _countries = [
    {'code': 'BR', 'name': 'Brasil'},
    {'code': 'AR', 'name': 'Argentina'},
    {'code': 'US', 'name': 'Estados Unidos'},
    {'code': 'ES', 'name': 'Espanha'},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recupera as instâncias dos providers
    authService = Provider.of<AuthService>(context, listen: false);
    authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _documentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Você pode descomentar o Dropdown se precisar permitir a mudança do país.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entrar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Por favor, informe o país de origem do seu documento de identificação para prosseguir.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              // Caso queira habilitar a seleção do país, descomente o Dropdown:
              /* DropdownButtonFormField<String>(
                value: _selectedCountry,
                decoration: const InputDecoration(
                  labelText: 'País de origem do documento*',
                  border: OutlineInputBorder(),
                ),
                items: _countries.map((country) {
                  return DropdownMenuItem<String>(
                    value: country['code'],
                    child: Text(country['name']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCountry = value!);
                },
                validator: (value) {
                  if (value == null) return 'Selecione um país';
                  return null;
                },
              ), */
              const SizedBox(height: 20),
              TextFormField(
                controller: _documentController,
                inputFormatters: _selectedCountry == 'BR'
                    ? <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(11),
                        _CpfInputFormatter(),
                      ]
                    : <TextInputFormatter>[],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _selectedCountry == 'BR'
                      ? 'Documento (CPF)*'
                      : 'Documento*',
                  border: const OutlineInputBorder(),
                  hintText: _selectedCountry == 'BR' ? '000.000.000-00' : '',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o documento';
                  if (_selectedCountry == 'BR' && value.length != 14)
                    return 'CPF inválido';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                obscureText: true,
                controller: _passwordController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  hintText: 'Senha',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe a senha';
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Não tem uma conta?", textAlign: TextAlign.center),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/createAccountView'),
                    child: const Text("Criar", textAlign: TextAlign.center),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isLoading = true;
                            });
                            final String cpfLimpo = _documentController.text.replaceAll(RegExp(r'[^0-9]'), '');
                            
                            // Chama o fakeLogin e aguarda a resposta
                            final user = await authService.fakeLogin(
                              cpfLimpo,
                              _passwordController.text,
                            );
                            
                            if (user != null) {
                              // Exemplo: Armazenar algum dado (número do telefone) no provider
                              authProvider.setUserPhone('5517...150');
                              await authService.saveLoginData(user.token!, 'user123');
                              // Navega para a tela de SMS
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const SmsView()),
                              );
                            }
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // Se _isLoading for true, mostra um CircularProgressIndicator
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'ENTRAR',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formatted = text;

    if (text.length > 3) {
      formatted = '${text.substring(0, 3)}.';
      if (text.length > 6) {
        formatted += '${text.substring(3, 6)}.';
        if (text.length > 9) {
          formatted += '${text.substring(6, 9)}-${text.substring(9)}';
        } else {
          formatted += text.substring(6);
        }
      } else {
        formatted += text.substring(3);
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
