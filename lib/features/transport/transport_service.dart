import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransportService {
  TransportService({
    FirebaseFirestore? firestore,
    FirebaseDatabase? database,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _database = database ?? FirebaseDatabase.instance;

  final FirebaseFirestore _firestore;
  final FirebaseDatabase _database;

  CollectionReference<Map<String, dynamic>> get requests =>
      _firestore.collection('transport_requests');

  CollectionReference<Map<String, dynamic>> get trips =>
      _firestore.collection('trips');

  CollectionReference<Map<String, dynamic>> get ratings =>
      _firestore.collection('ratings');

  Future<String> createRequest({
    required String customerId,
    required String serviceType,
    required GeoPoint origin,
    required GeoPoint destination,
  }) async {
    final doc = await requests.add({
      'customerId': customerId,
      'serviceType': serviceType,
      'origin': {
        'latitude': origin.latitude,
        'longitude': origin.longitude,
      },
      'destination': {
        'latitude': destination.latitude,
        'longitude': destination.longitude,
      },
      'status': 'searching',
      'driverId': null,
      'acceptedOfferId': null,
      'acceptedPrice': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  Future<String> createOffer({
    required String requestId,
    required String driverId,
    required double price,
  }) async {
    final offerRef = await requests
        .doc(requestId)
        .collection('offers')
        .add({
      'driverId': driverId,
      'price': price,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return offerRef.id;
  }

  Future<void> acceptOffer({
    required String requestId,
    required String offerId,
    required String driverId,
    required double price,
    required String customerId,
  }) async {
    final requestRef = requests.doc(requestId);

    final offerRef = requestRef
        .collection('offers')
        .doc(offerId);

    final tripRef = trips.doc(requestId);

    await _firestore.runTransaction((transaction) async {
      final requestSnap = await transaction.get(requestRef);

      if (!requestSnap.exists) {
        throw Exception('La solicitud ya no existe.');
      }

      final requestData = requestSnap.data()!;

      final currentStatus =
          requestData['status'] as String?;

      if (currentStatus != 'searching') {
        throw Exception(
          'Esta solicitud ya fue confirmada.',
        );
      }

      transaction.update(requestRef, {
        'status': 'accepted',
        'driverId': driverId,
        'acceptedOfferId': offerId,
        'acceptedPrice': price,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      transaction.update(offerRef, {
        'status': 'accepted',
      });

      transaction.set(tripRef, {
        'requestId': requestId,
        'customerId': customerId,
        'driverId': driverId,
        'price': price,
        'status': 'accepted',
        'origin': requestData['origin'],
        'destination': requestData['destination'],
        'commissionRate': 0.20,
        'commission': 0.0,
        'driverNet': 0.0,
        'commissionProcessed': false,
        'startedAt': null,
        'completedAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> startTrip(String tripId) async {
    await trips.doc(tripId).update({
      'status': 'active',
      'startedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> completeTrip(String tripId) async {
    final tripRef = trips.doc(tripId);

    await _firestore.runTransaction((transaction) async {
      final tripSnap = await transaction.get(tripRef);

      if (!tripSnap.exists) {
        throw Exception('El viaje no existe.');
      }

      final data = tripSnap.data()!;

      if (data['status'] == 'completed') {
        return;
      }

      final rawPrice = data['price'];

      final price = rawPrice is num
          ? rawPrice.toDouble()
          : 0.0;

      final driverId =
          data['driverId'] as String?;

      final commission = double.parse(
        (price * 0.20).toStringAsFixed(2),
      );

      final driverNet = double.parse(
        (price - commission).toStringAsFixed(2),
      );

      transaction.update(tripRef, {
        'status': 'completed',
        'completedAt':
            FieldValue.serverTimestamp(),
        'commission': commission,
        'driverNet': driverNet,
        'commissionProcessed': true,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (driverId != null) {
        final walletRef = _firestore
            .collection('driver_wallets')
            .doc(driverId);

        final walletSnap =
            await transaction.get(walletRef);

        final wallet =
            walletSnap.data() ?? {};

        final currentBalance =
            (wallet['balance'] as num?)
                    ?.toDouble() ??
                0.0;

        final totalCommission =
            (wallet['totalCommission'] as num?)
                    ?.toDouble() ??
                0.0;

        final newBalance = double.parse(
          (currentBalance - commission)
              .toStringAsFixed(2),
        );

        transaction.set(
          walletRef,
          {
            'balance': newBalance,
            'totalCommission': double.parse(
              (totalCommission + commission)
                  .toStringAsFixed(2),
            ),
            'lastCommission': commission,
            'lastTripId': tripId,
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
    });

    await _database
        .ref('active_trips/$tripId')
        .remove();
  }

  Future<void> updateDriverLocation({
    required String driverId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
  }) async {
    await _database
        .ref('driver_locations/$driverId')
        .set({
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading ?? 0,
      'speed': speed ?? 0,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> updateTripLocation({
    required String tripId,
    required String driverId,
    required String customerId,
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
  }) async {
    await _database
        .ref('active_trips/$tripId')
        .set({
      'driverId': driverId,
      'customerId': customerId,
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading ?? 0,
      'speed': speed ?? 0,
      'updatedAt': ServerValue.timestamp,
    });
  }

  Future<void> ensureDriverWallet(
    String driverId,
  ) async {
    final walletRef = _firestore
        .collection('driver_wallets')
        .doc(driverId);

    final snapshot = await walletRef.get();

    if (!snapshot.exists) {
      await walletRef.set({
        'balance': 100.0,
        'totalCommission': 0.0,
        'lastCommission': 0.0,
        'lastTripId': null,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> createRating({
    required String tripId,
    required String customerId,
    required String driverId,
    required int rating,
    String? comment,
  }) async {
    await ratings.add({
      'tripId': tripId,
      'customerId': customerId,
      'driverId': driverId,
      'rating': rating,
      'comment': comment ?? '',
      'createdAt':
          FieldValue.serverTimestamp(),
    });

    await trips.doc(tripId).set(
      {
        'customerRated': true,
        'customerRating': rating,
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}

final transportServiceProvider =
    Provider<TransportService>(
  (ref) => TransportService(),
);