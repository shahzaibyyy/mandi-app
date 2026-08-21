import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/models/fee_type.dart';
import '../../../data/models/market.dart';
import '../../../data/providers.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/empty_state.dart';
import '../widgets/fee_type_form_sheet.dart';

class ManageFeeTypesScreen extends ConsumerWidget {
  const ManageFeeTypesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fees = ref.watch(feeTypesControllerProvider);
    final markets = ref.watch(marketsControllerProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Fee Types')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context, markets),
        icon: const Icon(Icons.add),
        label: const Text('Add fee type'),
      ),
      body: fees.isEmpty
          ? EmptyState(
              icon: Icons.sell_outlined,
              title: 'No fee types',
              message: 'Add entry fees, vehicle fees, or crate rates.',
              actionLabel: 'Add fee type',
              onAction: () => _openForm(context, markets),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: fees.length,
              itemBuilder: (context, index) {
                final fee = fees[index];
                final matches = markets.where((m) => m.id == fee.marketId);
                final marketName = fee.marketId == null
                    ? 'All markets'
                    : (matches.isEmpty ? 'Unknown market' : matches.first.name);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(fee.name),
                    subtitle: Text(
                      '$marketName · ${fee.unitLabel} · ${CurrencyFormatter.format(fee.defaultRate)}${fee.isActive ? '' : ' · inactive'}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        try {
                          await ref
                              .read(feeTypesControllerProvider.notifier)
                              .delete(fee.id);
                        } catch (error) {
                          if (context.mounted) {
                            SnackbarUtils.error(context, error);
                          }
                        }
                      },
                    ),
                    onTap: () =>
                        _openForm(context, markets, existing: fee),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _openForm(
    BuildContext context,
    List<Market> markets, {
    FeeType? existing,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => FeeTypeFormSheet(markets: markets, existing: existing),
    );
  }
}