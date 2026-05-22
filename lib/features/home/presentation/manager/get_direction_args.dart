import 'package:cloud_firestore/cloud_firestore.dart';

/// Navigation payload for the Get Direction flow.
import '../../../booking/presentation/models/e_receipt_args.dart';

class GetDirectionArgs {
  GetDirectionArgs({
    required this.hospitalId,
    required this.hospitalName,
    required this.geoPoint,
    this.hospitalAddress,
    this.eReceipt,
  });

  final String hospitalId;
  final String hospitalName;
  final GeoPoint geoPoint;

  /// Optional address for route preview / arrival screens.
  final String? hospitalAddress;

  /// E-Receipt shown after arrival (offline appointment flow).
  final EReceiptArgs? eReceipt;
}
