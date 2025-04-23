import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RazorpayApiIntegration extends StatefulWidget {
  final int amount;
  final String eventId;

  const RazorpayApiIntegration({
    super.key,
    required this.amount,
    required this.eventId,
  });

  @override
  State<RazorpayApiIntegration> createState() => _RazorpayApiIntegrationState();
}

class _RazorpayApiIntegrationState extends State<RazorpayApiIntegration> {
  late Razorpay _razorpay;
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_test_36aoYpSrjOomtE', // Use your actual key in production
      'amount': widget.amount * 100,
      'name': 'Event HUB',
      'description': 'Event Booking',
      'timeout': 60,
      'prefill': {
        'contact': '9730516224',
        'email': 'jawalkarjay7@gmail.com',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay checkout: $e'); // Improved error logging
      debugPrint('Error opening Razorpay checkout: $e');
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    debugPrint('Payment Success: ${response.paymentId}');
    print('Payment Success: ${response.paymentId}'); // Additional log

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final result = await _supabase.rpc(
        'append_user_to_event',
        params: {
          'event_id': widget.eventId,
          'user_id': userId,
        },
      );

      debugPrint('RPC Result: $result');
      print('RPC Result: $result'); // Log result from Supabase

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful! You are now registered.'),
        ),
      );
    } catch (e, st) {
      debugPrint('Error updating event: $e\n$st');
      print('Error updating event: $e\n$st'); // Log error and stack trace

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment succeeded but registration failed: $e'),
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('Payment Error: ${response.code} - ${response.message}');
    print(
        'Payment Error: ${response.code} - ${response.message}'); // Additional log
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Error: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External Wallet: ${response.walletName}');
    print('External Wallet: ${response.walletName}'); // Additional log
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Razorpay Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: openCheckout,
          child: Text("Pay ${widget.amount}"),
        ),
      ),
    );
  }
}
