import 'package:firebase_auth/firebase_auth.dart';
import 'api_client.dart';

class WalletManager {
  static User? get _user => FirebaseAuth.instance.currentUser;

  static Future<void> createUserWallet({required String username}) async {
    final user = _user;
    if (user == null) return;

    await ApiClient.postJson('/users/sync', {
      'firebaseUid': user.uid,
      'email': user.email,
      'username': username,
    });
  }

  static Future<double> getBalance() async {
    final user = _user;
    if (user == null) return 0.0;

    final data = await ApiClient.getJson('/users/${user.uid}/wallet') as Map<String, dynamic>;
    return (data['walletBalance'] as num? ?? 0).toDouble();
  }

  static Stream<double> getBalanceStream() async* {
    while (true) {
      yield await getBalance();
      await Future<void>.delayed(const Duration(seconds: 5));
    }
  }

  static Future<bool> addCredits(double amount) async {
    final user = _user;
    if (user == null || amount <= 0) return false;

    try {
      await ApiClient.postJson('/users/${user.uid}/wallet/add', {'amount': amount});
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> makePurchase(double amount) async {
    final user = _user;
    if (user == null || amount <= 0) return false;

    try {
      await ApiClient.postJson('/users/${user.uid}/wallet/purchase', {'amount': amount});
      return true;
    } catch (_) {
      return false;
    }
  }
}
