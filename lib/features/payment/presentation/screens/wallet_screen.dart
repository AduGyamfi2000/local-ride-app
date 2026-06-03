import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/payment_bloc.dart';

class WalletScreen extends StatefulWidget {
  final String userId;

  const WalletScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PaymentBloc>().add(GetWalletEvent(widget.userId));
    context.read<PaymentBloc>().add(GetTransactionHistoryEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wallet'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) {
                  if (state is WalletLoaded) {
                    return _buildWalletCard(state.wallet.balance);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              const SizedBox(height: 32),
              AppButton(
                onPressed: () => _showAddFundsDialog(context),
                text: 'Add Funds', label: '',
              ),
              const SizedBox(height: 32),
              const Text(
                'Transaction History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, state) {
                  if (state is TransactionHistoryLoaded) {
                    if (state.transactions.isEmpty) {
                      return const Center(
                        child: Text('No transactions yet'),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = state.transactions[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              transaction.type == 'payment'
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color:
                                  transaction.type == 'payment' ? Colors.red : Colors.green,
                            ),
                            title: Text(transaction.type.toUpperCase()),
                            subtitle: Text(transaction.timestamp.toString()),
                            trailing: Text(
                              '${transaction.type == 'payment' ? '-' : '+'}GHS ${transaction.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: transaction.type == 'payment' ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard(double balance) {
    return Card(
      color: const Color(0xFF1B6B3A),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Balance',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'GHS ${balance.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddFundsDialog(BuildContext context) {
    final amountController = TextEditingController();
    String selectedMethod = 'card';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Funds'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (GHS)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedMethod,
                items: const [
                  DropdownMenuItem(value: 'card', child: Text('Credit/Debit Card')),
                  DropdownMenuItem(value: 'mobile_money', child: Text('Mobile Money')),
                ],
                onChanged: (value) {
                  selectedMethod = value!;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                context.read<PaymentBloc>().add(
                      AddFundsEvent(
                        userId: widget.userId,
                        amount: amount,
                        method: selectedMethod,
                      ),
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
