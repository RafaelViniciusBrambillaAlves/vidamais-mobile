import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidamais/Providers/LaborProvider.dart';

class SearchView extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final laborProvider = Provider.of<LaborProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar por Nome'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Digite o nome do laboratório',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => laborProvider.searchLabs(_searchController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => laborProvider.searchLabs(value),
            ),
          ),
          Expanded(
            child: Consumer<LaborProvider>(
              builder: (context, provider, child) {
                if (provider.labs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text('Carregando laboratórios...'),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: provider.labs.length,
                  itemBuilder: (context, index) {
                    final lab = provider.labs[index];
                    return ListTile(
                      title: Text(lab.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (lab.units.isNotEmpty)
                            Text('Unidades: ${lab.units.map((u) => u.name).join(', ')}'),
                          if (lab.units.isEmpty)
                            Text('Nenhuma unidade cadastrada'),
                        ],
                      ),
                      onTap: () {
                        final laborProvider = Provider.of<LaborProvider>(context, listen: false);
                        laborProvider.setLabor(lab.id);
                        Navigator.pushNamed(context, '/home');
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}