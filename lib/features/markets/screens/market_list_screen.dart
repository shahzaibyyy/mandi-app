import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/snackbar_utils.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/empty_state.dart';

class MarketListScreen extends ConsumerWidget {
  const MarketListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final markets = ref.watch(marketsControllerProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Markets / منڈیاں')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/markets/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add market'),
      ),
      body: markets.isEmpty
          ? EmptyState(
              icon: Icons.storefront_outlined,
              title: 'No mandis yet',
              message: 'Add the markets where you collect entry fees.',
              actionLabel: 'Add market',
              onAction: () => context.push('/markets/new'),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: markets.length,
              itemBuilder: (context, index) {
                final market = markets[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(market.name),
                    subtitle: Text(
                      '${market.cityDistrict}${market.address == null || market.address!.isEmpty ? '' : ' · ${market.address}'}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        try {
                          await ref
                              .read(marketsControllerProvider.notifier)
                              .delete(market.id);
                        } catch (error) {
                          if (context.mounted) {
                            SnackbarUtils.error(context, error);
                          }
                        }
                      },
                    ),
                    onTap: () => context.push('/markets/${market.id}/edit'),
                  ),
                );
              },
            ),
    );
  }
}