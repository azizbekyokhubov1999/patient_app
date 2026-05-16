import 'package:cloud_firestore/cloud_firestore.dart';

/// Navigation payload for the Get Direction flow.
class GetDirectionArgs {
  GetDirectionArgs({
    required this.hospitalId,
    required this.hospitalName,
    required this.geoPoint,
    this.hospitalAddress,
  });

  final String hospitalId;
  final String hospitalName;
  final GeoPoint geoPoint;

  /// Optional address for route preview / arrival screens.
  final String? hospitalAddress;
}
