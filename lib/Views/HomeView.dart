import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidamais/Providers/AuthProvider.dart';
import 'package:vidamais/Providers/LaborProvider.dart';
import 'package:vidamais/Views/PreSchedulingView.dart';
import 'package:vidamais/models/Labor.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _mainTabController;
  late TabController _laboratorioTabController;

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this);
    _laboratorioTabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    _laboratorioTabController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final laborProvider = Provider.of<LaborProvider>(context, listen: false);
    
    await authProvider.logout();
    await laborProvider.logout();
    
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final laborProvider = Provider.of<LaborProvider>(context);
    final Labor? lab = laborProvider.selectedLabor;

    return Scaffold(
      appBar: AppBar(
        title: Text(lab?.nome ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _mainTabController,
              children: [
                _buildPanelTab(lab),
                _buildLaboratorioTab(authProvider),
                _buildNotificationsTab(),
              ],
            ),
          ),
          Container(
            color: Colors.grey[200],
            child: TabBar(
              controller: _mainTabController,
              labelColor: Colors.deepPurple,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard), text: 'Painel',), 
                Tab(icon: Icon(Icons.science), text: 'Laboratorio',),
                Tab(icon: Icon(Icons.notifications), text: 'Notificação',),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanelTab(Labor? lab) {
    if (lab == null) return const Center(child: Text('Nenhum laboratório selecionado'));

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'UNIDADES'),
              Tab(text: 'EXAMES'),
              Tab(text: 'CONVÊNIOS'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildUnitList(lab.unidades),
                _buildExamList(lab.exames),
                _buildConveniosList(lab.convenios),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildNotificationsTab() {

    return Text('notificação');
  }

  Widget _buildUnitList(List<String> unidades) {
    return ListView.builder(
      itemCount: unidades.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(unidades[index]),
        subtitle: const Text('Endereço completo da unidade'),
      ),
    );
  }

  Widget _buildExamList(List<String> exames) {
    return ListView.builder(
      itemCount: exames.length,
      itemBuilder: (context, index) => ListTile(
        title: Text(exames[index]),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Widget _buildConveniosList(List<String> convenios) {
    return ListView.builder(
      itemCount: convenios.length,
      itemBuilder: (context, index) => Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(convenios[index]),
        ),
      ),
    );
  }

  Widget _buildLaboratorioTab(AuthProvider authProvider) {
    return Column(
      children: [
        TabBar(
          controller: _laboratorioTabController,
          tabs: const [
            Tab(text: 'RESULTADOS'),
            Tab(text: 'PRÉ-AGENDAMENTO'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _laboratorioTabController,
            children: [
              authProvider.isLoggedIn 
                  ? _buildResultados() 
                  : _buildLoginMessage(),
              authProvider.isLoggedIn 
                  ? _buildPreAgendamento() 
                  : _buildLoginMessage(),
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildLoginMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Para acessar esta funcionalidade',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              'faça login ou crie uma conta',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              child: const Text('ENTRAR'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/createAccountView'),
              child: const Text('CRIAR CONTA'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultados() {
    return ListView(
      children: const [
        ListTile(
          title: Text('Hemograma Completo'),
          subtitle: Text('Resultado disponível: 05/01/2024'),
          trailing: Icon(Icons.assignment),
        ),
        // Adicione mais resultados
      ],
    );
  }

  Widget _buildPreAgendamento() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.add_circle),
          title: const Text('Novo Pré-Agendamento'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PreSchedulingScreen()),
            );
          },
        ),
      ],
    );
  }
}