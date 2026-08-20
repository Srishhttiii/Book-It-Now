// lib/screens/credits_page.dart

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../services/credits_manager.dart';
import '../services/wallet_manager.dart';
import '../models/constants.dart';

class CreditsPage extends StatefulWidget {
  const CreditsPage({super.key});

  @override
  State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  // Conversion rates (500 = 100)
  final int creditsToConvert = 500;
  final double moneyToReceive = 100.0;

  bool _isConverting = false;

  void _convertCredits() async {
    setState(() {
      _isConverting = true;
    });

    try {
      await CreditsManager.convertCredits(
        credits: creditsToConvert,
        money: moneyToReceive,
      );
      _showSuccess('Successfully added ₹$moneyToReceive to your wallet.');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isConverting = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: const Text(
          'My Credits',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        constraints: const BoxConstraints.expand(),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 0, 0, 0),
              Color.fromARGB(255, 49, 1, 1),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Credit Balance Card ---
              _buildCreditBalanceCard(CreditsManager.getCreditsStream()),

              const SizedBox(height: 20),

              // --- 2. Wallet Balance Row ---
              _buildWalletBalanceRow(WalletManager.getBalanceStream()),

              const SizedBox(height: 32),

              // --- 3. Instructions ---
              Text(
                "How to Earn Credits ?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: primaryFont,
                ),
              ),
              const SizedBox(height: 16),
              _buildRuleCard(
                icon: Iconsax.edit,
                text: "Earn 100 credits per review you post.",
              ),
              const SizedBox(height: 12),
              _buildRuleCard(
                icon: Iconsax.ticket_star,
                text: "For every 500 credits, you can redeem ₹100.",
              ),
              const SizedBox(height: 32),

              // --- 4. Conversion Button Section ---
              StreamBuilder<int>(
                stream: CreditsManager.getCreditsStream(),
                builder: (context, snapshot) {
                  final currentCredits = snapshot.data ?? 0;
                  final bool canConvert = currentCredits >= creditsToConvert;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: canConvert
                            ? [
                                const Color.fromARGB(255, 74, 2, 2),
                                const Color.fromARGB(255, 74, 2, 2),
                              ]
                            : [Colors.grey.shade700, Colors.grey.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: canConvert ? [] : [],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: (canConvert && !_isConverting)
                          ? _convertCredits
                          : null,
                      child: _isConverting
                          ? const SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Redeem $creditsToConvert Credits',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Credit Balance Card Widget ---
  Widget _buildCreditBalanceCard(Stream<int> stream) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 146, 28, 28),
            Color.fromARGB(255, 69, 5, 5)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Credits :",
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          StreamBuilder<int>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(color: Colors.white);
              }
              final credits = snapshot.data ?? 0;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Iconsax.coin, color: Colors.amberAccent, size: 38),
                  const SizedBox(width: 12),
                  Text(
                    credits.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Wallet Balance Card Widget ---
  Widget _buildWalletBalanceRow(Stream<double> stream) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ListTile(
        leading:
            const Icon(Iconsax.wallet_3, color: Colors.greenAccent, size: 30),
        title: const Text(
          "Wallet Balance",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: StreamBuilder<double>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(strokeWidth: 2);
            }
            final balance = snapshot.data?.toStringAsFixed(2) ?? '0.00';
            return Text(
              '₹ $balance',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Rule Card Widget ---
  Widget _buildRuleCard({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 229, 218, 18), size: 26),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
