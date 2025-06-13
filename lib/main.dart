import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vidamais/Providers/AuthProvider.dart';
import 'package:vidamais/Providers/LaborProvider.dart';
import 'package:vidamais/Providers/ScheduleProvider.dart';
import 'package:vidamais/Services/AuthService.dart';
import 'package:vidamais/Services/LaborService.dart';
import 'package:vidamais/Services/ScheduleService.dart';
import 'package:vidamais/Views/LoginView.dart';
import 'package:vidamais/Views/QrCodeSearchView.dart';
import 'package:vidamais/Views/SearchView.dart';
import 'package:vidamais/Views/createAccountView.dart';
import 'package:vidamais/Views/HomeView.dart';
import 'package:vidamais/Views/smsView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();  
  final authService = AuthService();
  final isLoggedIn = await authService.isLoggedIn();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        Provider<AuthService>(create: (_) => authService),
        ChangeNotifierProvider(
          create: (_) => LaborProvider(
            laborService: LaborService(),
            prefs: prefs,
            service: ScheduleService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ScheduleProvider(
            service: ScheduleService(),
          ),
        ),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vidamais',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(isLoggedIn: isLoggedIn),
        '/login': (context) => LoginView(),
        '/smsView': (context) => SmsView(),
        '/createAccountView': (context) => CreateAccountView(),
        '/qrScan': (context) => QrCodeSearchView(),
        '/search': (context) => SearchView(),
        '/home': (context) => HomeView(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key,required this.isLoggedIn});
  final bool isLoggedIn;


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AuthProvider authProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/vida_mais_logo2.png',
                    width: 250,
                  ),
                ),
              ),

              // PARTE INFERIOR FIXADA
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Encontre o seu laboratório',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Localize o laboratório desejado para consulta de instruções de exames, resultados de exames, pré-agendamento e outros serviços.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/qrScan');
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        'ESCANEAR CÓDIGO QR',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('OU'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/search');
                    },
                    icon: const Icon(Icons.search),
                    label: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        'BUSCAR POR NOME',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.deepPurple),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: !authProvider.isLoggedIn
                          ? Text.rich(
                              TextSpan(
                                text: 'Já tem conta? ',
                                style: const TextStyle(color: Colors.grey),
                                children: [
                                  TextSpan(
                                    text: 'ENTRAR / CRIAR CONTA',
                                    style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}