import 'package:firebase_auth/firebase_auth.dart';
import 'api_client.dart';

class CreditsManager {
  static User? get _user => FirebaseAuth.instance.currentUser;

  static Future<int> getCredits() async {
    final user = _user;
    if (user == null) return 0;

    final data = await ApiClient.getJson('/users/${user.uid}/wallet') as Map<String, dynamic>;
    return (data['credits'] as num? ?? 0).toInt();
  }

  static Stream<int> getCreditsStream() async* {
    while (true) {
      yield await getCredits();
      await Future<void>.delayed(const Duration(seconds: 5));
    }
  }

  static Future<void> addCredits(int amount) async {
    final user = _user;
    if (user == null) return;
    await ApiClient.postJson('/users/${user.uid}/credits/add', {'amount': amount});
  }

  static Future<void> spendCredits(int amount) async {
    final user = _user;
    if (user == null) return;
    await ApiClient.postJson('/users/${user.uid}/credits/spend', {'amount': amount});
  }

  static Future<void> convertCredits({required int credits, required double money}) async {
    final user = _user;
    if (user == null) return;
    await ApiClient.postJson('/users/${user.uid}/credits/convert', {
      'credits': credits,
      'money': money,
    });
  }
}
