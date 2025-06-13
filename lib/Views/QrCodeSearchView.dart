import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vidamais/Providers/LaborProvider.dart';

class QrCodeSearchView extends StatefulWidget {
  const QrCodeSearchView({super.key});

  @override
  State<QrCodeSearchView> createState() => _QrCodeSearchViewState();
}

class _QrCodeSearchViewState extends State<QrCodeSearchView> {
  bool isFlashOn = false;
  late MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null) return;

    try {
      final uri = Uri.parse(code);
      final idStr = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
      final id = int.tryParse(idStr);

      if (id != null) {
        final laborProvider = Provider.of<LaborProvider>(context, listen: false);
        final found = await laborProvider.setLabor(id);
        if (found) {
          Navigator.pushNamed(context, '/home');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Laboratório não encontrado.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID inválido no QR Code')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR Code inválido')),
      );
    }

    // Evita múltiplos disparos
    _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busca por código QR'),
        actions: [
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              _controller.toggleTorch();
              setState(() => isFlashOn = !isFlashOn);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: _handleBarcode,
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Escaneie o Código QR para acesso ao laboratório e serviços disponíveis.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
