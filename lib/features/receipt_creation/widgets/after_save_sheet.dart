import 'package:flutter/material.dart';

import '../../../data/models/receipt.dart';

class AfterSaveSheet extends StatelessWidget {
  const AfterSaveSheet({super.key, required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Receipt ${receipt.receiptNumber} saved',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text('Print now on the Bluetooth thermal printer, or save only.'),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop('print'),
            icon: const Icon(Icons.print),
            label: const Text('Print'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop('save'),
            child: const Text('Save only'),
          ),
        ],
      ),
    );
  }
}