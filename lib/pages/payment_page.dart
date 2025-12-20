import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:gap/gap.dart';
import '../keys.dart';
import '../utils/styles.dart';
import 'package:http/http.dart' as http;

class PaymentPage extends StatefulWidget {
  final String bookingId;
  final String serviceName;
  final String petName;
  final double amount;

  const PaymentPage({
    Key? key,
    required this.bookingId,
    required this.serviceName,
    required this.petName,
    this.amount = 0.0,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = 'credit_card';
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController expiryController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  
  Map<String, dynamic>? intentPaymentData;
  String? currentPaymentIntentId; // NEW: Track current payment intent ID

  // Calculate amount based on service (in real app, this comes from backend)
  double get totalAmount => widget.amount > 0 ? widget.amount : _calculateAmount();

  double _calculateAmount() {
    if (widget.serviceName.contains('Hotel')) {
      return 350.00; // RM 350
    } else if (widget.serviceName.contains('Grooming')) {
      return 180.00; // RM 180
    } else if (widget.serviceName.contains('Vet')) {
      return 250.00; // RM 250
    } else if (widget.serviceName.contains('Daycare')) {
      return 120.00; // RM 120
    } else if (widget.serviceName.contains('Training')) {
      return 200.00; // RM 200
    }
    return 200.00;
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    cardHolderController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Styles.highlightColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Payment',
          style: TextStyle(
            color: Styles.blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Booking Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Styles.bgColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Styles.highlightColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.receipt_long, color: Styles.highlightColor),
                      const Gap(10),
                      Text(
                        'Booking Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Styles.blackColor,
                        ),
                      ),
                    ],
                  ),
                  const Gap(15),
                  Divider(color: Colors.grey.shade300),
                  const Gap(15),
                  _buildSummaryRow('Booking ID', widget.bookingId),
                  const Gap(10),
                  _buildSummaryRow('Pet Name', widget.petName),
                  const Gap(10),
                  _buildSummaryRow('Service', widget.serviceName),
                  const Gap(15),
                  Divider(color: Colors.grey.shade300),
                  const Gap(15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Styles.blackColor,
                        ),
                      ),
                      Text(
                        'RM ${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Styles.highlightColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Gap(30),

            // Payment Method Selection
            Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Styles.blackColor,
              ),
            ),
            const Gap(15),

            _buildPaymentMethodOption(
              'credit_card',
              'Credit/Debit Card',
              Icons.credit_card,
            ),
            const Gap(10),
            _buildPaymentMethodOption(
              'digital_wallet',
              'Digital Wallet',
              Icons.account_balance_wallet,
            ),
            const Gap(10),
            _buildPaymentMethodOption(
              'bank_transfer',
              'Bank Transfer',
              Icons.account_balance,
            ),

            const Gap(30),

            // Payment Details Form
            if (selectedPaymentMethod == 'digital_wallet') ...[
              _buildDigitalWalletOptions(),
            ] else if (selectedPaymentMethod == 'bank_transfer') ...[
              _buildBankTransferInfo(),
            ],

            const Gap(30),

            // Pay Now Button
            ElevatedButton(
              onPressed: () {
                paymentSheetInitialization(
                  totalAmount.round().toString(),
                  "myr",
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.highlightColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: Text(
                'Pay RM ${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Gap(20),

            // Security badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const Gap(5),
                Text(
                  'Secure payment powered by Stripe',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const Gap(20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Styles.blackColor.withOpacity(0.6),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Styles.blackColor,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodOption(
    String value,
    String title,
    IconData icon,
  ) {
    final isSelected = selectedPaymentMethod == value;
    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Styles.highlightColor.withOpacity(0.1)
              : Styles.bgColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? Styles.highlightColor
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Styles.highlightColor : Colors.grey.shade600,
              size: 24,
            ),
            const Gap(15),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Styles.highlightColor : Styles.blackColor,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Styles.highlightColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalWalletOptions() {
    return Column(
      children: [
        _buildWalletOption('Apple Pay', Icons.apple),
        const Gap(10),
        _buildWalletOption('Google Pay', Icons.android),
        const Gap(10),
        _buildWalletOption('PayPal', Icons.payment),
      ],
    );
  }

  Widget _buildWalletOption(String name, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Styles.bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Styles.highlightColor),
          const Gap(15),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              color: Styles.blackColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankTransferInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700),
              const Gap(10),
              Text(
                'Bank Transfer Details',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const Gap(15),
          _buildBankDetail('Bank Name', 'Maybank'),
          const Gap(8),
          _buildBankDetail('Account Number', '1234567890'),
          const Gap(8),
          _buildBankDetail('Account Name', 'Pawgoda Sdn Bhd'),
          const Gap(8),
          _buildBankDetail('Reference', widget.bookingId),
          const Gap(15),
          Text(
            'Please include booking ID as reference',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.blue.shade900,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
      ],
    );
  }

  // ========== FIREBASE LOGGING METHODS ==========
  
  /// Log payment attempt to Firebase
  Future<void> _logPaymentToFirebase({
    required String status,
    String? error,
    String? paymentIntentId,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('payment').add({
        'bookingId': widget.bookingId,
        'serviceName': widget.serviceName,
        'petName': widget.petName,
        'amount': totalAmount,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
        'paymentMethod': selectedPaymentMethod,
        if (error != null) 'error': error,
        if (paymentIntentId != null) 'paymentIntentId': paymentIntentId,
      });
      
      debugPrint('✅ Payment logged to Firebase: $status');
    } catch (e) {
      debugPrint('❌ Failed to log payment to Firebase: $e');
      // Don't throw - logging failure shouldn't stop payment process
    }
  }

  // ========== NEW HELPER FUNCTIONS (ADDED) ==========
  
  /// NEW: Check if payment already logged to prevent duplicates
  Future<bool> _isPaymentAlreadyLogged(String paymentIntentId) async {
    try {
      final existingPayments = await FirebaseFirestore.instance
          .collection('payment')
          .where('paymentIntentId', isEqualTo: paymentIntentId)
          .limit(1)
          .get();
      
      return existingPayments.docs.isNotEmpty;
    } catch (e) {
      debugPrint('⚠️ Error checking existing payment: $e');
      return false; // If check fails, allow logging (safer)
    }
  }

  /// NEW: Log payment with duplicate prevention
  Future<void> _logPaymentSafely({
    required String status,
    String? error,
    String? paymentIntentId,
  }) async {
    // Check for duplicates if we have a payment intent ID
    if (paymentIntentId != null) {
      final alreadyLogged = await _isPaymentAlreadyLogged(paymentIntentId);
      if (alreadyLogged) {
        debugPrint('⚠️ Payment already logged: $paymentIntentId (skipping duplicate)');
        return; // Skip logging duplicate
      }
    }
    
    // Use existing function to log
    await _logPaymentToFirebase(
      status: status,
      error: error,
      paymentIntentId: paymentIntentId,
    );
  }

  /// NEW: Update booking document with payment status
  Future<void> _updateBookingPaymentStatus(String status, String? paymentIntentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        'paymentStatus': status,
        if (paymentIntentId != null) 'paymentIntentId': paymentIntentId,
        if (status == 'success') 'paidAt': FieldValue.serverTimestamp(),
      });
      
      debugPrint('✅ Booking payment status updated: $status');
    } catch (e) {
      debugPrint('⚠️ Failed to update booking status: $e');
      // Don't throw - this shouldn't stop the payment flow
    }
  }

  // ========== PAYMENT PROCESSING METHODS ==========
  
  Future<void> paymentSheetInitialization(String amountToBeCharge, String currency) async {
    try {
      debugPrint('💳 Initializing payment sheet...');
      debugPrint('   Amount: $amountToBeCharge $currency');
      
      // Log payment attempt to Firebase
      await _logPaymentToFirebase(status: 'pending');

      try {
        intentPaymentData = await makeIntentForPayment(amountToBeCharge, currency);
        
        if (intentPaymentData == null) {
          throw Exception('Failed to create payment intent');
        }

        // NEW: Store the payment intent ID
        currentPaymentIntentId = intentPaymentData!['id'];

        debugPrint('✅ Payment intent data received');
        debugPrint('   Client secret: ${intentPaymentData!['client_secret']}');
        debugPrint('   Payment Intent ID: $currentPaymentIntentId'); // NEW: Log the ID

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: intentPaymentData!['client_secret'],
            merchantDisplayName: 'Pawgoda',
            style: ThemeMode.light,
            billingDetailsCollectionConfiguration: const BillingDetailsCollectionConfiguration(
              name: CollectionMode.always,
              email: CollectionMode.always,
              phone: CollectionMode.always,
            ),
          ),
        );

        debugPrint('✅ Payment sheet initialized');

        await showPaymentSheet();

      } catch (initError) {
        debugPrint('❌ Payment sheet init error: $initError');
        
        // NEW: Log error with duplicate prevention using tracked ID
        await _logPaymentSafely(
          status: 'failed',
          error: initError.toString(),
          paymentIntentId: currentPaymentIntentId, // NEW: Use tracked ID
        );
        
        // NEW: Update booking status
        await _updateBookingPaymentStatus('failed', currentPaymentIntentId);
        
        rethrow;
      }
      
    } catch (errorMsg, stackTrace) {
      debugPrint('❌ Payment sheet initialization failed!');
      debugPrint('   Error: $errorMsg');
      if (kDebugMode) {
        debugPrint('   Stack trace: $stackTrace');
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const Gap(12),
                Expanded(
                  child: Text('Payment error: ${errorMsg.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<Map<String, dynamic>?> makeIntentForPayment(String amountToBeCharge, String currency) async {
    try {
      debugPrint('📤 Creating payment intent...');
      
      final amountInCents = (int.parse(amountToBeCharge) * 100).toString();
      
      Map<String, dynamic> paymentInfo = {
        "amount": amountInCents,
        "currency": currency.toLowerCase(), 
        "payment_method_types[]": "card",
      };
      
      debugPrint('   Amount: $amountToBeCharge ${currency.toUpperCase()}');
      debugPrint('   Amount in cents: $amountInCents');

      var responseStripe = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: paymentInfo,
        headers: {
          "Authorization": "Bearer $stripeSecretKey",
          "Content-Type": "application/x-www-form-urlencoded"
        },
      );

      debugPrint('   Response status: ${responseStripe.statusCode}');
      
      if (responseStripe.statusCode == 200) {
        final responseData = jsonDecode(responseStripe.body);
        debugPrint('   Response body: ${responseStripe.body}');
        debugPrint('✅ Payment intent created successfully');
        return responseData;
      } else {
        debugPrint('❌ Failed to create payment intent');
        debugPrint('   Status code: ${responseStripe.statusCode}');
        debugPrint('   Response: ${responseStripe.body}');
        throw Exception('Payment intent creation failed: ${responseStripe.body}');
      }
    } catch (errorMsg) {
      debugPrint('❌ Error creating payment intent: $errorMsg');
      if (kDebugMode) {
        debugPrint('   Full error: ${errorMsg.toString()}');
      }
      rethrow;
    }
  }

  Future<void> showPaymentSheet() async {
    try {
      debugPrint('📱 Presenting payment sheet...');
      
      await Stripe.instance.presentPaymentSheet();
      
      debugPrint('✅ Payment completed successfully!');
      
      // NEW: Log successful payment with duplicate prevention
      await _logPaymentSafely(
        status: 'success',
        paymentIntentId: currentPaymentIntentId,
      );

      // NEW: Update booking document with payment status
      await _updateBookingPaymentStatus('success', currentPaymentIntentId);
     
      setState(() {
        intentPaymentData = null;
        currentPaymentIntentId = null; // NEW: Clear the payment intent ID
      });
      
      if (mounted) {
        _showPaymentSuccess();
      }
    } on StripeException catch (error) {
      debugPrint('❌ Stripe error occurred!');
      debugPrint('   Error code: ${error.error.code}');
      debugPrint('   Error message: ${error.error.message}');
      debugPrint('   Error localized message: ${error.error.localizedMessage}');
      
      if (kDebugMode) {
        debugPrint('   Full error: $error');
      }
      
      // Log failed payment to Firebase
      if (error.error.code != FailureCode.Canceled) {
        // NEW: Use safe logging to prevent duplicates
        await _logPaymentSafely(
          status: 'failed',
          error: error.error.message ?? 'Stripe error',
          paymentIntentId: currentPaymentIntentId, // NEW: Use tracked ID
        );
        
        // NEW: Update booking status
        await _updateBookingPaymentStatus('failed', currentPaymentIntentId);
      }
      
      if (mounted) {
        if (error.error.code == FailureCode.Canceled) {
          // User cancelled - don't log as failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white),
                  Gap(12),
                  Text('Payment cancelled'),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          // Other error
          showDialog(
            context: context,
            builder: (c) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700),
                  const Gap(10),
                  const Text('Payment Failed'),
                ],
              ),
              content: Text(
                error.error.localizedMessage ?? error.error.message ?? 'An error occurred',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c),
                  child: Text(
                    'OK',
                    style: TextStyle(color: Styles.highlightColor),
                  ),
                ),
              ],
            ),
          );
        }
      }
    } catch (errorMsg, stackTrace) {
      debugPrint('❌ Unexpected error showing payment sheet!');
      debugPrint('   Error: $errorMsg');
      if (kDebugMode) {
        debugPrint('   Stack trace: $stackTrace');
      }
      
      // Log failed payment to Firebase
      // NEW: Use safe logging to prevent duplicates
      await _logPaymentSafely(
        status: 'failed',
        error: errorMsg.toString(),
        paymentIntentId: currentPaymentIntentId, // NEW: Use tracked ID
      );
      
      // NEW: Update booking status
      await _updateBookingPaymentStatus('failed', currentPaymentIntentId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const Gap(12),
                Expanded(
                  child: Text('Payment error: ${errorMsg.toString()}'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 60,
              ),
            ),
            const Gap(20),
            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(10),
            Text(
              'Your booking has been confirmed',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(10),
            Text(
              'Booking ID: ${widget.bookingId}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
              ),
            ),
            const Gap(25),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Styles.highlightColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Back to Home',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}