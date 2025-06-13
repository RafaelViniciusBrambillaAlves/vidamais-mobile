import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:vidamais/Providers/AuthProvider.dart';
import 'package:vidamais/Providers/LaborProvider.dart';
import 'package:vidamais/models/Labor.dart';
import 'package:vidamais/models/Result.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ResultView extends StatefulWidget {
  const ResultView({Key? key}) : super(key: key);

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  List<Result> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final laborProvider = Provider.of<LaborProvider>(context, listen: false);
      final Labor? selectedLab = laborProvider.selectedLabor;

      if (selectedLab == null || selectedLab.units.isEmpty) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
        return;
      }

      final userId = int.tryParse(authProvider.userId ?? '');
      if (userId == null) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
        return;
      }

      List<Result> allResults = [];

      for (final unit in selectedLab.units) {
        final unitResults = await laborProvider.loadUserResult(userId, unit.id);
        allResults.addAll(unitResults);
      }

      setState(() {
        _results = allResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _results = [];
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar resultados: $e')),
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_results.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum resultado disponível.',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];
        final createdAt = result.createdAt;
        final formattedDate = '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year} - ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: Text(formattedDate),
            subtitle: Text('Disponível: ${result.status.name ?? ''}'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              try {
                final dio = Dio();
                final dir = await getTemporaryDirectory();
                final fileName = result.fileResult.split('/').last;
                final savePath = '${dir.path}/$fileName';


                final response = await dio.download(
                  'https://c7ad-2804-14d-8487-9c03-d5fa-2482-ef11-32e3.ngrok-free.app/files/$fileName',
                  savePath,
                );

                if (response.statusCode == 200) {
                  await OpenFile.open(savePath);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Falha ao baixar o arquivo')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao abrir arquivo: $e')),
                );
              }
            },
          ),
        );
      },
    );
  }
}
