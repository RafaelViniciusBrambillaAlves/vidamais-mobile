import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vidamais/Providers/AuthProvider.dart';
import 'package:vidamais/Providers/LaborProvider.dart';
import 'package:vidamais/Views/PreSchedulingView.dart';
import 'package:vidamais/models/Agreement.dart';
import 'package:vidamais/models/Exam.dart';
import 'package:vidamais/models/Labor.dart';
import 'package:vidamais/models/Unit.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final laborProvider = Provider.of<LaborProvider>(context);
    final Labor? lab = laborProvider.selectedLabor;

    return Scaffold(
      appBar: AppBar(
        title: Text(lab?.name ?? ''),
        actions: [
        ],
      ),
      body: Column(
        children: [],
      ),
    );
  }
}