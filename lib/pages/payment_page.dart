import 'dart:convert';

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
            // if (selectedPaymentMethod == 'credit_card') ...[
            //   Text(
            //     'Card Details',
            //     style: TextStyle(
            //       fontSize: 18,
            //       fontWeight: FontWeight.bold,
            //       color: Styles.blackColor,
            //     ),
            //   ),
            //   const Gap(15),
            //   _buildCardForm(),
            // ] else
              if (selectedPaymentMethod == 'digital_wallet') ...[
              _buildDigitalWalletOptions(),
            ] else ...[
              _buildBankTransferInfo(),
            ],

            const Gap(30),

            // Pay Now Button
            ElevatedButton(
              // onPressed: _processPayment,
              onPressed: ()
              {
                paymentSheetInitialization(
                  totalAmount.round().toString(),
                  "MYR",
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
                  'Secure payment powered by PawGoda',
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

  Widget _buildCardForm() {
    return Column(
      children: [
        TextField(
          controller: cardNumberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Card Number',
            hintText: '1234 5678 9012 3456',
            prefixIcon: Icon(Icons.credit_card, color: Styles.highlightColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Styles.highlightColor, width: 2),
            ),
          ),
        ),
        const Gap(15),
        TextField(
          controller: cardHolderController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Card Holder Name',
            hintText: 'John Doe',
            prefixIcon: Icon(Icons.person, color: Styles.highlightColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Styles.highlightColor, width: 2),
            ),
          ),
        ),
        const Gap(15),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: expiryController,
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(
                  labelText: 'Expiry Date',
                  hintText: 'MM/YY',
                  prefixIcon: Icon(Icons.calendar_today, color: Styles.highlightColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Styles.highlightColor, width: 2),
                  ),
                ),
              ),
            ),
            const Gap(15),
            Expanded(
              child: TextField(
                controller: cvvController,
                keyboardType: TextInputType.number,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: '123',
                  prefixIcon: Icon(Icons.lock, color: Styles.highlightColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Styles.highlightColor, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDigitalWalletOptions() {
    return Column(
      children: [
        _buildWalletOption('Apple Pay', 'assets/svg/apple_pay.svg'),
        const Gap(10),
        _buildWalletOption('Google Pay', 'assets/svg/google_pay.svg'),
        const Gap(10),
        _buildWalletOption('PayPal', 'assets/svg/paypal.svg'),
      ],
    );
  }

  Widget _buildWalletOption(String name, String iconPath) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Styles.bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet, color: Styles.highlightColor),
          const Gap(15),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Styles.blackColor,
            ),
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios, size: 16, color: Styles.highlightColor),
        ],
      ),
    );
  }

  Widget _buildBankTransferInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Styles.bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bank Transfer Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Styles.blackColor,
            ),
          ),
          const Gap(15),
          _buildBankDetail('Bank Name', 'PawGoda Bank'),
          const Gap(10),
          _buildBankDetail('Account Number', '1234567890'),
          const Gap(10),
          _buildBankDetail('Account Name', 'PawGoda Pet Hotel'),
          const Gap(10),
          _buildBankDetail('Reference', widget.bookingId),
          const Gap(15),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.orange.shade700, size: 20),
                const Gap(10),
                Expanded(
                  child: Text(
                    'Please include your booking ID as reference',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
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
            color: Styles.blackColor.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Styles.blackColor,
          ),
        ),
      ],
    );
  }

  Map<String, dynamic>? intentPaymentData;

  paymentSheetInitialization(amountToBeCharge,currency) async{
    try {
      intentPaymentData = await makeIntentForPayment(amountToBeCharge,currency);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          allowsDelayedPaymentMethods: true,
          paymentIntentClientSecret: intentPaymentData!['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: "Pawgoda"
        )
      ).then((val)
      {
        print(val);
      });

      showPaymentSheet();

    }catch (errorMsg,s){
      if(kDebugMode){
        print(s);
      }

      print(errorMsg.toString());
    }
  }

  makeIntentForPayment(amountToBeCharge,currency) async {
    try {
      Map<String, dynamic>? paymentInfo =
          {
            "amount": (int.parse(amountToBeCharge) * 100).toString(),
            "currency": currency,
            "payment_method_types[]": "card"
          };

      var responseStripe = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: paymentInfo,
        headers:
          {
            "Authorization": "Bearer $StripeSecretKey",
            "Content-Type": "application/x-www-form-urlencoded"
          }
      );

      print("response from API = " + responseStripe.body);
      
      return jsonDecode(responseStripe.body);
    } catch (errorMsg) {
      if(kDebugMode){
        print(errorMsg.toString());
      }

      print(errorMsg.toString());
    }

  }

  showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((val){
        intentPaymentData = null;
      }).onError((errorMsg,sTrace){
        if(kDebugMode){
          print(errorMsg.toString() + sTrace.toString());
        }
      });
    }
    on StripeException catch(error) {
      if(kDebugMode){
        print(error);
      }
      
      showDialog(
          context: context, 
          builder: (c) => const AlertDialog(
            content: Text("cancelled"),
          )
      );
    }
    catch (errorMsg, s) {
      if(kDebugMode){
        print(s);
      }

      print(errorMsg.toString());
    }
  }

  void _processPayment() {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Styles.highlightColor),
              const Gap(20),
              const Text('Processing payment...'),
            ],
          ),
        ),
      ),
    );

    // Simulate payment processing
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close loading
      _showPaymentSuccess();
    });
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}