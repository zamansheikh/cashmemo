import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/pdf_service.dart';
import '../../bloc/cash_memo/cash_memo_bloc.dart';
import '../../bloc/cash_memo/cash_memo_state.dart';
import '../../bloc/cash_memo/cash_memo_event.dart';
import '../../bloc/shop_settings/shop_settings_bloc.dart';
import '../../bloc/shop_settings/shop_settings_state.dart';

class CashMemosScreen extends StatelessWidget {
  const CashMemosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cash Memos')),
      body: BlocBuilder<CashMemoBloc, CashMemoState>(
        builder: (context, state) {
          if (state is CashMemoLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CashMemoLoaded) {
            if (state.cashMemos.isEmpty) {
              return const Center(child: Text('No cash memos found'));
            }
            return ListView.builder(
              padding: Responsive.padding(context),
              itemCount: state.cashMemos.length,
              itemBuilder: (context, index) {
                final memo = state.cashMemos[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accent,
                      child: const Icon(Icons.receipt, color: Colors.white),
                    ),
                    title: Text('Memo #${memo.memoNumber}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat(
                            AppConstants.dateTimeFormat,
                          ).format(memo.date),
                        ),
                        if (memo.customerName != null)
                          Text('Customer: ${memo.customerName}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '৳${memo.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.print),
                          onPressed: () async {
                            final settingsBloc = context
                                .read<ShopSettingsBloc>();
                            final settingsState = settingsBloc.state;
                            if (settingsState is ShopSettingsLoaded) {
                              await PdfService.generateAndPrintCashMemo(
                                memo,
                                settingsState.settings,
                              );
                            } else {
                              await PdfService.generateAndPrintCashMemo(
                                memo,
                                null,
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            context.read<CashMemoBloc>().add(
                              DeleteCashMemo(memo.id),
                            );
                          },
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
