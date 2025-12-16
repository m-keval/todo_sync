import 'package:flutter/material.dart';

class OfflineStatusBanner extends StatelessWidget {
  final bool isConnected;

  const OfflineStatusBanner({Key? key, required this.isConnected})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isConnected) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: Colors.red[700],
      padding: const EdgeInsets.all(8),
      child: const Text(
        'You are offline. Changes will be synced when you are back online.',
        style: TextStyle(color: Colors.white, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}
