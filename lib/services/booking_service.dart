import 'package:firebase_auth/firebase_auth.dart';
import 'api_client.dart';
import 'wallet_manager.dart';

class BookingService {
  static User? get _user => FirebaseAuth.instance.currentUser;

  static Future<bool> createBooking({
    required int movieId,
    required String movieTitle,
    required String bookingDetails,
    required List<String> selectedSeats,
    required int totalPrice,
  }) async {
    return WalletManager.makePurchase(totalPrice.toDouble());
  }

  static Future<List<Map<String, dynamic>>> getBookings() async {
    final user = _user;
    if (user == null) return [];

    final data = await ApiClient.getJson('/users/${user.uid}/bookings') as List<dynamic>;
    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  static Future<Map<String, dynamic>?> getBooking(String bookingId) async {
    final user = _user;
    if (user == null) return null;

    final data = await ApiClient.getJson('/users/${user.uid}/bookings/$bookingId') as Map<String, dynamic>;
    return data;
  }

  static Future<void> saveTicketBooking({
    required String bookingId,
    required int movieId,
    required String movieTitle,
    required String cinemaName,
    required String cinemaLocation,
    required String showTime,
    required List<String> selectedSeats,
    required int totalPrice,
    required String posterUrl,
    required List<String> castList,
  }) async {
    final user = _user;
    if (user == null) throw Exception('Please sign in first');

    await ApiClient.postJson('/bookings', {
      'firebaseUid': user.uid,
      'bookingId': bookingId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'cinemaName': cinemaName,
      'cinemaLocation': cinemaLocation,
      'showTime': showTime,
      'selectedSeats': selectedSeats,
      'totalPrice': totalPrice,
      'posterUrl': posterUrl,
      'castList': castList,
    });
  }

  static Future<void> markReviewed(String bookingId) async {
    final user = _user;
    if (user == null) return;
    await ApiClient.postJson('/users/${user.uid}/bookings/$bookingId/reviewed', {});
  }
}
