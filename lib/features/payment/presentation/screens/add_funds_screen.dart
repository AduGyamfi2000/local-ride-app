import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/payment_bloc.dart';

class AddFundsScreen extends StatefulWidget {
  final String userId;

  const AddFundsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<AddFundsScreen> createState() => _AddFundsScreenState();
}

class _AddFundsScreenState extends State<AddFundsScreen> {
  final _amountController = TextEditingController();
  String _selectedMethod = 'card';
  String _selectedAmount = '';

  final List<double> _quickAmounts = [10, 20, 50, 100];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Funds'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: _quickAmounts.length,
                itemBuilder: (context, index) {
                  final amount = _quickAmounts[index];
                  final isSelected = _selectedAmount == amount.toString();
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAmount = amount.toString()),
                    child: Card(
                      color: isSelected ? const Color(0xFFE8A020) : Colors.white,
                      child: Center(
                        child: Text(
                          'GHS ${amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Or Enter Custom Amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (GHS)',
                  border: OutlineInputBorder(),
                  prefixText: 'GHS ',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => setState(() => _selectedAmount = value),
              ),
              const SizedBox(height: 32),
              const Text(
                'Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildMethodOption('card', '💳 Credit/Debit Card'),
              const SizedBox(height: 12),
              _buildMethodOption('mobile_money', '📱 Mobile Money'),
              const SizedBox(height: 32),
              BlocListener<PaymentBloc, PaymentState>(
                listener: (context, state) {
                  if (state is WalletLoaded) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Funds added successfully!')),
                    );
                    Navigator.pop(context);
                  } else if (state is PaymentFailure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                child: BlocBuilder<PaymentBloc, PaymentState>(
                  builder: (context, state) {
                    final isLoading = state is PaymentLoading;
                    final amount = double.tryParse(_selectedAmount) ?? 0;

                    return AppButton(
                      onPressed: amount > 0 && !isLoading
                          ? () => _addFunds(amount)
                          : null,
                      text: isLoading ? 'Processing...' : 'Add Funds', label: '',
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodOption(String value, String label) {
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = value),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: _selectedMethod,
                onChanged: (val) => setState(() => _selectedMethod = val!),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addFunds(double amount) {
    context.read<PaymentBloc>().add(
          AddFundsEvent(
            userId: widget.userId,
            amount: amount,
            method: _selectedMethod,
          ),
        );
  }
}
