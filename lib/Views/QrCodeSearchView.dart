import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeSearchView extends StatefulWidget {
  const QrCodeSearchView({super.key});

  @override
  State<QrCodeSearchView> createState() => _QrCodeSearchViewState();
}

class _QrCodeSearchViewState extends State<QrCodeSearchView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isFlashOn = false;

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
    if (scanData.code != null) {
      Navigator.pop(context); // Fecha o scanner
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Código escaneado'),
          content: Text(scanData.code!),
        ),
      );
    }
  });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busca por código QR'),
        actions: [
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              await controller?.toggleFlash();
              setState(() => isFlashOn = !isFlashOn);
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.deepPurple,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Escaneie o Código QR para acesso ao laboratório e serviços disponíveis.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}