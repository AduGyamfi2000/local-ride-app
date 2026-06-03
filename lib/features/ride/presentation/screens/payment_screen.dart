import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rural_ride/features/payment/presentation/bloc/payment_bloc.dart';
import '../../../../core/widgets/app_button.dart';


class PaymentScreen extends StatefulWidget {
  final String rideId;
  final double estimatedFare;
  final String userId;

  const PaymentScreen({
    Key? key,
    required this.rideId,
    required this.estimatedFare,
    required this.userId,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'wallet';
  late double _totalAmount;

  @override
  void initState() {
    super.initState();
    _totalAmount = widget.estimatedFare;
    context.read<PaymentBloc>().add(GetWalletEvent(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocListener<PaymentBloc, PaymentState>(
            listener: (context, state) {
              if (state is PaymentSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment successful!')),
                );
                Navigator.pop(context, true);
              } else if (state is PaymentFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ride Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(),
                const SizedBox(height: 32),
                const Text(
                  'Select Payment Method',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                BlocBuilder<PaymentBloc, PaymentState>(
                  builder: (context, state) {
                    if (state is WalletLoaded) {
                      return _buildPaymentMethods(state.wallet.balance);
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                const SizedBox(height: 32),
                BlocBuilder<PaymentBloc, PaymentState>(
                  builder: (context, state) {
                    if (state is PaymentLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return AppButton(
                      onPressed: _processPayment,
                      text: 'Pay GHS ${_totalAmount.toStringAsFixed(2)}', label: '',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSummaryRow('Base Fare', 'GHS 5.00'),
            const SizedBox(height: 8),
            _buildSummaryRow('Distance', 'GHS ${(widget.estimatedFare - 5).toStringAsFixed(2)}'),
            const Divider(height: 16),
            _buildSummaryRow(
              'Total',
              'GHS ${_totalAmount.toStringAsFixed(2)}',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods(double walletBalance) {
    return Column(
      children: [
        _buildMethodOption(
          'wallet',
          '💳 Wallet',
          'Balance: GHS ${walletBalance.toStringAsFixed(2)}',
          walletBalance >= _totalAmount,
        ),
        const SizedBox(height: 12),
        _buildMethodOption(
          'card',
          '🏦 Credit/Debit Card',
          'Visa, Mastercard',
          true,
        ),
        const SizedBox(height: 12),
        _buildMethodOption(
          'mobile_money',
          '📱 Mobile Money',
          'MTN, Vodafone, AirtelTigo',
          true,
        ),
      ],
    );
  }

  Widget _buildMethodOption(
    String value,
    String title,
    String subtitle,
    bool isAvailable,
  ) {
    return GestureDetector(
      onTap: isAvailable ? () => setState(() => _selectedMethod = value) : null,
      child: Card(
        color: isAvailable ? Colors.white : Colors.grey[200],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Radio<String>(
                value: value,
                groupValue: _selectedMethod,
                onChanged: isAvailable ? (val) => setState(() => _selectedMethod = val!) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? Colors.black : Colors.grey,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isAvailable ? Colors.grey : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processPayment() {
    context.read<PaymentBloc>().add(
          ProcessPaymentEvent(
            rideId: widget.rideId,
            amount: _totalAmount,
            method: _selectedMethod,
          ),
        );
  }
}
