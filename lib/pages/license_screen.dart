import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  String? _license;

  static const _appBarTitle = 'Safe List';
  static const _mainTitle = 'Toque na tela para colar sua licença';
  static const _subtitle =
      'Copie sua licença e toque em qualquer lugar da tela';
  static const _successMessage = 'Licença colada com sucesso!';
  static const _errorMessage =
      'Nenhuma licença encontrada na área de transferência';
  static const _licensePrefix = 'Licença: ';
  static const _snackBarDuration = Duration(seconds: 2);
  static const _navigationDelay = Duration(seconds: 1);
  static const _maxLicensePreviewLength = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(_appBarTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: GestureDetector(
        onTap: _onTapArea,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.transparent,
          child: _buildContent(),
        ),
      ),
    );
  }

  String _formatLicensePreview(String license) {
    return license.length > _maxLicensePreviewLength
        ? '${license.substring(0, _maxLicensePreviewLength)}...'
        : license;
  }

  Widget _buildLicensePreview() {
    if (_license == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$_licensePrefix${_formatLicensePreview(_license!)}',
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, size: 80, color: Colors.deepPurple),
          const SizedBox(height: 24),
          const Text(
            _mainTitle,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            _subtitle,
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildLicensePreview(),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: _snackBarDuration),
    );
  }

  void _navigateToTodoList() async {
    await Future.delayed(_navigationDelay);
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/todo-list',
        arguments: _license,
      );
    }
  }

  void _onTapArea() async {
    final clipboardData = await Clipboard.getData('text/plain');

    if (clipboardData?.text != null && clipboardData!.text!.isNotEmpty) {
      setState(() {
        _license = clipboardData.text;
      });
      _showSnackBar(_successMessage);
      _navigateToTodoList();
    } else {
      _showSnackBar(_errorMessage);
    }
  }
}
