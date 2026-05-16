import 'package:cloud_firestore/cloud_firestore.dart';

sealed class GetDirectionState {
  const GetDirectionState();
}

final class GetDirectionInitial extends GetDirectionState {
  const GetDirectionInitial();
}

final class GetDirectionLoading extends GetDirectionState {
  const GetDirectionLoading();
}

final class GetDirectionLoaded extends GetDirectionState {
  const GetDirectionLoaded({
    required this.destination,
    this.userLocation,
  });

  final GeoPoint destination;
  final GeoPoint? userLocation;
}

final class GetDirectionError extends GetDirectionState {
  const GetDirectionError(this.message);

  final String message;
}
